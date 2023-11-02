//
//  CreateAccountVC.swift
//  Non-Editable-Social-Media
//
//  Created by James McArdle on 23/03/2021.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftKeychainWrapper

class CreateAccountVC: UIViewController {

    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    var imagePicker: UIImagePickerController!
    var selectedImage: UIImage!
    var downloadURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPassword.isSecureTextEntry = true
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func createAccountAndSignIn(_ sender: Any) {
        
        guard let username = username.text else {return}
        guard let email = userEmail.text else {return}
        guard let password = userPassword.text else {return}
        guard let image = userImage.image else {return}

        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                print("User created")
                
                self.uploadProfilePicture(image) { url in
                    
                    if url != nil {
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.photoURL = url
                        changeRequest?.commitChanges(completion: {error in
                            if error == nil {
                                self.storeUserData(username: username, profileImgURL: url!) { success in
                                    if(success) {
                                        self.performSegue(withIdentifier: "toFeed", sender: nil)
                                    }
                                }
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    } else {
                        print("error with url")
                    }

                }

            } else {
                let alert = UIAlertController(title: "Error!", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
//        if let email = userEmail.text, let password = userPassword.text {
//            //If there is an error entering credentials, either user doesn't exist or credentials are wrong
//            Auth.auth().signIn(withEmail: email, password: password){ (user, error) in
//                if error != nil {
//                    // if the user doesnt have an account we should create one and send credentials to the database
//                    Auth.auth().createUser(withEmail: email, password: password)
//                        { (user, error) in
//                        self.storeUserData(userID: (user?.user.uid)!)
//                        KeychainWrapper.standard.set((user?.user.uid)!, forKey: "KEY_UID")
//                        self.performSegue(withIdentifier: "toFeed", sender: nil)
//                    }
//                } else {
//                    // if user doesnt have a userID it doesnt store the variable userID
//                    if let userID = user?.user.uid {
//                        KeychainWrapper.standard.set(userID, forKey: "KEY_UID")
//                        self.performSegue(withIdentifier: "toFeed", sender: nil)
//                    }
//                }
//            }
//        }
    }
    
    func uploadProfilePicture(_ image: UIImage, completion: @escaping ((_ url: URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if error == nil, metadata != nil {
                storageRef.downloadURL(completion: { (url, error) in
                    if error == nil {
                        completion(url)
                    } else {
                        completion(nil)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    @IBAction func addProfilePicture(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
        
        //addProfilePicture.alpha = 0.0
    }
        
    override func didReceiveMemoryWarning() {
        //dispose of any resources that can be recreated
        super.didReceiveMemoryWarning()
    }
        
    func storeUserData(username: String, profileImgURL: URL, completion: @escaping ((_ success: Bool)->())){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/profile/\(uid)")
        let userObject = [
            "username": username,
            "photoURL": profileImgURL.absoluteString
        ] as [String:Any]
        
        databaseRef.setValue(userObject) { error, ref in
            completion(error == nil)
        }
        
//        //let downloadURL: String!
//        // might possibly have to perform M.I.R algorithm on this!!
//        if let imageData = selectedImage.jpegData(compressionQuality: 0.75) {
//            let metadata = StorageMetadata()
//            let imgUID = UUID().uuidString
//            let storageRef = Storage.storage().reference().child("user/\(imgUID)")
//            Storage.storage().reference().putData(imageData, metadata: metadata) { (metadata, error) in
//                guard let metadata = metadata else {
//                    // Uh-oh, an error occurred!
//                    return
//                }
//                // You can also access to download URL after upload.
//                storageRef.downloadURL { (url, error) in
//                    guard let downloadURL = url else {
//                        // Uh-oh, an error occurred!
//                        return
//                    }
//                    print("********************************************************")
//                    print(downloadURL.absoluteURL, downloadURL.absoluteString)
//                    print("********************************************************")
//
//                    let userData = [
//                        "username": self.username.text!,
//                        "userImg": downloadURL
//                    ] as [String: Any]
//
//                    Database.database().reference().child("users").child(userID).setValue(userData)
//                }
//            }
//        }
    }
    
}

extension CreateAccountVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.userImage.image = image
            selectedImage = image
        } else {
            print("image was not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
