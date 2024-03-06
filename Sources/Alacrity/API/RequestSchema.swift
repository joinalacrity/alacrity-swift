//
//  RequestSchema.swift
//  
//
//  Created by Anderthan Hsieh on 3/5/24.
//

import Foundation

public struct DeviceParams: Codable {
    var name: String
    var model: String
}

public struct AddPushAuthenticatorParams: Codable {
    var publicKey: String
    var device: DeviceParams
}

public struct PushVerificationParams: Codable {
    var verificationId: String
    var challenge: String
    var action: String
}
