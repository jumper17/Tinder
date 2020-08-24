//
//  Bindable.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 23.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }

    var observer: ((T?) -> ())?

    func bind(observer: @escaping ((T?) -> ())) {
        self.observer = observer
    }
}
