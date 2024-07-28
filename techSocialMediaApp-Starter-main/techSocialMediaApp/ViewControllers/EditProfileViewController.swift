//
//  EditProfileViewController.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 6/27/24.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    var profile: Profile?
    
    let profileController = ProfileController()

    @IBOutlet weak var interestsBackgroundView: UIView!
    @IBOutlet weak var bioBackgroundView: UIView!
    @IBOutlet weak var nameBackgroundView: UIView!
    @IBOutlet weak var usernameBackgroundView: UIView!
    @IBOutlet weak var submitButtonBackgroundView: UIView!
    @IBOutlet weak var interestsTextView: UITextView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        GradientBackground.applyGradientBackground(to: view)
        usernameTextField.setRoundedCornersAndDynamicPlaceholder(placeholderText: "")
        nameTextField.setRoundedCornersAndDynamicPlaceholder(placeholderText: "")
        bioTextView.setRoundedCornersAndDynamicPlaceholder()
        interestsTextView.setRoundedCornersAndDynamicPlaceholder()
        submitButtonBackgroundView.setRoundedCornersAndFrostedBackground()
        interestsBackgroundView.setRoundedCornersAndFrostedBackground()
        bioBackgroundView.setRoundedCornersAndFrostedBackground()
        nameBackgroundView.setRoundedCornersAndFrostedBackground()
        usernameBackgroundView.setRoundedCornersAndFrostedBackground()
        fetchUserProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GradientBackground.applyGradientBackground(to: view)
    }
    
    private func fetchUserProfile() {
        Task {
            do {
                let success = try await profileController.fetchProfile(userUUID: User.current?.userUUID, userSecret: User.current?.secret)
                if success {
                    profile = Profile.current
                    nameTextField.text = "\(profile?.firstName ?? "Enter Full Name") \(profile?.lastName ?? "")"
                    usernameTextField.text = profile?.userName
                    bioTextView.text = profile?.bio
                    interestsTextView.text = profile?.techInterests
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
    
    @IBAction func submitProfileButtonPressed(_ sender: Any) {
        Task {
            do {
                guard var currentProfile = profile else {
                    showAlert(message: "Profile data is missing.")
                    return
                }
                
                currentProfile.userName = usernameTextField.text ?? ""
                currentProfile.bio = bioTextView.text
                currentProfile.techInterests = interestsTextView.text
                
                let success = try await profileController.updateProfile(userSecret: User.current?.secret, profile: currentProfile)
                
                if success {
                    showAlert(message: "Profile updated successfully.")
                } else {
                    showAlert(message: "Failed to update profile.")
                }
            } catch {
                showAlert(message: "Error updating profile: \(error.localizedDescription)")
            }
        }
        NotificationCenter.default.post(name: .profileDidUpdate, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            NotificationCenter.default.post(name: .profileDidUpdate, object: nil)
    }
}

extension Notification.Name {
    static let profileDidUpdate = Notification.Name("profileDidUpdate")
}
