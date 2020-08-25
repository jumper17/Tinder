//
//  HomeBottomControlsStackView.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 17.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {

    static func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }

    let refreshButton = createButton(image: #imageLiteral(resourceName: "refresh_circle"))
    let dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"))
    let superLikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"))
    let likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"))
    let specialButton = createButton(image: #imageLiteral(resourceName: "boost_circle"))


    override init(frame: CGRect) {
        super.init(frame: frame)

        distribution = .fillEqually

        heightAnchor.constraint(equalToConstant: 100).isActive = true
        [refreshButton, dislikeButton, superLikeButton, likeButton, specialButton].forEach { (button) in
            addArrangedSubview(button)
        }

    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
