//
//  ProfileCell.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/8/24.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var parentStackView: UIStackView!
    @IBOutlet weak var techInterestsTextField: UITextView!
    @IBOutlet weak var bioTextField: UITextView!
    @IBOutlet weak var firstAndLastNameLabel: UILabel!
    @IBOutlet weak var profileUsernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
