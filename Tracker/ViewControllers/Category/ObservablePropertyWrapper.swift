//
//  ObservablePropertyWrapper.swift
//  Tracker
//
//  Created by Егор Свистушкин on 04.09.2023.
//

import Foundation

@propertyWrapper
class Observable<Value> {
    
    // MARK: - Public Properties
    var wrappedValue: Value {
        didSet {
            onChange?(wrappedValue)
        }
    }
    
    var projectedValue: Observable<Value> {
        return self
    }
    
    // MARK: - Private Properties
    private var onChange: ((Value) -> Void)? = nil
    
    // MARK: - View Life Cycles
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    // MARK: - Public Methods
    func bind(action: @escaping (Value) -> Void) {
        self.onChange = action
    }
}
