//
//  UIViewController+Extension.swift
//  Tracker
//
//  Created by Егор Свистушкин on 10.07.2023.
//

import UIKit

extension UIViewController {
    
    // MARK: - Public Methods
    func hideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Private Methods
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}
