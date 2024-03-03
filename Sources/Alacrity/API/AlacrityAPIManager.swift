//
//  AlacrityAPIManager.swift
//  
//
//  Created by Anderthan Hsieh on 3/3/24.
//

import Foundation

public struct AlacrityAPIManager {
    let baseURL: String
    let orgAPIKey: String
    
    init(baseURL: String, orgAPIKey: String) {
        self.baseURL = baseURL
        self.orgAPIKey = orgAPIKey
    }
    
    func getChallengeForRegistration(token: String, username: String) async throws -> AlacrityResponse<PasskeyRegistrationResponse>  {
        let relativeURL = URL(string: self.baseURL + "/v1/authenticators/register")!
        var request = URLRequest(url: relativeURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["username": username]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (httpResponse.statusCode == 200 || httpResponse.statusCode == 409) /* OK */ else {
            return AlacrityResponse(error: "Error has occurred")
        }
        
        if httpResponse.statusCode == 409 {
            throw PasskeyRegistrationError.usernameExists
        }
        
        let obj = try JSONDecoder().decode(PasskeyRegistrationResponse.self, from: data)
        
        return AlacrityResponse(data: obj)
    }
    
    func completeRegistration(token: String, payload: [String: Any]) async throws -> AlacrityResponse<AlacrityPasskeyComplete> {
        let relativeURL = URL(string: self.baseURL + "/v1/authenticators/register/complete")!
        var request = URLRequest(url: relativeURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 /* OK */ else {
            return AlacrityResponse(error: "Unable to complete registration")
        }
        let obj = try JSONDecoder().decode(AlacrityPasskeyComplete.self, from: data)
        
        return AlacrityResponse(data: obj)
    }
    
    func getChallengeForLogin(username: String) async throws -> AlacrityResponse<AlacrityPasskeyLoginRequestResponse> {
        let relativeURL = URL(string: self.baseURL + "/v1/authenticators/login")!
        var request = URLRequest(url: relativeURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ["username": username]
        let jsonData = try? JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonData
        request.setValue(self.orgAPIKey, forHTTPHeaderField: "x-api-key")
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 /* OK */ else {
            
            return AlacrityResponse(error: "Error has occurred")
        }
        
        let obj = try JSONDecoder().decode(AlacrityPasskeyLoginRequestResponse.self, from: data)
        
        return AlacrityResponse(data: obj)
    }
    
    func completeLogin(payload: [String: Any]) async throws -> AlacrityResponse<AlacrityPasskeyComplete> {
        let relativeURL = URL(string: self.baseURL + "/v1/authenticators/login/complete")!
        var request = URLRequest(url: relativeURL)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.orgAPIKey, forHTTPHeaderField: "x-api-key")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 /* OK */ else {
            return AlacrityResponse(error: "Unable to login")
        }
        
        let obj = try JSONDecoder().decode(AlacrityPasskeyComplete.self, from: data)
        return AlacrityResponse(data: obj)
    }
    
    func getChallengeForVerification(token: String) async throws -> AlacrityResponse<AlacrityPasskeyVerificationRequestResponse> {
        let relativeURL = URL(string: self.baseURL + "/v1/authenticators/verify")!
        var request = URLRequest(url: relativeURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 /* OK */ else {
            
            return AlacrityResponse(error: "Error has occurred")
        }
        
        let obj = try JSONDecoder().decode(AlacrityPasskeyVerificationRequestResponse.self, from: data)
        
        return AlacrityResponse(data: obj)
    }
    
    func completeVerification(token: String, verificationId: String, body: [String: Any]) async throws -> AlacrityResponse<AlacrityPasskeyVerificationResponse> {
        
        let relativeURL = URL(string: self.baseURL + "/v1/verifications/\(verificationId)/responses/")!
        var request = URLRequest(url: relativeURL)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let payload : [String: Any] = [
            "passkey": body
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 /* OK */ else {
            return AlacrityResponse(error: "Unable to verify response")
        }
        
        let obj = try JSONDecoder().decode(AlacrityPasskeyVerificationResponse.self, from: data)
        return AlacrityResponse(data: obj)
    }
}
