//
//  ViewModifiers.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/1/24.
//

import UIKit

extension UITextField {
    func setRoundedCornersAndDynamicPlaceholder(placeholderText: String) {
        let placeholderColor: UIColor
        if self.traitCollection.userInterfaceStyle == .dark {
            placeholderColor = .white
        } else {
            placeholderColor = .black
        }
        
        self.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        self.borderStyle = .none
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}


extension UITextView {
    func setRoundedCornersAndDynamicPlaceholder() {
        let placeholderColor: UIColor
        if self.traitCollection.userInterfaceStyle == .dark {
            placeholderColor = .white
        } else {
            placeholderColor = .black
        }

        self.textColor = placeholderColor
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0
    }
}

extension UIView {
    func setRoundedCornersAndFrostedBackground() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.layer.cornerRadius = 10
        blurEffectView.clipsToBounds = true
        blurEffectView.alpha = 0.5

        insertSubview(blurEffectView, at: 0)

        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
