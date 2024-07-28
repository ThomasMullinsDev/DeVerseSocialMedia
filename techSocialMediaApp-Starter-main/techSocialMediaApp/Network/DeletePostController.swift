//
//  deletePostController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/28/24.
//

import Foundation

class DeletePostController {
    
    func deletePost(userSecret: UUID, postId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://tech-social-media-app.fly.dev/post?userSecret=\(userSecret)&postid=\(postId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            if httpResponse.statusCode == 200 {
                completion(.success(()))
            } else if let data = data, let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] {
                let error = NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                completion(.failure(error))
            } else {
                let error = NSError(domain: "Unknown error", code: httpResponse.statusCode, userInfo: nil)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
