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
        topStackView.delegate = self
        bottomControl.delegate = self
        setupLayout()
        bindUsers()
        viewModel?.fetchUsers()
    }

    // MARK: - Fileprivate

    fileprivate func bindUsers() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Users"
        hud.show(in: self.view)

        viewModel?.bindableUsersIsFetched.bind { _ in hud.dismiss() }

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

extension HomeController: HomeBottomControlsStackViewDelegate {
    func homeBottomControlsStackViewRefreshButtonDidTap(_ stackView: HomeBottomControlsStackView) {
        fetchAllUsers()
    }
}

extension HomeController: TopNavigationStackViewDelegate {
    func topNavigationStackViewSettingsButtonDidTap(_ stackView: TopNavigationStackView) {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true, completion: nil)
    }
}
