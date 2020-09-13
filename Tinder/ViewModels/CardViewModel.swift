//
//  CardViewModel.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 20.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit

protocol CardViewModelProtocol {
    var imageNames: [String] { get }
    var attributedString: NSAttributedString { get }
    var textAligment: NSTextAlignment { get }
    var imageIndexObserver: ((Int, String?) -> ())? { get set }
    func advanceToNextPhoto()
    func goToPreviousPhoto()
}

class CardViewModel: CardViewModelProtocol {

    var imageNames: [String] {
        return imgNames
    }

    var attributedString: NSAttributedString {
        return string
    }

    var textAligment: NSTextAlignment {
        return aligment
    }

    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imgNames[imageIndex]
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }

    let imgNames: [String]
    let string: NSAttributedString
    let aligment: NSTextAlignment
    var imageIndexObserver: ((Int, String?) -> ())? {
        didSet {
            
        }
    }

    init(imgNames: [String], string: NSAttributedString, aligment: NSTextAlignment) {
        self.imgNames = imgNames
        self.string = string
        self.aligment = aligment
    }

    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imgNames.count - 1)
    }

    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}
