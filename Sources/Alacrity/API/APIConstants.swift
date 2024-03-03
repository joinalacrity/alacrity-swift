//
//  APIConstants.swift
//  
//
//  Created by Anderthan Hsieh on 3/3/24.
//

import Foundation

public struct AlacrityBaseURL {
    static let Production = "https://api.joinalacrity.com"
    static let Staging = "https://staging.joinalacrity.com"
}

public enum PasskeyRegistrationError: Error {
    case genericError(String)
    case usernameExists
}

public struct PasskeyVerificationResponse: Decodable {
    public var challenge: String
    public var rpId: String
}

public struct PasskeyRegistrationResponse: Decodable {
    struct User: Decodable {
        var id: String
        var displayName: String
        var name: String
    }
    
    struct RelyingParty: Decodable {
        var name: String
        var id: String
    }
    
    var rp: RelyingParty
    var user: User
    var challenge: String
}

public struct PasskeyRegistrationComplete: Decodable {
    var key: String
}
