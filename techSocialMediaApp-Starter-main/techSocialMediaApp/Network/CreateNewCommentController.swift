//
//  CreateNewCommentController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/28/24.
//

import Foundation

class CreateNewCommentController {
    
    func createComment(userSecret: UUID, commentBody: String, postId: Int, completion: @escaping (Result<Comment, Error>) -> Void) {
        guard let url = URL(string: "https://tech-social-media-app.fly.dev/createComment") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userSecret": userSecret.uuidString,
            "commentBody": commentBody,
            "postid": postId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let comment = try decoder.decode(Comment.self, from: data)
                completion(.success(comment))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
