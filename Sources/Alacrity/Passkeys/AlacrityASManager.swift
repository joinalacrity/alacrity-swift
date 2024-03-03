//
//  AlacrityASManager.swift
//  
//
//  Created by Anderthan Hsieh on 3/3/24.
//

import Foundation

import Foundation
import AuthenticationServices

public struct PasskeyRegistrationCredential: Codable {
  public let id: String
  public let rawId: String
  public let type: String
  public let authenticatorAttachment: String
  public let response: PasskeyRegistrationCredentialResponse
}

public struct PasskeyRegistrationCredentialResponse: Codable {
  public let attestationObject: String?
  public let clientDataJSON: String
}


class AlacrityASManager: NSObject, ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<ASAuthorization, Error>?
    private var controller: ASAuthorizationController?
    
    func loginWithPasskey(rpIdentifier: String, challenge: String, username: String) async -> AlacrityResponse<[String: Any]> {
        // Should probably switch this over to base64
        let challenge: Data = Data(challenge.utf8)
        
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpIdentifier)
        let platformKeyRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge)
        
        let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController.delegate = self
        authController.presentationContextProvider = self
        self.controller = authController
        
        do {
            let authorization = try await withCheckedThrowingContinuation { continuation in
              self.continuation = continuation
                
              authController.performRequests()
            }
            
            self.continuation = nil
            self.controller = nil
            
            guard
              let credentialAssertion = authorization.credential
                as? ASAuthorizationPlatformPublicKeyCredentialAssertion
            else {
                print("wtf")
                return AlacrityResponse(error: "asdf")
            }
            
            // Convert to dictionary
            guard let signature = credentialAssertion.signature else {
                return AlacrityResponse(error: "Missing signature")
            }
            guard let authenticatorData = credentialAssertion.rawAuthenticatorData else {
                return AlacrityResponse(error: "Missing authenticator data")
            }
            guard let userID = credentialAssertion.userID else {
                return AlacrityResponse(error: "Missing user ID")
            }
            
            let clientDataJSON = credentialAssertion.rawClientDataJSON
            let credentialId = credentialAssertion.credentialID
        
            let payload = ["rawId": credentialId.base64EncodedString(), // Base64
                           "id": credentialId.base64URLEncode(), // Base64URL
                           // "authenticatorAttachment": "platform", // Optional
                           // "clientExtensionResults": [String: Any](), // Optional
                           "type": "public-key",
                               "response": [
                                "clientDataJSON": clientDataJSON.base64EncodedString(),
                                "authenticatorData": authenticatorData.base64EncodedString(),
                                "signature": signature.base64EncodedString(),
                                "userHandle": userID.base64URLEncode()
                               ],
                           "username": username
            ] as [String: Any]
            
            return AlacrityResponse(data: payload)
            
        } catch {
            self.continuation = nil
            self.controller = nil
            return AlacrityResponse(error: error.localizedDescription)
        }
    }

    func createPasskey(rpIdentifier: String, username: String, challenge: Data, userId: Data) async -> AlacrityResponse<[String: Any]> {
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpIdentifier)
        
        let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challenge, name: username, userID: userId)
        let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController.delegate = self
        authController.presentationContextProvider = self
        self.controller = authController

        
        do {
            let authorization = try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
                if #unavailable(iOS 16.0) {
                    authController.performRequests()
                }
                else {
                    authController.performAutoFillAssistedRequests()
                }
            }
            self.continuation = nil
            self.controller = nil
            
            guard
              let credential = authorization.credential
                as? ASAuthorizationPlatformPublicKeyCredentialRegistration else {
                return AlacrityResponse(error: "asdf")
            }
                
            guard let attestation = credential.rawAttestationObject else { return AlacrityResponse(error: "asdf")}
                let clientDataJSON = credential.rawClientDataJSON
                let credentialID = credential.credentialID
            
                let payload = ["rawId": credentialID.base64EncodedString(), // Base64
                               "id": credential.credentialID.base64URLEncode(), // Base64URL
                               "authenticatorAttachment": "platform", // Optional parameter
                               "type": "public-key",
                               "response": [
                                   "attestationObject": attestation.base64EncodedString(),
                                   "clientDataJSON": clientDataJSON.base64EncodedString(),
                               ]
                ] as [String: Any]
                return AlacrityResponse(data: payload)
            
        } catch {
            self.continuation = nil
            self.controller = nil
            return AlacrityResponse(error: error.localizedDescription)
        }
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            fatalError("Unable to find a window scene.")
        }
        guard let _ = windowScene.keyWindow else {
            fatalError("Unable to find a key window.")
        }
        
        let keyWindow = UIApplication
          .shared
          .connectedScenes
          .compactMap { $0 as? UIWindowScene }
          .flatMap { $0.windows }
          .first { $0.isKeyWindow }

        return keyWindow!
    }
}

extension AlacrityASManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation?.resume(returning: authorization)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}
