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

public struct AlacrityPasskeyVerificationResponse: Decodable {
    public var token: String
}
