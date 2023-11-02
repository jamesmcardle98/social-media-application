//
//  MyProfile.swift
//  Non-Editable-Social-Media
//
//  Created by James McArdle on 24/04/2021.
//

import UIKit
import Firebase

class MyProfile: UIViewController{
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UILabel!
    var profilePic: UIImage!
    override func viewDidLoad() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        super.viewDidLoad()
        username.text = Auth.auth().currentUser?.displayName!
        storageRef.getData(maxSize: 100000000, completion: { (data, error) in
            if error != nil {
                print("couldnt load img")
            } else {
                if let imgData = data {
                    if let img = UIImage(data: imgData){
                        self.profilePicture.image = img
                    }
                }
            }
        })
        
        getPosts()
//        Database.database().reference().child("users/profile/\((Auth.auth().currentUser?.uid)!)/photoURL").getData { (error, snapshot) in
//            if let error = error {
//                print(error)
//            } else if snapshot.exists() {
//                ImageService.downloadImage(withURL: snapshot.value as! URL ) { image in
//                    self.profilePicture.image = image
//                }
//            }
//        }
//        ImageService.downloadImage(withURL: (Auth.auth().currentUser?.photoURL?.absoluteURL)!) { image in
//            self.profilePicture.image = image
//        }
        // Do any additional setup after loading the view.
    }
    
    func getPosts(){
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
