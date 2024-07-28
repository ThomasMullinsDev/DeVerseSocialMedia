//
//  EditProfilePostViewController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/15/24.
//

import UIKit

protocol EditProfilePostViewControllerDelegate: AnyObject {
    func didUpdatePost(_ updatedPost: Post)
}

class EditProfilePostViewController: UIViewController {
    
    var post: Post?
    var userSecret: UUID = User.current?.secret ?? UUID()
    weak var delegate: EditProfilePostViewControllerDelegate?

    @IBOutlet weak var editPostTitleBackgroundView: UIView!
    @IBOutlet weak var editPostTitleTextField: UITextField!
    @IBOutlet weak var submitButtonBackgroundView: UIView!
    @IBOutlet weak var editPostTextBackgroundView: UIView!
    @IBOutlet weak var editPostTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        GradientBackground.applyGradientBackground(to: view)
        editPostTextView.setRoundedCornersAndDynamicPlaceholder()
        editPostTextBackgroundView.setRoundedCornersAndFrostedBackground()
        submitButtonBackgroundView.setRoundedCornersAndFrostedBackground()
        editPostTitleTextField.setRoundedCornersAndDynamicPlaceholder(placeholderText: "")
        editPostTitleBackgroundView.setRoundedCornersAndFrostedBackground()
        
        if let post = post {
            editPostTextView.text = post.body
            editPostTitleTextField.text = post.title
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GradientBackground.applyGradientBackground(to: view)
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let post = post,
              let title = editPostTitleTextField.text,
              let body = editPostTextView.text else { return }

        EditPostController.editPost(userSecret: userSecret, postid: post.postid, title: title, body: body) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    let updatedPost = Post(
                        postid: post.postid,
                        title: title,
                        body: body,
                        authorUserName: post.authorUserName,
                        authorUserId: post.authorUserId,
                        likes: post.likes,
                        userLiked: post.userLiked,
                        numComments: post.numComments,
                        createdDate: post.createdDate
                    )
                    self?.delegate?.didUpdatePost(updatedPost)
                    
                    self?.dismiss(animated: true, completion: nil)
                    
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
