//
//  ErrorView.swift
//  weather report
//
//  Created by alex surmava on 15.02.25.
//
import UIKit

class ErrorView: UIView {

    private let errorStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 15
        stack.backgroundColor = .clear
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let errorContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let warningImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cloud.fill")
        imageView.tintColor = UIColor.systemBlue.withAlphaComponent(0.6)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let warningIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "Error occurred while loading data."
        return label
    }()
    
    private let errorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reload", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    var onReload: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupErrorStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupErrorStack() {
        self.addSubview(errorStack)
        errorStack.addArrangedSubview(errorContainerView)
        errorStack.addArrangedSubview(errorLabel)
        errorStack.addArrangedSubview(errorButton)
        errorStack.setCustomSpacing(50, after: errorContainerView)
        
        errorContainerView.addSubview(warningImageView)
        errorContainerView.addSubview(warningIconView)
        
        NSLayoutConstraint.activate([
            errorStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            errorStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            errorButton.heightAnchor.constraint(equalToConstant: 50),
            errorButton.widthAnchor.constraint(equalToConstant: 100),
            
            warningImageView.centerXAnchor.constraint(equalTo: errorContainerView.centerXAnchor),
            warningImageView.centerYAnchor.constraint(equalTo: errorContainerView.centerYAnchor),
            warningImageView.widthAnchor.constraint(equalToConstant: 80),
            warningImageView.heightAnchor.constraint(equalToConstant: 80),
            
            warningIconView.centerXAnchor.constraint(equalTo: warningImageView.centerXAnchor),
            warningIconView.centerYAnchor.constraint(equalTo: warningImageView.centerYAnchor, constant: 20),
            warningIconView.widthAnchor.constraint(equalToConstant: 30),
            warningIconView.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        errorButton.addTarget(self, action: #selector(handleReload), for: .touchUpInside)
    }

    @objc private func handleReload() {
        removeFromSuperview()
        onReload?()
    }
}

