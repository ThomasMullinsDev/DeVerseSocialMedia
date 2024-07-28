//
//  PostFeedController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/10/24.
//

import Foundation

class PostFeedController {
    enum AuthError: Error, LocalizedError {
        case couldNotFetchPost
        case invalidResponse
        case invalidData
        case invalidUserSecret
        case serverError(String)
    }
    
    func fetchPosts(userSecret: UUID, pageNumber: Int? = nil) async throws -> [Post] {
        let urlString = "https://tech-social-media-app.fly.dev/posts"
        
        // Add query parameters for userSecret and pageNumber
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "userSecret", value: userSecret.uuidString)
        ]
        
        if let pageNumber = pageNumber {
            queryItems.append(URLQueryItem(name: "pageNumber", value: "\(pageNumber)"))
        }
        
        guard var urlComponents = URLComponents(string: urlString) else {
            throw AuthError.couldNotFetchPost
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw AuthError.couldNotFetchPost
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.couldNotFetchPost
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            do {
                let posts = try decoder.decode([Post].self, from: data)
                return posts
            } catch {
                throw AuthError.invalidData
            }
        case 400:
            throw AuthError.invalidUserSecret
        case 500:
            let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
            let message = errorResponse?["message"] ?? "Unknown server error"
            throw AuthError.serverError(message)
        default:
            throw AuthError.couldNotFetchPost
        }
    }
}

