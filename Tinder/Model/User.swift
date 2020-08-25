//
//  User.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 19.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit

struct User: ProducesCardViewModel {

    var name: String?
    var age: Int?
    var profession: String?
    //let imageNames: [String]
    var imageUrl: String?
    var uid: String?

    init(dictionary: [String: Any]) {
        self.age = dictionary["age"] as? Int ?? 0
        self.name = dictionary["fullName"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.profession = dictionary["profession"] as? String ?? ""
    }


    func toCardViewModel() -> CardViewModel {
        let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])

        let ageString = age != nil ? "\(age!)" : "N\\A"

        attributedText.append(NSAttributedString(string: " \(ageString)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))

        let professionString = profession != nil ? profession! : "Not available"

        attributedText.append(NSAttributedString(string: "\n\(professionString)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))

        return CardViewModel(imageNames: [imageUrl ?? ""], attributedString: attributedText, textAligment: .left)
    }
}
