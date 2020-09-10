//
//  ViewController.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 16.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit
import JGProgressHUD

class HomeController: UIViewController {

    private let topStackView = TopNavigationStackView()
    private let cardsDeckView = UIView()
    private let bottomControl = HomeBottomControlsStackView()

    private var viewModel: HomeViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = HomeViewModel()
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControl.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        setupLayout()
        fetchCurrentUser()
    }

    // MARK: - Fileprivate

    fileprivate func fetchCurrentUser() {
        viewModel?.fetchCurrentUser { [weak self] error in
            guard error == nil else {
                print("Failed to fetch current user:", error!)
                return
            }
            self?.fetchAllUsers()
        }
    }

    fileprivate func fetchAllUsers() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Users"
        hud.show(in: self.view)

        viewModel?.fetchAllUsers { [weak self] error in
            hud.dismiss()
            guard error == nil else {
                print("Failed to fetch users:", error!)
                return
            }
            self?.setupCard()
        }
    }

    @objc fileprivate func handleRefresh() {
        fetchAllUsers()
    }

    fileprivate func setupCard() {
        self.viewModel?.cardViewModels.forEach({ [weak self] cardViewModel in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardViewModel
            self?.cardsDeckView.addSubview(cardView)
            self?.cardsDeckView.sendSubviewToBack(cardView)
            cardView.fillSuperview()
        })
    }

    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true, completion: nil)
    }

    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControl])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                leading: view.leadingAnchor,
                                bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardsDeckView)
    }

}

extension HomeController: SettingsControllerDelegate {
    func didSaveSettings() {
        fetchCurrentUser()
    }
}
