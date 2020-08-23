//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 23.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import Foundation

class RegistrationViewModel {

    var fullName: String? {
        didSet {
            checkFormValidity()
        }
    }
    var email: String? {
        didSet {
            checkFormValidity()
        }
    }
    var password: String? {
        didSet {
            checkFormValidity()
        }
    }

    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        isFormValidObserver?(isFormValid)
    }

    // Reactive programming

    var isFormValidObserver: ((Bool) -> ())?
}
