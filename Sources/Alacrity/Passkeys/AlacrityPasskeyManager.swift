//
//  AlacrityPasskeyManager.swift
//  AlacrityPushDemo
//
//  Created by Anderthan Hsieh on 2/28/24.
//

import Foundation

public struct AlacrityPasskeyManager {
    private let authenticationServiceManager: AlacrityASManager
    private let api: AlacrityAPIManager
    
    public init(baseURL: String, orgAPIKey: String) {
        self.authenticationServiceManager = AlacrityASManager()
        self.api = AlacrityAPIManager(baseURL: baseURL, orgAPIKey: orgAPIKey)
    }
    
    public func verify(username: String, token: String, verificationId: String) async throws -> AlacrityResponse<AlacrityVerificationResponse> {
        do {
            let result = try await self.api.getChallengeForVerification(token: token)
            
            if let error = result.error {
                return AlacrityResponse(error: error)
            }
            
            guard let verificationRequest = result.data else {
                return AlacrityResponse(error: "Unknown error occurred")
            }
            
            let localLoginResult = await self.authenticationServiceManager.loginWithPasskey(rpIdentifier: verificationRequest.rpId, challenge: verificationRequest.challenge, username: username)
            
            if let error = localLoginResult.error {
                return AlacrityResponse(error: error)
            }
            
            guard let credential = localLoginResult.data else {
                return AlacrityResponse(error: nil)
            }
            
            let response = try await api.completeVerification(token: token, verificationId: verificationId, body: credential)
            return response
        } catch {
            return AlacrityResponse(error: error.localizedDescription)
        }
    }
    
    public func login(username: String) async throws -> AlacrityResponse<AlacrityPasskeyComplete> {
        do {
            let result = try await self.api.getChallengeForLogin(username: username)
            
            if let error = result.error {
                return AlacrityResponse(error: error)
            }
            
            guard let login = result.data else {
                return AlacrityResponse(error: "Unknown error occurred")
            }
            
            let localLoginResult = await self.authenticationServiceManager.loginWithPasskey(rpIdentifier: login.rpId, challenge: login.challenge, username: username)
            
            if let error = localLoginResult.error {
                return AlacrityResponse(error: error)
            }
            
            guard let credential = localLoginResult.data else {
                return AlacrityResponse(error: nil)
            }
            
            let response = try await api.completeLogin(payload: credential)
            return response
        }
        catch {
            return AlacrityResponse(error: error.localizedDescription)
        }
    }
    
    public func register(token: String, username: String) async throws -> AlacrityResponse<AlacrityPasskeyComplete> {
        do {
            let result = try await self.api.getChallengeForRegistration(token: token, username: username)
            
            if let error = result.error {
              return AlacrityResponse(error: error)
            }
            
            guard let registration = result.data else {
              return AlacrityResponse(error: "Unknown error occurred")
            }
            
            let userIdentifierData = registration.user.id.data(using: .utf8)!
            let challengeData = registration.challenge.data(using: .utf8)!
            
            let creationResult = await self.authenticationServiceManager.createPasskey(rpIdentifier: registration.rp.id,username: registration.user.name, challenge: challengeData, userId: userIdentifierData)
            
            if let error = creationResult.error {
              return AlacrityResponse(error: error)
            }
            
            guard let credential = creationResult.data else {
              return AlacrityResponse(error: nil)
            }
            
            let response = try await api.completeRegistration(token: token, payload: credential)
            return response
            
        } catch PasskeyRegistrationError.usernameExists {
            throw PasskeyRegistrationError.usernameExists
        } catch {
            return AlacrityResponse(error: "Unknown error occurred")
        }
    }
}
