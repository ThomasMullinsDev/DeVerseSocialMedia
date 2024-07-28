//
//  CommentsViewController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/8/24.
//

protocol CommentsViewControllerDelegate: AnyObject {
    func didUpdateComments()
}

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var comments: [Comment] = []
    var postId: Int = 0
    var userSecret: UUID = User.current?.secret ?? UUID()
    var currentPage: Int = 0
    var isFetching: Bool = false
    private let threshold: CGFloat = 200.0
    
    let commentFeedController = CommentFeedController()
    
    weak var delegate: CommentsViewControllerDelegate?
    
    @IBOutlet weak var commentTextFieldBackgroundView: UIView!
    @IBOutlet weak var submitCommentBackgroundView: UIView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GradientBackground.applyGradientBackground(to: view)
        submitCommentBackgroundView.setRoundedCornersAndFrostedBackground()
        commentTextField.setRoundedCornersAndDynamicPlaceholder(placeholderText: "New Comment")
        commentTextFieldBackgroundView.setRoundedCornersAndFrostedBackground()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        print("\(postId)")
        fetchComments()
    }
    
    private func fetchComments() {
        guard !isFetching else { return }
        isFetching = true
        
        commentFeedController.fetchComments(userSecret: userSecret, postId: postId, pageNumber: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetching = false
                
                switch result {
                case .success(let newComments):
                    self?.comments.append(contentsOf: newComments)
                    self?.tableView.reloadData()
                    self?.currentPage += 1
                case .failure(let error):
                    print("Failed to fetch comments: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func newCommentTextEditingDidBegin(_ sender: Any) {
        setupKeyboardHiding()
    }
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
        let currentTextField = commentTextField else { return }
        
        let keyboardHeight = keyboardFrame.height
        let textFieldBottomY = currentTextField.frame.origin.y + currentTextField.frame.size.height
        let textFieldBottomInView = self.view.convert(CGPoint(x: 0, y: textFieldBottomY), from: currentTextField.superview).y
        let spaceAboveKeyboard = self.view.frame.height - keyboardHeight
        
        if textFieldBottomInView > spaceAboveKeyboard {
            let offsetY = textFieldBottomInView - spaceAboveKeyboard + 50
            self.view.frame.origin.y = -offsetY
        } else {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        view.frame.origin.y = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GradientBackground.applyGradientBackground(to: view)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        cell.dateCreatedLabel.text = comment.createdDate
        cell.commentBodyTextField.text = comment.body
        cell.usernameLabel.text = "@\(comment.userName)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    @IBAction func submitCommentButtonPressed(_ sender: Any) {
        guard let commentBody = commentTextField.text, !commentBody.isEmpty else {
            return
        }
        
        dismissKeyboard()
        
        let createCommentController = CreateNewCommentController()
        createCommentController.createComment(userSecret: userSecret, commentBody: commentBody, postId: postId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newComment):
                    self?.comments.append(newComment)
                    self?.tableView.reloadData()
                    self?.commentTextField.text = ""
                    
                    self?.delegate?.didUpdateComments()
                    
                case .failure(let error):
                    print("Failed to create comment: \(error.localizedDescription)")
                }
            }
        }
    }

    
    private func loadMoreComments() {
        guard !isFetching else { return }
        isFetching = true
        
        commentFeedController.fetchComments(userSecret: userSecret, postId: postId, pageNumber: currentPage + 1) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetching = false
                
                switch result {
                case .success(let newComments):
                    if newComments.isEmpty {
                        return
                    }
                    self?.comments.append(contentsOf: newComments)
                    self?.tableView.reloadData()
                    self?.currentPage += 1
                case .failure(let error):
                    print("Failed to fetch comments: \(error.localizedDescription)")
                }
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let contentOffsetY = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.bounds.height
        
        if contentOffsetY + scrollViewHeight > contentHeight - threshold {
            loadMoreComments()
        }
    }
}

