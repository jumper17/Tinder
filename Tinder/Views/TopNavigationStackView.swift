//
//  TopNavigationStackView.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 17.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit

protocol TopNavigationStackViewDelegate: class {
    func topNavigationStackViewSettingsButtonDidTap(_ stackView: TopNavigationStackView)
}

class TopNavigationStackView: UIStackView {

    private let settingsButton = UIButton(type: .system)
    private let messageButton = UIButton(type: .system)
    private let fireImageView = UIImageView(image: #imageLiteral(resourceName: "app_icon"))
    weak var delegate: TopNavigationStackViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        fireImageView.contentMode = .scaleAspectFit

        settingsButton.setImage(#imageLiteral(resourceName: "top_left_profile").withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.setImage(#imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysOriginal), for: .normal)

        [settingsButton, UIView(), fireImageView, UIView(), messageButton].forEach { (v) in
            addArrangedSubview(v)
        }
        settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        distribution = .equalCentering

        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
    }

    required init(coder: NSCoder) {
        fatalError()
    }

    @objc func handleSettings() {
        delegate?.topNavigationStackViewSettingsButtonDidTap(self)
    }
}
