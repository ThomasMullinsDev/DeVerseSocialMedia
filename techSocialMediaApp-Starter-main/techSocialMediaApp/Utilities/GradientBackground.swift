//
//  BackgroundChanger.swift
//  techSocialMediaApp
//
//  Created by Thomas Mullins on 7/1/24.
//

import UIKit

class GradientBackground {
    static func applyGradientBackground(to view: UIView) {
        if let sublayers = view.layer.sublayers {
            for layer in sublayers where layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        let isDarkMode = view.traitCollection.userInterfaceStyle == .dark
        
        gradientLayer.colors = isDarkMode ? [
            UIColor(red: 30/255, green: 0/255, blue: 60/255, alpha: 1).cgColor,
            UIColor(red: 0/255, green: 0/255, blue: 60/255, alpha: 1).cgColor
        ] : [
            UIColor(red: 210/255, green: 160/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 160/255, green: 200/255, blue: 255/255, alpha: 1).cgColor
        ]
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
