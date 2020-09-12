//
//  SettingsViewModel.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 12.09.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import Firebase

protocol SettingsViewModelProtocol {
    func fetchCurrentUser(completion: @escaping (Error?) -> ())
    func imageUrl(forIndex index: Int) -> String?
    func headerLabel(forSection section: Int) -> String?
    func cellViewModel(forSection section: Int) -> CellViewModelProtocol
    func setName(_ name: String?)
    func setProfession(_ profession: String?)
    func setAge(_ age: Int?)
    func setMinSeekingAge(_ age: Int?)
    func setMaxSeekingAge(_ age: Int?)
    func uploadImage(_ image: UIImage?, completion: @escaping (Error?) -> ())
    func saveChange(completion: @escaping (Error?) -> ())
    func setImageUrl(forIndexButton index: Int)
    var sectionCount: Int { get }
}

class SettingsViewModel: SettingsViewModelProtocol {

    private var user: User?
    private let collection = "users"
    private var lastUploadImageUrl: URL!
    private let storage = Storage.storage()
    private let firestore = Firestore.firestore()


    private let headerLabels = [nil, "Name", "Profession", "Age", "Bio", "Seeking Age Range"]
    private let placeholdersCell = [nil, "Enter Name", "Enter Profession", "Enter Age", "Enter Bio"]

    func fetchCurrentUser(completion: @escaping (Error?) -> ()) {
        guard let uid = uid else { return }
        firestore.collection(collection).document(uid).getDocument { (snapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            guard let dictionary = snapshot?.data() else { return }
            self.user = User(dictionary: dictionary)
            completion(nil)
        }
    }

    func imageUrl(forIndex index: Int) -> String? {
        if user == nil || index > imageUrls.count {
            return nil
        }
        return imageUrls[index]
    }

    func headerLabel(forSection section: Int) -> String? {
        return headerLabels[section]
    }

    var sectionCount: Int {
        return headerLabels.count
    }

    func cellViewModel(forSection section: Int) -> CellViewModelProtocol {
        var textCell: String?
        switch section {
        case 1: textCell = user?.name
        case 2: textCell = user?.profession
        case 3:
            if let age = user?.age {
                textCell = String(age)
            }
        case 5:
            return AgeRangeCellViewModel(minSeekingAge: user?.minSeekingAge, maxSeekingAge: user?.maxSeekingAge)
        default: break
        }
        let placeholder = placeholdersCell[section]!
        return SettingsCellViewModel(textCell: textCell, placeholderCell: placeholder)
    }

    func setName(_ name: String?) {
        user?.name = name
    }

    func setProfession(_ profession: String?) {
        user?.profession = profession
    }

    func setAge(_ age: Int?) {
        user?.age = age
    }

    func setMinSeekingAge(_ age: Int?) {
        user?.minSeekingAge = age
    }

    func setMaxSeekingAge(_ age: Int?) {
        user?.maxSeekingAge = age
    }

    func uploadImage(_ image: UIImage?, completion: @escaping (Error?) -> ()) {
        let filename = UUID().uuidString
        let ref = storage.reference(withPath: "/images/\(filename)")
        guard let uploadData = image?.jpegData(compressionQuality: 0.75) else { return }
        ref.putData(uploadData, metadata: nil) { (nil, error) in
            if let error = error {
                completion(error)
                return
            }
            ref.downloadURL { (url, error) in
                if let error = error {
                    completion(error)
                    return
                }
                self.lastUploadImageUrl = url
                completion(nil)
            }
        }
    }

    func saveChange(completion: @escaping (Error?) -> ()) {
        guard let uid = uid else { return }
        let docData: [String: Any] = [
            "uid": uid,
            "fullName": user?.name ?? "",
            "imageUrl1": user?.imageUrl1 ?? "",
            "imageUrl2": user?.imageUrl2 ?? "",
            "imageUrl3": user?.imageUrl3 ?? "",
            "age": user?.age ?? -1,
            "profession": user?.profession ?? "",
            "minSeekingAge": user?.minSeekingAge ?? -1,
            "maxSeekingAge": user?.maxSeekingAge ?? -1
        ]
        firestore.collection(collection).document(uid).setData(docData) { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }

    func setImageUrl(forIndexButton index: Int) {
        switch index {
        case 0: user?.imageUrl1 = lastUploadImageUrl.absoluteString
        case 1: user?.imageUrl2 = lastUploadImageUrl.absoluteString
        default: user?.imageUrl3 = lastUploadImageUrl.absoluteString
        }
    }

    private var imageUrls: [String?] {
        return [user?.imageUrl1, user?.imageUrl2, user?.imageUrl3]
    }

    private var uid: String? {
        return Auth.auth().currentUser?.uid
    }

}
