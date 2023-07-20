//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Егор Свистушкин on 17.06.2023.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    private lazy var emptyScreenImage: UIImageView = {
        let emptyScreenImage = UIImageView()
        view.addSubview(emptyScreenImage)
        emptyScreenImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        return emptyScreenImage
    }()
    
    private lazy var emptyScreenText: UILabel = {
        let emptyScreenText = UILabel()
        view.addSubview(emptyScreenText)
        emptyScreenText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyScreenText.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8),
            emptyScreenText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        emptyScreenText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return emptyScreenText
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatisticsScreen()
    }
    
    private func setupStatisticsScreen() {
        emptyScreenImage.image = UIImage(named: "EmptyScreenSmileCrying")
        emptyScreenText.text = "Анализировать пока нечего"
        view.backgroundColor = .ypWhite
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            
            navigationBar.topItem?.title = "Статистика"
            navigationBar.prefersLargeTitles = true
            navigationBar.topItem?.largeTitleDisplayMode = .always
            
        }
    }
}
