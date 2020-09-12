//
//  SettingsController.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 25.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit
import JGProgressHUD
import SDWebImage

protocol SettingsControllerDelegate {
    func didSaveSettings()
}

class SettingsController: UITableViewController {

    var delegate: SettingsControllerDelegate?
    private var settingsViewModel: SettingsViewModelProtocol?

    fileprivate lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    fileprivate lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    fileprivate lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    fileprivate lazy var imageButtons = [image1Button, image2Button, image3Button]

    fileprivate lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true

        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.spacing = padding
        stackView.distribution = .fillEqually
        header.addSubview(stackView)

        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsViewModel = SettingsViewModel()
        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        fetchCurrentUser()
    }

    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }

    @objc fileprivate func handleSave() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        settingsViewModel?.saveChange { [weak self] error in
            hud.dismiss()
            if let error = error {
                print("Failed to save user settings", error)
                return
            }
            print("Finished saving user info")
            self?.dismiss(animated: true) {
                print("Dismissal complete")
                self?.delegate?.didSaveSettings()
            }
        }
    }

    @objc fileprivate func handleSelectPhoto(button: UIButton) {
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }

    fileprivate func fetchCurrentUser() {
        settingsViewModel?.fetchCurrentUser { [weak self] error in
            if let error = error {
                print(error)
                return
            }
            self?.loadUserPhotos()
            self?.tableView.reloadData()
        }
    }

    fileprivate func loadUserPhotos() {
        for (index, button) in imageButtons.enumerated() {
            if let imageUrl = settingsViewModel?.imageUrl(forIndex: index),
                let url = URL(string: imageUrl) {
                SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                    button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            }
        }
    }

    fileprivate func createButton(selector: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle("Select Photo", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }

    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleCancel))
        ]
    }
}

extension SettingsController {

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = HeaderLabel()
        headerLabel.text = settingsViewModel?.headerLabel(forSection: section)
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        return headerLabel
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 40
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsViewModel?.sectionCount ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.delegate = self
            ageRangeCell.viewModel = settingsViewModel?.cellViewModel(forSection: 5)
            return ageRangeCell
        }
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        cell.tag = indexPath.section
        cell.delegate = self
        cell.viewModel = settingsViewModel?.cellViewModel(forSection: indexPath.section)
        return cell
    }
}

extension SettingsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)

        settingsViewModel?.uploadImage(selectedImage, completion: { [weak self] error in
            hud.dismiss()
            if let error = error {
                print(error)
                return
            }
            print("Finished uploading image")
            guard let imageButton = imageButton else { return }
            let index = self?.imageButtons.firstIndex(of: imageButton)
            if let index = index {
                self?.settingsViewModel?.setImageUrl(forIndexButton: index)
            }
        })
    }
}

// MARK: AgeRangeCellDelegate

extension SettingsController: AgeRangeCellDelegate {
    
    func ageRangeCell(_ ageRangeCell: AgeRangeCell, minAgeDidChange value: Float) {
        settingsViewModel?.setMinSeekingAge(Int(value))
    }

    func ageRangeCell(_ ageRangeCell: AgeRangeCell, maxAgeDidChange value: Float) {
       settingsViewModel?.setMaxSeekingAge(Int(value))
    }
}

// MARK: SettingsCellDelegate

extension SettingsController: SettingsCellDelegate {
    func settingsCell(_ settingsCell: SettingsCell, textFieldEditingChanged value: String?) {
        switch settingsCell.tag {
        case 1: settingsViewModel?.setName(value)
        case 2: settingsViewModel?.setProfession(value)
        case 3: settingsViewModel?.setAge(Int(value ?? ""))
        default: break
        }
    }
}
