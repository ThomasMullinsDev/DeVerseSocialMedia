//
//  Profile.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/8/24.
//

import Foundation

struct Profile: Codable {
    var firstName: String
    var lastName: String
    var userName: String
    var userUUID: UUID
    var bio: String?
    var techInterests: String?
    var posts: [Post]
    
    static var current: Profile?
}
