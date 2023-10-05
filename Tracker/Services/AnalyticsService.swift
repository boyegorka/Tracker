//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Егор Свистушкин on 27.09.2023.
//

import Foundation
import YandexMobileMetrica

class AnalyticsService {
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "c7a41498-2287-49bb-ab8d-7333f134dc18") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, params: [AnyHashable : Any]?) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

//  c7a41498-2287-49bb-ab8d-7333f134dc18 --------- Metrika api
