//
//  AlertModel.swift
//  Tracker
//
//  Created by Егор Свистушкин on 24.09.2023.
//

import UIKit

struct AlertModel {
    var alertStyle: UIAlertController.Style
    var title: String
    var message: String?
    var buttonText: String
    
    var completion: (() -> Void)
}
