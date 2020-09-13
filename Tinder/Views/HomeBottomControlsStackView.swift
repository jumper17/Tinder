//
//  HomeBottomControlsStackView.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 17.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit

protocol HomeBottomControlsStackViewDelegate: class {
    func homeBottomControlsStackViewRefreshButtonDidTap(_ stackView: HomeBottomControlsStackView)
}

class HomeBottomControlsStackView: UIStackView {

    private static func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }

    weak var delegate: HomeBottomControlsStackViewDelegate?

    private let refreshButton = createButton(image: #imageLiteral(resourceName: "refresh_circle"))
    private let dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"))
    private let superLikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"))
    private let likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"))
    private let specialButton = createButton(image: #imageLiteral(resourceName: "boost_circle"))


    override init(frame: CGRect) {
        super.init(frame: frame)

        distribution = .fillEqually

        heightAnchor.constraint(equalToConstant: 100).isActive = true
        [refreshButton, dislikeButton, superLikeButton, likeButton, specialButton].forEach { button in
            addArrangedSubview(button)
        }
        refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)

    }

    @objc fileprivate func handleRefresh() {
        delegate?.homeBottomControlsStackViewRefreshButtonDidTap(self)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
