//
//  HomeViewModel.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 10.09.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import Foundation
import Firebase

protocol HomeViewModelProtocol {
    var cardViewModels: [CardViewModel] { get }
    func fetchCurrentUser(completion: @escaping (Error?) -> ())
    func fetchAllUsers(completion: @escaping (Error?) -> ())
}

class HomeViewModel: HomeViewModelProtocol {

    private var currentUser: User?
    private var allUsers = [User]()
    private let collection = "users"
    private let firestore = Firestore.firestore()

    var cardViewModels: [CardViewModel] {
        var viewModels = [CardViewModel]()
        allUsers.forEach { viewModels.append($0.toCardViewModel()) }
        return viewModels
    }

    func fetchCurrentUser(completion: @escaping (Error?) -> ()) {
        guard let uid = uid else { return }
        firestore.collection(collection).document(uid).getDocument { (snapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            guard let dictionary = snapshot?.data() else { return }
            self.currentUser = User(dictionary: dictionary)
            completion(nil)
        }
    }

    func fetchAllUsers(completion: @escaping (Error?) -> ()) {
        guard let minAge = currentUser?.minSeekingAge, let maxAge = currentUser?.maxSeekingAge else { return }

        let query = firestore.collection(collection).whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Failed to fetch users:", error)
                completion(error)
                return
            }
            snapshot?.documents.forEach({ documentSnapchot in
                let user = self.makeUserFromSnapshot(documentSnapchot)
                self.allUsers.append(user)
            })
            completion(nil)
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
