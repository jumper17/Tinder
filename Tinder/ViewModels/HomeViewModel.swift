//
//  HomeViewModel.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 10.09.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import Foundation
import Firebase

enum FetchedUser {
    case current
    case all
}

protocol HomeViewModelProtocol {
    var bindableCardViewModels: Bindable<[CardViewModel]> { get set }
    var bindableUsersIsFetched: Bindable<Bool> { get set }
    func fetchUsers(fetched: FetchedUser)
}

class HomeViewModel: HomeViewModelProtocol {

    var bindableUsersIsFetched = Bindable<Bool>()
    var bindableCardViewModels = Bindable<[CardViewModel]>()
    private var currentUser: User?
    private var allUsers = [User]()
    private let collection = "users"
    private let firestore = Firestore.firestore()
    private lazy var errorHandling: ((Error, String) -> ()) = { [weak self] error, message in
        self?.bindableUsersIsFetched.value = false
        print(message, error)
    }


//    var cardViewModels: [CardViewModel] {
//        var viewModels = [CardViewModel]()
//        allUsers.forEach { viewModels.append($0.toCardViewModel()) }
//        return viewModels
//    }

    func fetchUsers(fetched: FetchedUser) {
        if fetched == .current {
            fetchCurrentUser()
        } else {
            fetchAllUsers()
        }
    }

    private func fetchCurrentUser() {
        guard let uid = uid else {
            bindableUsersIsFetched.value = false
            return
        }
        firestore.collection(collection).document(uid).getDocument { [weak self] (snapshot, error) in
            if let error = error {
                self?.errorHandling(error, "Failed to fetch current user:")
                return
            }
            guard let dictionary = snapshot?.data() else { return }
            self?.currentUser = User(dictionary: dictionary)
            self?.bindableUsersIsFetched.value = true
        }
    }

    func fetchAllUsers() {
        guard let minAge = currentUser?.minSeekingAge, let maxAge = currentUser?.maxSeekingAge else { return }

        let query = firestore.collection(collection).whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        query.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let error = error {
                self.errorHandling(error, "Failed to fetch all users:")
                return
            }
            self.allUsers = []
            //self.bindableCardViewModels.v
            snapshot?.documents.forEach({ documentSnapchot in
                let user = self.makeUserFromSnapshot(documentSnapchot)
                self.allUsers.append(user)
            })
            self.bindableUsersIsFetched.value = true
        }
    }

    private var uid: String? {
        return Auth.auth().currentUser?.uid
    }

    private func makeUserFromSnapshot(_ snapshot: QueryDocumentSnapshot) -> User {
        let userDictionary = snapshot.data()
        return User(dictionary: userDictionary)
    }


}
