//
//  AlertPresenter.swift
//  Tracker
//
//  Created by Егор Свистушкин on 24.09.2023.
//

import UIKit

final class AlertPresenter {
    
    weak var viewController: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.viewController = delegate
    }
    
    func show(result: AlertModel) {
        let alert = UIAlertController(title: result.title, message: result.message, preferredStyle: result.alertStyle)
        let action = UIAlertAction(title: result.buttonText, style: .destructive) {_ in
            result.completion()
        }
        let cancel = UIAlertAction(title: "Отменить", style: .cancel) { _ in
            
        }
        alert.addAction(action)
        alert.addAction(cancel)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
