//
//  ProfileController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/10/24.
//

import Foundation

class ProfileController {
    enum AuthError: Error, LocalizedError {
        case couldNotFetchProfile
        case invalidResponse
        case invalidData
        case couldNotUpdateProfile
    }

    func fetchProfile(userUUID: UUID?, userSecret: UUID?) async throws -> Bool {
        guard let userUUID = userUUID, let userSecret = userSecret else {
            throw AuthError.couldNotFetchProfile
        }

        let session = URLSession.shared

        var urlComponents = URLComponents(string: "https://tech-social-media-app.fly.dev/userProfile")
        urlComponents?.queryItems = [
            URLQueryItem(name: "userUUID", value: userUUID.uuidString),
            URLQueryItem(name: "userSecret", value: userSecret.uuidString)
        ]

        guard let url = urlComponents?.url else {
            throw AuthError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.couldNotFetchProfile
        }
        let decoder = JSONDecoder()
        do {
            let profile = try decoder.decode(Profile.self, from: data)
            Profile.current = profile
            return true
        } catch {
            throw AuthError.invalidData
        }
    }
    
    func updateProfile(userSecret: UUID?, profile: Profile) async throws -> Bool {
        guard let userSecret = userSecret else {
            throw AuthError.couldNotUpdateProfile
        }
        
        guard let url = URL(string: "https://tech-social-media-app.fly.dev/updateProfile") else {
            throw AuthError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userSecret": userSecret.uuidString,
            "profile": [
                "userName": profile.userName,
                "bio": profile.bio,
                "techInterests": profile.techInterests
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.couldNotUpdateProfile
        }
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode([String: Bool].self, from: data)
            return response["success"] ?? false
        } catch {
            throw AuthError.invalidData
        }
    }
}



