//
//  CommentCell.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/8/24.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var parentStackView: UIStackView!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var commentBodyTextField: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        parentStackView.setRoundedCornersAndFrostedBackground()
    }

}
