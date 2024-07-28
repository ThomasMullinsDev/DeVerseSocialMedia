//
//  PostTableViewCell.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/3/24.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var currentNumberOfCommentsButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var currentNumberOfLikesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var postSettingsButton: UIButton!
    @IBOutlet weak var hoursSincePostLabel: UILabel!
    @IBOutlet weak var UsernameButton: UIButton!
}
