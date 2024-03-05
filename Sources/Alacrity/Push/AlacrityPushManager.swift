//
//  AlacrityPushManager.swift
//  
//
//  Created by Anderthan Hsieh on 3/5/24.
//

import Foundation

public struct AlacrityPushManager {
    
    private let api: AlacrityPushAPIManager
    
    init(api: AlacrityPushAPIManager) {
        self.api = api
    }
    
    public func register() async throws -> AlacrityResponse<Any> {
        guard let publicKey = KeychainManager.shared.getOrCreatePublicKey() else {
            return AlacrityResponse(error: "Unable to get public key")
        }
        
        return AlacrityResponse(data: publicKey)
    }
}
