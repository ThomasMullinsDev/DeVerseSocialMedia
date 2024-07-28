//
//  Post.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/3/24.
//

import Foundation

struct Post: Codable {
    var postid: Int
    var title: String
    var body: String
    var authorUserName: String
    var authorUserId: String
    var likes: Int
    var userLiked: Bool
    var numComments: Int
    var createdDate: String
    
    mutating func toggleLike() {
        userLiked.toggle()
        likes += userLiked ? 1 : -1
    }
}
