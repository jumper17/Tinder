//
//  SettingsCellViewModel.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 12.09.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import Foundation

protocol CellViewModelProtocol {}

protocol SettingsCellViewModelProtocol: CellViewModelProtocol {
    var placeholder: String { get }
    var text: String? { get }
}

class SettingsCellViewModel: SettingsCellViewModelProtocol {

    private let textCell: String?
    private let placeholderCell: String

    init(textCell: String?, placeholderCell: String) {
        self.textCell = textCell
        self.placeholderCell = placeholderCell
    }

    var placeholder: String {
        return placeholderCell
    }

    var text: String? {
        return textCell
    }


}
