//
//  CardViewModel.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 20.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {

    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageNames[imageIndex]
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }

    let imageNames: [String]
    let attributedString: NSAttributedString
    let textAligment: NSTextAlignment

    init(imageNames: [String], attributedString: NSAttributedString, textAligment: NSTextAlignment) {
        self.imageNames = imageNames
        self.attributedString = attributedString
        self.textAligment = textAligment
    }

    var imageIndexObserver: ((Int, String?) -> ())?

    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageNames.count - 1)
    }

    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}
