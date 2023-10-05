//
//  Int+Extension.swift
//  Tracker
//
//  Created by Егор Свистушкин on 22.09.2023.
//

import Foundation

extension Int {
    func localizeNumbers(_ key: String) -> String {
        let localizedFormat = NSLocalizedString(key, tableName: nil, bundle: .main, comment: "")
        return String.localizedStringWithFormat(localizedFormat, self)
    }
}
