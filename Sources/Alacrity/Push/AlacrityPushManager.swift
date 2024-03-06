//
//  AlacrityPushManager.swift
//  
//
//  Created by Anderthan Hsieh on 3/5/24.
//

import Foundation
import UIKit

public struct AlacrityPushManager {
    
    private let api: AlacrityPushAPIManager
    
    init(api: AlacrityPushAPIManager) {
        self.api = api
    }
    
    public func register(token: String) async -> AlacrityResponse<AlacrityAuthenticatorResponse> {
        do {
            guard let publicKey = KeychainManager.shared.getOrCreatePublicKey() else {
                return AlacrityResponse(error: "Unable to get public key")
            }
            
            let deviceName = await UIDevice.current.name
            let deviceModel = await UIDevice.current.model
            
            let params: AddPushAuthenticatorParams = AddPushAuthenticatorParams(
                publicKey: publicKey,
                device: DeviceParams(name: deviceName, model: deviceModel)
            )
            
            let authenticator = try await api.addPushAuthenticator(token: token, params: params)
            
            if let data = authenticator.data {
                return AlacrityResponse(data: data)
            }
            else {
                return AlacrityResponse(error: authenticator.error)
            }
            
            
        } catch {
            return AlacrityResponse(error: error.localizedDescription)
        }
    }
    
    public func verify(token: String, action: String, verificationId: String) async -> AlacrityResponse<AlacrityVerificationResponse> {
        do {
            let challenge = try await self.api.getChallengeForPushAuthenticator(token: token)
            
            
            guard let challengeData = challenge.data else {
                return AlacrityResponse(error: challenge.error)
            }
            
            guard let signedChallenge = KeychainManager.shared.signChallenge(unsignedChallenge: challengeData.challenge) else {
                return AlacrityResponse(error: "Unable to sign challenge")
            }
            
            let params: PushVerificationParams = PushVerificationParams(verificationId: verificationId, challenge: signedChallenge, action: action)
            let response = try await self.api.sendVerificationResponseForPushAuthenticator(token: token, params: params)
            
            guard let verificationResponse = response.data else {
                return AlacrityResponse(error: response.error)
            }
            
            return AlacrityResponse(data: verificationResponse)
            
        }
        catch {
            return AlacrityResponse(error: error.localizedDescription)
        }
    }
}
