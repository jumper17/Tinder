//
//  AgeRangeCellViewModel.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 12.09.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import Foundation

protocol AgeRangeCellViewModelProtocol: CellViewModelProtocol {
    var minValue: Float { get }
    var maxValue: Float { get }
}

class AgeRangeCellViewModel: AgeRangeCellViewModelProtocol {

    private let minSeekingAge: Int?
    private let maxSeekingAge: Int?

    init(minSeekingAge: Int?, maxSeekingAge: Int?) {
        self.minSeekingAge = minSeekingAge
        self.maxSeekingAge = maxSeekingAge
    }

    var minValue: Float {
        return Float(minSeekingAge ?? 0)
    }

    var maxValue: Float {
        return Float(maxSeekingAge ?? 0)
    }
}
