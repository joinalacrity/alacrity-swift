//
//  AlacrityPushAPIManager.swift
//  
//
//  Created by Anderthan Hsieh on 3/3/24.
//

import Foundation

public struct AlacrityPushAPIManager {
    let baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    public func addPushAuthenticator(token: String, params: AddPushAuthenticatorParams) async throws -> AlacrityResponse<AlacrityAuthenticatorResponse> {
        let relativeURL = URL(string: self.baseURL + "/v1/authenticators/")!
        var request = URLRequest(url: relativeURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "kind": "push",
            "public_key": params.publicKey,
            "details": [
                "name": params.device.name,
                "model": params.device.model
            ]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (httpResponse.statusCode == 200) /* OK */ else {
            return AlacrityResponse(error: "Error has occurred")
        }
        
        let obj = try JSONDecoder().decode(AlacrityAuthenticatorResponse.self, from: data)
        return AlacrityResponse(data: obj)
    }
    
    public func getAuthenticators(token: String) async throws -> AlacrityResponse<[AlacrityAuthenticatorResponse]> {
        let relativeURL = URL(string: self.baseURL + "/v1/authenticators/")!
        var request = URLRequest(url: relativeURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (httpResponse.statusCode == 200) /* OK */ else {
            return AlacrityResponse(error: "Error has occurred")
        }
        
        let obj = try JSONDecoder().decode([AlacrityAuthenticatorResponse].self, from: data)
        return AlacrityResponse(data: obj)
    }
    
    public func getChallengeForPushAuthenticator(token: String) async throws ->
        AlacrityResponse<AlacrityPushChallengeResponse> {
            let relativeURL = URL(string: self.baseURL + "/v1/authenticators/push/challenge")!
            var request = URLRequest(url: relativeURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (httpResponse.statusCode == 200) /* OK */ else {
                return AlacrityResponse(error: "Error has occurred")
            }
            
            let obj = try JSONDecoder().decode(AlacrityPushChallengeResponse.self, from: data)
            return AlacrityResponse(data: obj)
    }
    
    public func sendVerificationResponseForPushAuthenticator(token: String, params: PushVerificationParams) async throws -> AlacrityResponse<AlacrityVerificationResponse> {
        
        let relativeURL = URL(string: self.baseURL + "/v1/verifications/\(params.verificationId)/responses/push")!
        var request = URLRequest(url: relativeURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "challenge": params.challenge,
            "action": params.action
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (httpResponse.statusCode == 200) /* OK */ else {
            return AlacrityResponse(error: "Error has occurred")
        }
        
        let obj = try JSONDecoder().decode(AlacrityVerificationResponse.self, from: data)
        return AlacrityResponse(data: obj)
    }
    
}
