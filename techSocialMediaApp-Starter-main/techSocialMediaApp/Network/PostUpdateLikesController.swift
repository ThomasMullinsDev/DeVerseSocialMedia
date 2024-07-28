//
//  postUpdateLikesController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/28/24.
//

import Foundation

class PostUpdateLikesController {
    
    func updateLikeStatus(userSecret: UUID, postId: Int, completion: @escaping (Result<Post, Error>) -> Void) {
        let url = URL(string: "https://tech-social-media-app.fly.dev/updateLikes")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["userSecret": userSecret.uuidString, "postid": postId]
        
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
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let updatedPost = try decoder.decode(Post.self, from: data)
                completion(.success(updatedPost))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
