//
//  AddCityPopup.swift
//  weather report
//
//  Created by alex surmava on 13.02.25.
//
import UIKit

class AddCityPopup: UIView {
    
    var onAddCity: ((String) -> Void)?

    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add City"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter City name you wish to add"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "City name"
        textField.textAlignment = .center
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .white
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let warningView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter a city name!"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addButton.addTarget(self, action: #selector(addCityTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(blurEffectView)
        blurEffectView.frame = bounds

        addSubview(containerView)
        addSubview(warningView)
        
        [titleLabel, instructionLabel, textField, addButton, loadingIndicator].forEach {
            containerView.addSubview($0)
        }
        
        warningView.addSubview(warningLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        warningView.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            instructionLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 10),
            textField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textField.widthAnchor.constraint(equalToConstant: 200),
            textField.heightAnchor.constraint(equalToConstant: 35),
            
            addButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 15),
            addButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 40),
            addButton.heightAnchor.constraint(equalToConstant: 40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            
            warningView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            warningView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            warningView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 20),
            warningView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -20),
            
            warningLabel.topAnchor.constraint(equalTo: warningView.topAnchor, constant: 10),
            warningLabel.bottomAnchor.constraint(equalTo: warningView.bottomAnchor, constant: -10),
            warningLabel.leadingAnchor.constraint(equalTo: warningView.leadingAnchor, constant: 10),
            warningLabel.trailingAnchor.constraint(equalTo: warningView.trailingAnchor, constant: -10),
        ])
    }
    
    @objc
    private func addCityTapped() {
        guard let city = textField.text, !city.isEmpty else {
            showWarning(message: "Please enter a city name!")
            return
        }
        hideWarning()
        startLoading()
        onAddCity?(city)
    }
    
    func startLoading() {
        addButton.isHidden = true
        loadingIndicator.startAnimating()
    }
    
    func stopLoading() {
        addButton.isHidden = false
        loadingIndicator.stopAnimating()
    }
    
    func dismiss() {
        removeFromSuperview()
    }
    
    @objc
    private func dismissTapped() {
        dismiss()
    }
    
    func showWarning(message: String) {
        warningLabel.text = message
        
        warningView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.warningView.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.hideWarning()
            }
        }
    }
    
    func hideWarning() {
        UIView.animate(withDuration: 0.3) {
            self.warningView.alpha = 0
        }
    }
}
