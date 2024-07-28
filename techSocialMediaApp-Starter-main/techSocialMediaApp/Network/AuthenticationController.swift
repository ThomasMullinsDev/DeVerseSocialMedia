//
//  AuthenticationController.swift
//  techSocialMediaApp
//
//  Created by Brayden Lemke on 10/25/22.
//

import Foundation

class AuthenticationController {
    enum AuthError: Error, LocalizedError {
        case couldNotSignIn
    }
    
    func signIn(email: String, password: String) async throws -> Bool {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: "\(API.url)/signIn")!)
        
        let credentials: [String: Any] = ["email": email, "password": password]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: credentials, options: .prettyPrinted)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.couldNotSignIn
        }
        
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: data)
        
        User.current = user

        return true
    }
}
