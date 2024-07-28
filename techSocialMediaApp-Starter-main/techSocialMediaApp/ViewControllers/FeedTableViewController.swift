//
//  FeedTableViewController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 6/27/24.
//

import UIKit

class FeedTableViewController: UITableViewController, PostCellDelegate, CommentsViewControllerDelegate {
    
    var posts: [Post] = []
    let postFeedController = PostFeedController()
    let postUpdateLikesController = PostUpdateLikesController()
    var userSecret: UUID = User.current?.secret ?? UUID()
    var currentPage: Int = 0
    var isFetching: Bool = false
    private let threshold: CGFloat = 200.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GradientBackground.applyGradientBackground(to: view)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.isUserInteractionEnabled = false
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GradientBackground.applyGradientBackground(to: view)
    }
    
    func didUpdateComments() {
            fetchPosts(page: currentPage)
        }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return posts.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeVerseCell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            let post = posts[indexPath.row]
            cell.postTitleLabel.text = " \(post.title)"
            cell.usernameButton.setTitle("@\(post.authorUserName)", for: .normal)
            cell.postBodyTextField.text = post.body
            cell.numberOfLikesLabel.text = "\(post.likes)"
            cell.numberOfCommentsLabel.text = "\(post.numComments)"
            cell.datePostedLabel.text = post.createdDate
            cell.updateLikeButton(isLiked: post.userLiked)
            cell.delegate = self
            cell.commentButtonAction = { [weak self] in
                            guard let self = self else { return }
                            self.showCommentsViewController(for: post.postid)
                        }
            return cell
        }
    }
    
    private func showCommentsViewController(for postId: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let commentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsViewController") as? CommentsViewController {
            commentsVC.postId = postId
            commentsVC.delegate = self
            commentsVC.modalPresentationStyle = .pageSheet
            present(commentsVC, animated: true, completion: nil)
        }
    }
    
    func didPressLikeButton(on cell: PostCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let post = posts[indexPath.row]

        postUpdateLikesController.updateLikeStatus(userSecret: userSecret, postId: post.postid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedPost):
                    self?.posts[indexPath.row] = updatedPost
                    cell.numberOfLikesLabel.text = "\(updatedPost.likes)"
                    cell.updateLikeButton(isLiked: updatedPost.userLiked)
                    
                case .failure(let error):
                    print("Failed to update like status: \(error.localizedDescription)")
                }
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath?) -> IndexPath? {
        return nil
    }
    
    private func fetchPosts(page: Int = 0) {
        guard !isFetching else { return }
        isFetching = true
        
        Task {
            do {
                let fetchedPosts = try await postFeedController.fetchPosts(userSecret: userSecret, pageNumber: page)
                if page == 0 {
                    posts = fetchedPosts
                } else {
                    posts.append(contentsOf: fetchedPosts)
                }
                currentPage = page
                tableView.reloadData()
            } catch {
                print("Failed to fetch posts: \(error.localizedDescription)")
            }
            isFetching = false
        }
    }
    
    func loadMorePosts() {
        fetchPosts(page: currentPage + 1)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let contentOffsetY = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.bounds.height
        
        if contentOffsetY + scrollViewHeight > contentHeight - threshold {
            loadMorePosts()
        }
    }
}
