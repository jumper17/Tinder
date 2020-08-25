//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by Vyacheslav Pavlov on 23.08.2020.
//  Copyright © 2020 Vyacheslav Pavlov. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {

    var bindableImage = Bindable<UIImage>()
    var bindableFormValid = Bindable<Bool>()
    var bindableIsRegistration = Bindable<Bool>()

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
        bindableFormValid.value = isFormValid
    }

    func performRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        bindableIsRegistration.value = true
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(error)
                return
            }
            print("successfully registered user:", result?.user.uid ?? "")
            self.saveImageToFirebase(completion: completion)
        }
    }

    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = [
            "fullName": fullName ?? "",
            "uid": uid,
            "imageUrl": imageUrl
        ]
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData(docData) { (error) in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }

    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageDate = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageDate, metadata: nil) { (_, error) in
            if let error = error {
                completion(error)
                return
            }
            print("Finished uploading image to storage")
            ref.downloadURL { (url, error) in
                if let error = error {
                    completion(error)
                    return
                }
                self.bindableIsRegistration.value = false
                print("Download url of our image is:", url?.absoluteString ?? "")
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            }
        }
    }
}
