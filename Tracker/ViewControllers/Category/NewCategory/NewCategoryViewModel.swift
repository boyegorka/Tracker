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

protocol NewCategoryViewModelProtocol {
    var categoryName: String? { get set }
    func createNewCategory() throws
    func bindIsValidForm(execute: @escaping (Bool) -> ())
}

final class NewCategoryViewModel: NewCategoryViewModelProtocol {
    
    // MARK: - Public Properties
    private weak var delegate: NewCategoryDelegate?
    var categoryName: String? {
        didSet {
            isValidForm = !(categoryName?.isEmpty ?? true)
        }
    }
    
    // MARK: - Private Properties
    private let service = TrackerService()
    @Observable private(set) var isValidForm: Bool = false
    
    // MARK: - View Life Cycles
    init(delegate: NewCategoryDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Public Methods
    func createNewCategory() throws {
        guard let categoryName else { return }
        try service.addNewCategory(name: categoryName)
        delegate?.didCreateCategory()
    }
    
    func bindIsValidForm(execute: @escaping (Bool) -> ()) {
        $isValidForm.bind { execute($0) }
    }
}
