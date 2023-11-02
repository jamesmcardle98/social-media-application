//
//  TableViewController.swift
//  Non-Editable-Social-Media
//
//  Created by James McArdle on 15/03/2021.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import ImageIO
import PhotosUI

class FeedVC: UITableViewController, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    
//    @IBOutlet weak var postButton: UIButton!
    
    var posts = [PostData]()
    var post: PostData!
    var imagePicker: UIImagePickerController!
    var imageSelected: Bool = false
    var selectedImage: UIImage!
    var userImage: String!
    var userName: String!
    var currentUserImageUrl: String!
    var MIR = MIR_algorithm()

    override func viewDidLoad() {
        super.viewDidLoad()
        let postButton = UIBarButtonItem(title: "Post+", style: .plain, target: self, action: #selector(postImage))
        let myProfile = UIBarButtonItem(title: "Home☺︎", style: .plain, target: self, action: #selector(goToProfile))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        navigationItem.rightBarButtonItems = [myProfile, postButton]
        getUsersData()
        getPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func getUsersData(){
      //let uid = KeychainWrapper.standard.string(forKey: "uid")
        let userID = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            if let postDict = snapshot.value as? [String : AnyObject] {
                self.currentUserImageUrl = postDict["userImg"] as? String
                self.tableView.reloadData()
            }
        }
    }
    
    func getPosts() {
        let postsRef = Database.database().reference().child("posts")
        
        postsRef.observe(.value, with: { snapshot in
            var tempPosts = [PostData]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let username = dict["username"] as? String,
                   let likes = dict["likes"] as? Int,
                   let userImg = dict["userImg"] as? String,
                   let imgURL = dict["imgURL"] as? String {
                    
                    let post = PostData(imgUrl: imgURL, likes: likes, username: username, userImg: userImg)
                    tempPosts.append(post)
                }
            }
            self.posts = tempPosts
            self.tableView.reloadData()
        })
        
//        Database.database().reference().child("posts").observeSingleEvent(of: .value) { (snapshot) in
//            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
//            self.posts.removeAll()
//            for data in snapshot.reversed() {
//                guard let postDict = data.value as? Dictionary<String, AnyObject> else { return }
//                let post = PostData(postKey: data.key, postData: postDict)
//                self.posts.append(post)
//            }
//            self.tableView.reloadData()
//        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    @objc func goToProfile (_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toProfile", sender: nil)
    }
    
    @objc func signOut (_ sender: AnyObject) {
        try! Auth.auth().signOut()
        KeychainWrapper.standard.removeObject(forKey: "uid")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func postImage (_ sender: AnyObject) {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        configuration.filter = .images
        configuration.selectionLimit = 1
        let phPicker = PHPickerViewController(configuration: configuration)
        phPicker.delegate = self
        self.present(phPicker, animated: true)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostCell else { return UITableViewCell() }
        //cell.configCell(post: posts[indexPath.row-1])
        cell.configCell(post: posts[indexPath.row])
        //cell.configCell(post: PostData(imgUrl: "gs://non-editable-social-media.appspot.com/post-pics/3AD733E1-44B7-4E53-BB17-9F067F991C65", likes: 3, username: "@jamesmcardle", userImg: "gs://non-editable-social-media.appspot.com/post-pics/3AD733E1-44B7-4E53-BB17-9F067F991C65"))
        return cell
    }
    
//    @objc func post(_ sender: AnyObject) {
//        let photoLibrary = PHPhotoLibrary.shared()
//        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
//        configuration.filter = .images
//        configuration.selectionLimit = 1
//        let phPicker = PHPickerViewController(configuration: configuration)
//        phPicker.delegate = self
//        self.present(phPicker, animated: true)
//    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        var startTime: DispatchTime = DispatchTime(uptimeNanoseconds: 0)
        var endTime: DispatchTime = DispatchTime(uptimeNanoseconds: 0)
        picker.dismiss(animated: true)
        startTime = DispatchTime.now()
        //if(MIR.testImage(results: results)) {
            for result in results {
                  result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                     if let image = object as? UIImage {
                        DispatchQueue.main.async {
                           // Use UIImage
                            print("Selected image: \(image)")
                            if let imageData = image.jpegData(compressionQuality: 0.75){
                                let imgUID = UUID().uuidString
                                let metadata = StorageMetadata()
                                metadata.contentType = "image/jpeg"
                                //let storageRef = Storage.storage().reference().child("user/\(imgUID)")
                                Storage.storage().reference().child("post-pics").child(imgUID).putData(imageData, metadata: metadata) { [self] (metadata, error) in
                                    if error != nil {
                                        print("image wasn't saved to firebase database")
                                    } else {
                                        print("image was uploaded and saved to firebase storage")
                
                                        let downloadURL = "gs://" + metadata!.bucket + "/" + (metadata?.path!)!
                                        postToFirebase(imgURL: downloadURL)
                                        endTime = DispatchTime.now()
                                        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                                        let timeInterval = Double(nanoTime) / 1_000_000_000
                                        print("Time taken to post to firebase: \(timeInterval)")
                                    }
                                }
                            }
                        }
                     }
                  })
            }
            
//        } else {
//            let alert = UIAlertController(title: "Image Modification Detected!", message: "Please only use non-edited images from the camera.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//            self.present(alert, animated: true)
//        }
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            selectedImage = image
//            imageSelected = true
//        } else {
//            print("image was not selected")
//        }
//        imagePicker.dismiss(animated: true, completion: nil)
//
//        guard imageSelected == true else {
//            print("no image selected")
//            return
//        }
//
//        if(MIR.testImage(results: ) == true) {
//
//            if let imageData = selectedImage.jpegData(compressionQuality: 1.0) {
//
//                let imgUID = UUID().uuidString
//                let metadata = StorageMetadata()
//
//                metadata.contentType = "image/jpeg"
//                //let storageRef = Storage.storage().reference().child("user/\(imgUID)")
//                Storage.storage().reference().child("post-pics").child(imgUID).putData(imageData, metadata: metadata) { (metadata, error) in
//                    if error != nil {
//                        print("image wasn't saved to firebase database")
//                    } else {
//                        print("image was uploaded and saved to firebase storage")
//
//                        let downloadURL = metadata?.storageReference?.fullPath
//
//                        if let url = downloadURL {
//                            self.postToFirebase(imgURL: url)
//                        }
//
//                    }
//                }
//            }
//
//        }
//    }
    
    func postToFirebase(imgURL: String) {
        print("I made it here with \(Auth.auth().currentUser?.photoURL)")
        let postRef = Database.database().reference().child("posts").childByAutoId()
        
        let postObject = [
            "imgURL": imgURL,
            "username": Auth.auth().currentUser?.displayName,
            "likes": 0,
            "userImg": imgURL
        ] as [String: Any]
        
        postRef.setValue(postObject) { error, ref in
            if error == nil {
                print("successful")
            } else {
                // handle error
            }
        }
        
        self.tableView.reloadData()
        
//        let userID = Auth.auth().currentUser?.uid
//
//        Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
//            let data = snapshot.value as! Dictionary<String, AnyObject>
//            let username = "@jamesmcardle"
//            let userImg = imgURL
//            let posted: Dictionary<String, Any> = [
//                "username": username,
//                "userImg": userImg,
//                "imageURL": imgURL,
//                "likes": 0
//            ]
//
//            let firebasePost = Database.database().reference().child("posts").childByAutoId()
//
//            firebasePost.setValue(posted)
//
//            self.imageSelected = false
//            self.tableView.reloadData()
//        })
    }
}

