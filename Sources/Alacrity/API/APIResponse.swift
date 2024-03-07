//
//  APIResponse.swift
//  
//
//  Created by Anderthan Hsieh on 3/3/24.
//

import Foundation

public struct AlacrityPasskeyLoginRequestResponse: Decodable {
    public var challenge: String
    public var rpId: String
}

public struct AlacrityPasskeyVerificationRequestResponse: Decodable {
    public var challenge: String
    public var rpId: String
    
    private enum CodingKeys : String, CodingKey {
        case challenge
        case rpId
    }
}

public struct AlacrityPasskeyComplete: Decodable {
    public var key: String
}

public struct AlacrityVerificationResponse: Decodable {
    public var token: String
}

public struct AlacrityPushChallengeResponse: Decodable {
    public var challenge: String
}

public struct AlacrityAuthenticatorResponse: Decodable {
    public var externalId: String
    public var createdAt: String
    public var updatedAt: String
    public var isActive: Bool
    public var kind: String
    public var friendlyName: String
    
    private enum CodingKeys : String, CodingKey {
        case externalId = "external_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isActive = "is_active"
        case friendlyName = "friendly_name"
        case kind
    }
}
