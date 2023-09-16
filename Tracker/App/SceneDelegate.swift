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
    let userDefaults = UserDefaults.standard
    
    private let mainViewController = TabBarController()
    private let onboardingViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    // MARK: - Public Methods
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        
        let hasSeenOnboarding = userDefaults.bool(forKey: "HasSeenOnboarding")
        
        if !hasSeenOnboarding {
            window?.rootViewController = onboardingViewController
            userDefaults.set(true, forKey: "HasSeenOnboarding")
        } else {
            window?.rootViewController = mainViewController
        }
        
        window?.makeKeyAndVisible()
    }
    
}
