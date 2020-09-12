//
//  SettingsCell.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 25.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit

protocol SettingsCellDelegate: class {
    func settingsCell(_ settingsCell: SettingsCell, textFieldEditingChanged value: String?)
}

final class SettingsCell: UITableViewCell {

    // MARK: Public

    var viewModel: CellViewModelProtocol! {
        didSet {
            if let viewModel = viewModel as? SettingsCellViewModelProtocol {
                textField.text = viewModel.text
                textField.placeholder = viewModel.placeholder
            }
        }
    }

    weak var delegate: SettingsCellDelegate?

    // MARK: Private

    private let textField = SettingsTextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)

        addSubview(textField)
        textField.fillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func handleTextChange() {
        delegate?.settingsCell(self, textFieldEditingChanged: textField.text)
    }

}
