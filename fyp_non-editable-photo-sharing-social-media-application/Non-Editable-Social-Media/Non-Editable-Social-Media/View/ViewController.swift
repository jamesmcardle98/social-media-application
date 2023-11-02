//
//  ViewController.swift
//  Non-Editable-Social-Media
//
//  Created by James McArdle on 14/02/2021.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftKeychainWrapper


class ViewController: UIViewController {
        
    @IBOutlet weak var addProfilePicture: UIButton!
//    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var userImgView: UIImageView!
    var imagePicker: UIImagePickerController!
    var selectedImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //pulling the string UID to perform segue automatically
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            self.performSegue(withIdentifier: "toFeed", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        //dispose of any resources that can be recreated
        super.didReceiveMemoryWarning()
    }
    
//    func storeUserData(userID: String){
////        let downloadURL: String!
//        // might possibly have to perform M.I.R algorithm on this!!
//        if let imageData = selectedImage.jpegData(compressionQuality: 0.75) {
//            if imageData == nil {
//                print("OOPS!")
//            }
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
//                        "username": self.usernameField.text!,
//                        "userImg": downloadURL
//                    ] as [String: Any]
//
//                    Database.database().reference().child("users").child(userID).setValue(userData)
//                }
//            }
//        }
//    }

    @IBAction func signInPressed(_ sender: Any) {
        if let email = emailField.text, let password = passwordField.text {
            //If there is an error entering credentials, either user doesn't exist or credentials are wrong
            Auth.auth().signIn(withEmail: email, password: password){ (user, error) in
                if error != nil {
                    // if the user doesnt have an account we should create one and send credentials to the database
                    let alert = UIAlertController(title: "Invalid Credentials", message: "Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                    self.present(alert, animated: true)
                } else {
                    // if user doesnt have a userID it doesnt store the variable userID
                    if let userID = user?.user.uid {
                        KeychainWrapper.standard.set(userID, forKey: "KEY_UID")
                        self.performSegue(withIdentifier: "toFeed", sender: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toCreateAccount", sender: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            userImgView.image = image
            print(image)
        } else {
            print("image was not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

