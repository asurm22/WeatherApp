//
//  ViusalEffects.swift
//  weather report
//
//  Created by alex surmava on 12.02.25.
//
import UIKit

func addGradientBackground(view: UIView) {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [UIColor.blue.cgColor, UIColor.gray.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    view.layer.insertSublayer(gradientLayer, at: 0)
}
    
func addBlurEffect(view: UIView) {
    let blurEffect = UIBlurEffect(style: .light)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = view.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.insertSubview(blurEffectView, belowSubview: view)
}
