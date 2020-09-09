//
//  AgeRangeCell.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 03.09.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit

protocol AgeRangeCellDelegate: class {
    func ageRangeCell(_ ageRangeCell: AgeRangeCell, minAgeDidChange value: Float)
    func ageRangeCell(_ ageRangeCell: AgeRangeCell, maxAgeDidChange value: Float)
}

final class AgeRangeCell: UITableViewCell {

    // MARK: Public

    var minValue: Float {
        set {
            minSlider.value = newValue
            minLabel.text = "Min: \(Int(minSlider.value))"
        }
        get { minSlider.value }
    }

    var maxValue: Float {
        set {
            maxSlider.value = newValue
            maxLabel.text = "Max: \(Int(maxSlider.value))"
        }
        get { maxSlider.value }
    }

    weak var delegate: AgeRangeCellDelegate?

    // MARK: Private

    private let minSlider = UISlider()
    private let maxSlider = UISlider()
    private let minLabel = AgeRangeLabel()
    private let maxLabel = AgeRangeLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        [minSlider, maxSlider].forEach { slider in
            slider.minimumValue = 18
            slider.maximumValue = 100
        }
        minSlider.addTarget(self, action: #selector(handleMinAgeChange), for: .valueChanged)
        maxSlider.addTarget(self, action: #selector(handleMaxAgeChange), for: .valueChanged)
        let overallStackView = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [minLabel, minSlider]),
            UIStackView(arrangedSubviews: [maxLabel, maxSlider])
        ])
        overallStackView.axis = .vertical
        overallStackView.spacing = 16
        addSubview(overallStackView)
        overallStackView.anchor(top: topAnchor,
                                leading: leadingAnchor,
                                bottom: bottomAnchor,
                                trailing: trailingAnchor,
                                padding: .init(top: 16, left: 16, bottom: 16, right: 16))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func handleMinAgeChange() {
        minLabel.text = "Min: \(Int(minSlider.value))"
        delegate?.ageRangeCell(self, minAgeDidChange: minSlider.value)
    }

    @objc fileprivate func handleMaxAgeChange() {
        maxLabel.text = "Max: \(Int(maxSlider.value))"
        delegate?.ageRangeCell(self, maxAgeDidChange: maxSlider.value)
    }

}
