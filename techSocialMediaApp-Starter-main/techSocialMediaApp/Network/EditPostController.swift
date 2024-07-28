//
//  EditPostController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/28/24.
//

import Foundation

class EditPostController {
    
    static func editPost(userSecret: UUID, postid: Int, title: String, body: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://tech-social-media-app.fly.dev/editPost")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let postParameters: [String: Any] = [
            "userSecret": userSecret.uuidString,
            "post": [
                "postid": postid,
                "title": title,
                "body": body
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postParameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response"])
                completion(.failure(error))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "Server error \(httpResponse.statusCode)"])
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No data received"])
                completion(.failure(error))
                return
            }
            
            do {
                if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let message = responseDict["message"] {
                    completion(.success(message))
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response data"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
