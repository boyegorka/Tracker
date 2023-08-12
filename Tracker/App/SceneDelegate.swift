//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Егор Свистушкин on 25.05.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Public Properties
    var window: UIWindow?
    
    // MARK: - Public Methods
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let viewController = TabBarController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}
