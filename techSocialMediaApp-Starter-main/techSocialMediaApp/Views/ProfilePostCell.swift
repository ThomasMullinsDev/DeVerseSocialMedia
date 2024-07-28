//
//  ProfilePostTableViewCell.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/8/24.
//

import UIKit

protocol ProfilePostCellDelegate: AnyObject {
    func didPressLikeButton(on cell: ProfilePostCell)
    func didPressPostSettingsButton(on cell: ProfilePostCell, from sender: UIView)
    func didPressCommentButton(on cell: ProfilePostCell)
}


class ProfilePostCell: UITableViewCell {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postBodyTextField: UITextView!
    @IBOutlet weak var datePostedLabel: UILabel!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var parentStackView: UIStackView!
    
    weak var delegate: ProfilePostCellDelegate?
    
    var commentButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        parentStackView.setRoundedCornersAndFrostedBackground()
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
            delegate?.didPressLikeButton(on: self)
        }
    
    @IBAction func postSettingsButtonPressed(_ sender: Any) {
        delegate?.didPressPostSettingsButton(on: self, from: sender as! UIView)
    }
    
    func updateLikeButton(isLiked: Bool) {
            let symbolName = isLiked ? "heart.fill" : "heart"
            let color: UIColor = isLiked ? .red : .label
            let image = UIImage(systemName: symbolName)?.withRenderingMode(.alwaysTemplate)
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = color
        }
    
    @IBAction func CommentButtonTapped(_ sender: Any) {
        commentButtonAction?()
    }
}
