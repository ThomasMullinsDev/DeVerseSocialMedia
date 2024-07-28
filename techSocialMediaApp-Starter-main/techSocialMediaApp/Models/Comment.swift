//
//  Comment.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/8/24.
//

import Foundation

struct Comment: Codable {
    let commentId: Int
    let body: String
    let userName: String
    let userId: String
    let createdDate: String
}



