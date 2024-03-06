//
//  KeychainManager.swift
//  AlacrityPushDemo
//
//  Created by Anderthan Hsieh on 2/26/24.
//

import Foundation
import Security

public class KeychainManager {
    public static let shared = KeychainManager(service: "com.alacrity.AlacrityManager")
    
    private let service: String
    
    init(service: String) {
        self.service = service
    }
    
    public func getOrCreatePublicKey() -> String? {
        if let privateKey = getPrivateKey() {
            // This means that a private key exists
            return generatePublicKey(privateKey: privateKey)
        }
        else {
            // Need to generate private key
            let didGeneratePrivateKey = generatePrivateKey()
            if didGeneratePrivateKey {
                // Then we need to get the public key
                if let privateKey = getPrivateKey() {
                    return generatePublicKey(privateKey: privateKey)
                }
            }
            return nil
        }
    }
    
    public func deleteKeyPair() -> Bool {
        let tag = self.service.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecReturnRef as String: true,
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess else {
            return false
        }

        return true
    }
    
    func generatePrivateKey() -> Bool {
        let attributes: CFDictionary =
        [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
         kSecAttrKeySizeInBits as String: 2048,
         kSecPrivateKeyAttrs as String:
            [kSecAttrIsPermanent as String: true,
             kSecAttrApplicationTag as String: self.service ]
        ] as CFDictionary

        var error: Unmanaged<CFError>?

        do {
            guard SecKeyCreateRandomKey(attributes, &error) != nil else {
                throw error!.takeRetainedValue() as Error
            }
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getPrivateKey() -> SecKey?  {
        let query: CFDictionary = [kSecClass as String: kSecClassKey,
                                   kSecAttrApplicationTag as String: self.service,
                                   kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                   kSecReturnRef as String: true] as CFDictionary

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query, &item)
        guard status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)
    }
    
    func generatePublicKey(privateKey: SecKey) -> String? {
        guard let publicKey = SecKeyCopyPublicKey(privateKey),
              let data = SecKeyCopyExternalRepresentation(publicKey, nil) else {
            return nil
        }

        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, .rsaEncryptionPKCS1)
        else {
            print("not supported cryptography")
            return nil
        }
        
        let finalData = data as Data

        return finalData.base64EncodedString()
    }
    
    func signChallenge(unsignedChallenge: String) -> String? {
        guard let privateKey = self.getPrivateKey() else {
            print("cannot find privateKey")
            return nil
        }
        
        let challengeData = unsignedChallenge.data(using: .utf8)!
        
        var error: Unmanaged<CFError>?
        guard let signedChallenge = SecKeyCreateEncryptedData(privateKey, .rsaEncryptionOAEPSHA512, challengeData as CFData, &error) as Data? else {
            return nil
        }
        
        return (signedChallenge as Data).base64EncodedString()
    }
    
    public func saveAuthToken(token: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }
        
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "authToken",
            kSecValueData as String: data
        ]
        
        // Delete existing item if present
        SecItemDelete(query as CFDictionary)
        
        // Add new item to Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    public func retrieveAuthToken() -> String? {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "authToken",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
}
