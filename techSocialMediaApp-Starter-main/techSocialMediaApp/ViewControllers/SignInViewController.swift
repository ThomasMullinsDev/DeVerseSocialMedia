//
//  ViewController.swift
//  techSocialMediaApp
//
//  Created by Brayden Lemke on 10/20/22.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var signInButtonBackgroundView: UIView!
    @IBOutlet weak var emailBackgroundView: UIView!
    @IBOutlet weak var passwordBackgroundView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    var authenticationController = AuthenticationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        GradientBackground.applyGradientBackground(to: view)
        emailBackgroundView.setRoundedCornersAndFrostedBackground()
        passwordBackgroundView.setRoundedCornersAndFrostedBackground()
        passwordTextField.isSecureTextEntry = true
        emailTextField.setRoundedCornersAndDynamicPlaceholder(placeholderText: "Email")
        passwordTextField.setRoundedCornersAndDynamicPlaceholder(placeholderText: "Password")
        signInButtonBackgroundView.setRoundedCornersAndFrostedBackground()
        
        emailTextField.text = "thomas.mullins1029@stu.mtec.edu"
        passwordTextField.text = "juppys-byrxeS-3mekxo"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GradientBackground.applyGradientBackground(to: view)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
                let password = passwordTextField.text, !password.isEmpty else {return}

        Task {
            do {
                let success = try await authenticationController.signIn(email: email, password: password)
                if(success) {
                    let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "userSignedIn")
                    let viewControllers = [viewController]
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                }
            } catch {
                print(error)
                dismissKeyboard()
                errorLabel.text = "Invalid Username or Password"
            }
        }
    }
}




