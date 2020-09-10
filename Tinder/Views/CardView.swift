//
//  CardView.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 17.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit
import SDWebImage

class CardView: UIView {

    var cardViewModel: CardViewModel! {
        didSet {
            if let imageName = cardViewModel.imageNames.first,
                let url = URL(string: imageName) {
                imageView.sd_setImage(with: url)
            }

            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAligment

            setBarsStackViewItems()
            setupImageIndexObserver()
        }
    }

    fileprivate let imageView = UIImageView()
    fileprivate let informationLabel = UILabel()
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let threshold: CGFloat = 80
    fileprivate let barDeselectionColor = UIColor(white: 0, alpha: 0.1)
    fileprivate let barsStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.frame
    }

    // MARK: - Private

    fileprivate func setBarsStackViewItems() {
        (0..<cardViewModel.imageNames.count).forEach { _ in
            let barView = UIView()
            barView.backgroundColor = barDeselectionColor
            barsStackView.addArrangedSubview(barView)
        }
        barsStackView.arrangedSubviews.first?.backgroundColor = .white
    }

    @objc fileprivate func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }

    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            break
        }
    }

    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        // rotation
        let translation = gesture.translation(in: nil)
        let degree: CGFloat = translation.x / 20
        let angle = degree * .pi / 180

        let rotationTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationTransformation.translatedBy(x: translation.x, y: translation.y)
    }

    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseOut,
                       animations: {
                        if shouldDismissCard {
                            self.center = CGPoint(x: 1000 * translationDirection, y: 0)
                        } else {
                            self.transform = .identity
                        }

        }) { _ in
            self.transform = .identity
            if shouldDismissCard {
                self.removeFromSuperview()
            }
        }
    }

    fileprivate func setupLayout() {
        layer.cornerRadius = 10
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperview()

        setupBarsStackView()
        setupGradientLayer()

        addSubview(informationLabel)

        informationLabel.anchor(top: nil,
                                leading: leadingAnchor,
                                bottom: bottomAnchor,
                                trailing: trailingAnchor,
                                padding: .init(top: 0, left: 16, bottom: 16, right: 16))

        informationLabel.textColor = .white
        informationLabel.numberOfLines = 0
    }

    fileprivate func setupBarsStackView() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor,
                             leading: leadingAnchor,
                             bottom: nil,
                             trailing: trailingAnchor,
                             padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))

        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
    }

    fileprivate func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
    }

    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] (idx, imageUrl) in
            guard let imageUrl = imageUrl else { return }
            if let url = URL(string: imageUrl) {
                self?.imageView.sd_setImage(with: url)
            }

            self?.barsStackView.arrangedSubviews.forEach { view in
                view.backgroundColor = self?.barDeselectionColor
            }
            self?.barsStackView.arrangedSubviews[idx].backgroundColor = .white
        }
    }

}
