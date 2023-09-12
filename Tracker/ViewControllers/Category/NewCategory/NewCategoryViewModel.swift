//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Егор Свистушкин on 07.09.2023.
//

import Foundation

protocol NewCategoryDelegate: AnyObject  {
    func didCreateCategory()
}

final class NewCategoryViewModel {
    
    // MARK: - Public Properties
    var delegate: NewCategoryDelegate?
    var categoryName: String? {
        didSet {
            isValidForm = !(categoryName?.isEmpty ?? true)
        }
    }
    
    // MARK: - Private Properties
    private let service = TrackerService()
    @Observable private(set) var isValidForm: Bool = false
    
    // MARK: - Public Methods
    func createNewCategory() throws {
        guard let categoryName else { return }
        try service.addNewCategory(name: categoryName)
        delegate?.didCreateCategory()
    }
}
