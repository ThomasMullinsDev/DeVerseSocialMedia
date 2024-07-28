//
//  NewPostController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/27/24.
//

import Foundation

class NewPostController {
    
    func createPost(title: String, body: String, completion: @escaping (Result<Post, Error>) -> Void) {
        guard let userSecret = User.current?.secret else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        let url = URL(string: "https://tech-social-media-app.fly.dev/createPost")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let post = ["title": title, "body": body]
        let parameters = ["userSecret": userSecret.uuidString, "post": post] as [String : Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                let error = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unexpected response from server."])
                completion(.failure(error))
                return
            }
            
            do {
                let postResponse = try JSONDecoder().decode(Post.self, from: data)
                completion(.success(postResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
