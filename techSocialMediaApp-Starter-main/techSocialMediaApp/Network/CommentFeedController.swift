//
//  CommentFeeController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/10/24.
//

import Foundation

class CommentFeedController {
    
    func fetchComments(userSecret: UUID, postId: Int, pageNumber: Int, completion: @escaping (Result<[Comment], Error>) -> Void) {
        let urlString = "https://tech-social-media-app.fly.dev/comments"
        guard var urlComponents = URLComponents(string: urlString) else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "userSecret", value: userSecret.uuidString),
            URLQueryItem(name: "postid", value: "\(postId)"),
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let comments = try JSONDecoder().decode([Comment].self, from: data)
                completion(.success(comments))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
