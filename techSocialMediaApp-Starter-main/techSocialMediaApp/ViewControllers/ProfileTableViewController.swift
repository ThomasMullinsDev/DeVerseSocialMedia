//
//  ProfileTableViewController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 6/28/24.
//

import UIKit

class ProfileTableViewController: UITableViewController, ProfilePostCellDelegate, EditProfilePostViewControllerDelegate, CommentsViewControllerDelegate {
    
    var profile: Profile? {
        didSet {
            tableView.reloadData()
        }
    }
    var userSecret: UUID = User.current?.secret ?? UUID()
    
    let profileController = ProfileController()
    let deletePostController = DeletePostController()
    let postUpdateLikesController = PostUpdateLikesController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GradientBackground.applyGradientBackground(to: view)
    }

    private func setupUI() {
        GradientBackground.applyGradientBackground(to: view)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(profileDidUpdate), name: .profileDidUpdate, object: nil)
    }
    
    func didUpdateComments() {
            fetchUserProfile()
        }
    
    @objc private func profileDidUpdate() {
        fetchUserProfile()
        tableView.reloadData()
    }


    private func fetchUserProfile() {
        Task {
            do {
                let success = try await profileController.fetchProfile(userUUID: User.current?.userUUID, userSecret: User.current?.secret)
                if success {
                    profile = Profile.current
                    tableView.reloadData()
                } else {
                    showAlert(message: "Failed to fetch profile.")
                }
            } catch {
                showAlert(message: "Error fetching profile: \(error.localizedDescription)")
            }
        }
    }

    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let profile = profile else { return 0 }
        return section == 0 ? 1 : profile.posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let profile = profile else { fatalError() }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            configureProfileCell(cell, with: profile)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePostCell", for: indexPath) as! ProfilePostCell
            let post = profile.posts[indexPath.row]
            configureProfilePostCell(cell, with: post)
            return cell
        }
    }

    private func configureProfileCell(_ cell: ProfileCell, with profile: Profile) {
        cell.profileUsernameLabel.text = "@\(profile.userName)"
        cell.firstAndLastNameLabel.text = "\(profile.firstName) \(profile.lastName)"
        cell.bioTextField.text = profile.bio
        cell.techInterestsTextField.text = profile.techInterests
    }

    private func configureProfilePostCell(_ cell: ProfilePostCell, with post: Post) {
        cell.postTitleLabel.text = " \(post.title)"
        cell.usernameButton.setTitle("@\(post.authorUserName)", for: .normal)
        cell.postBodyTextField.text = post.body
        cell.numberOfLikesLabel.text = "\(post.likes)"
        cell.numberOfCommentsLabel.text = "\(post.numComments)"
        cell.datePostedLabel.text = post.createdDate
        cell.updateLikeButton(isLiked: post.userLiked)
        cell.delegate = self
        cell.commentButtonAction = { [weak self] in
            self?.didPressCommentButton(on: cell)
        }
    }

    func didPressLikeButton(on cell: ProfilePostCell) {
        guard let indexPath = tableView.indexPath(for: cell), let post = profile?.posts[indexPath.row] else { return }
        
        postUpdateLikesController.updateLikeStatus(userSecret: userSecret, postId: post.postid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedPost):
                    self?.profile?.posts[indexPath.row] = updatedPost
                    cell.numberOfLikesLabel.text = "\(updatedPost.likes)"
                    cell.updateLikeButton(isLiked: updatedPost.userLiked)
                    
                case .failure(let error):
                    print("Failed to update like status: \(error.localizedDescription)")
                }
            }
        }
    }

    func didPressPostSettingsButton(on cell: ProfilePostCell, from sender: UIView) {
        presentPostSettings(for: cell, from: sender)
    }
    
    func didPressCommentButton(on cell: ProfilePostCell) {
        guard let indexPath = tableView.indexPath(for: cell), let postId = profile?.posts[indexPath.row].postid else { return }
        showCommentsViewController(for: postId)
    }
    
    private func showCommentsViewController(for postId: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let commentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsViewController") as? CommentsViewController else { return }
        commentsVC.delegate = self
        commentsVC.postId = postId
        commentsVC.modalPresentationStyle = .pageSheet
        present(commentsVC, animated: true, completion: nil)
    }

    private func presentPostSettings(for cell: ProfilePostCell, from sender: UIView) {
        let alertController = UIAlertController(title: "Choose an Option", message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            self.presentEditPost(for: cell)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deletePost(for: cell)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true)
    }

    private func presentEditPost(for cell: ProfilePostCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Adjust if needed
        guard let editPostViewController = storyboard.instantiateViewController(withIdentifier: "EditProfilePostViewController") as? EditProfilePostViewController else { return }
        
        if let indexPath = tableView.indexPath(for: cell) {
            editPostViewController.post = profile?.posts[indexPath.row]
        }
        
        editPostViewController.delegate = self
        editPostViewController.modalPresentationStyle = .pageSheet
        present(editPostViewController, animated: true)
    }

    private func deletePost(for cell: ProfilePostCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let postId = profile?.posts[indexPath.row].postid,
              let userSecret = User.current?.secret else {
            print("Could not retrieve necessary information for deletion.")
            return
        }

        deletePostController.deletePost(userSecret: userSecret, postId: postId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.profile?.posts.remove(at: indexPath.row)
                    self.tableView.reloadData()
                case .failure(let error):
                    self.showAlert(message: "Failed to delete post: \(error.localizedDescription)")
                }
            }
        }
    }

    func didUpdatePost(_ updatedPost: Post) {
        if let index = profile?.posts.firstIndex(where: { $0.postid == updatedPost.postid }) {
            profile?.posts[index] = updatedPost
            tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath?) -> IndexPath? {
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .profileDidUpdate, object: nil)
    }
}
