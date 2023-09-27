//
//  OnboardingPage.swift
//  Tracker
//
//  Created by Егор Свистушкин on 25.08.2023.
//

import UIKit

class OnboardingPage: UIViewController {
    
    // MARK: - Private Properties
    private var text: String {
        get { textLabel.text ?? "" }
        set { textLabel.text = newValue }
    }
    
    private var image: UIImage {
        get { backgroundImage.image ?? UIImage() }
        set { backgroundImage.image = newValue }
    }
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.overrideUserInterfaceStyle = .light
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backgroundImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.overrideUserInterfaceStyle = .light
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypBlack
        button.setTitle("onboarding.button".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View Life Cycles
    init(text: String, image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.text = text
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        addContstraints()
    }
    
    // MARK: - Private Methods
    private func addSubviews() {
        view.addSubview(backgroundImage)
        view.addSubview(textLabel)
        view.addSubview(button)
    }
    
    private func addContstraints() {
        NSLayoutConstraint.activate([
            
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 70)
            
        ])
    }
    
    @objc
    private func buttonAction() {
        let vc = TabBarController()
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        
        self.present(vc, animated: true)
    }
}
