//
//  AddPostViewController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 6/27/24.
//

import UIKit

class AddPostViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var submitPostBackgroundView: UIView!
    @IBOutlet weak var createPostBackgroundView: UIView!
    @IBOutlet weak var createPostTextView: UITextView!
    @IBOutlet weak var createPostTitleBackgroundView: UIView!
    @IBOutlet weak var createPostTitleTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    let newPostController = NewPostController()

    private var isTitleTextFieldTapped = false
    private var isBodyTextViewTapped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPostTitleTextField.delegate = self
        createPostTextView.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        GradientBackground.applyGradientBackground(to: view)
        createPostTextView.setRoundedCornersAndDynamicPlaceholder()
        createPostBackgroundView.setRoundedCornersAndFrostedBackground()
        submitPostBackgroundView.setRoundedCornersAndFrostedBackground()
        createPostTitleBackgroundView.setRoundedCornersAndFrostedBackground()
        createPostTitleTextField.setRoundedCornersAndDynamicPlaceholder(placeholderText: "")
        
        submitButton.addTarget(self, action: #selector(submitNewPostButton), for: .touchUpInside)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == createPostTitleTextField && !isTitleTextFieldTapped {
            textField.text = ""
            isTitleTextFieldTapped = true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == createPostTextView && !isBodyTextViewTapped {
            textView.text = ""
            isBodyTextViewTapped = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GradientBackground.applyGradientBackground(to: view)
    }

    @IBAction func submitNewPostButton(_ sender: Any) {
        guard let title = createPostTitleTextField.text, !title.isEmpty,
              let body = createPostTextView.text, !body.isEmpty else {
            showAlert(title: "Error", message: "Please enter both a title and body for the post.")
            return
        }
        
        newPostController.createPost(title: title, body: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    self.handlePostCreationSuccess(post: post)
                    self.createPostTextView.text = "What's Happening?"
                    self.createPostTitleTextField.text = "Title"
                case .failure(let error):
                    self.showAlert(title: "Error", message: "Failed to create post: \(error.localizedDescription)")
                }
            }
        }
        dismissKeyboard()
    }

    private func handlePostCreationSuccess(post: Post) {
        NotificationCenter.default.post(name: .profileDidUpdate, object: nil)
        showAlert(title: "Success", message: "Post created")
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
