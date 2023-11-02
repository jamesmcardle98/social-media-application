//
//  PostCell.swift
//  Non-Editable-Social-Media
//
//  Created by James McArdle on 15/03/2021.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    
    var post: PostData!
    var userPostKey: DatabaseReference!
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    
    func configCell(post: PostData) {
//        print(URL(string: post.postImg)!)
//        ImageService.downloadImage(withURL: URL(string: post.postImg)!) { image in
//            self.postImg.image = image
//        }
//
//        ImageService.downloadImage(withURL: URL(string: post.userImg)!) { image in
//            self.userImg.image = image
//        }
        
        username.text = post.username
        likesLabel.text = String(post.likes)
        
        
//        self.post = post
//        self.likesLabel.text = String(post.likes)
//        //each post has a key which then goes to a user -- might have to do something more here
//        //self.username.text = post.username
//        self.username.text = post.username
        
        let ref = Storage.storage().reference(forURL: post.userImg)
        ref.getData(maxSize: 100000000, completion: { (data, error) in
            if error != nil {
                print("couldnt load img")
            } else {
                if let imgData = data {
                    if let img = UIImage(data: imgData){
                        self.userImg.image = img
                    }
                }
            }
        })

        let postImageRef = Storage.storage().reference(forURL: post.postImg)
        postImageRef.getData(maxSize: 100000000, completion: { (data, error) in
            if error != nil {
                print("couldnt load img")
            } else {
                if let imgData = data {
                    if let img = UIImage(data: imgData){
                        self.postImg.image = img
                    }
                }
            }
        })
    }
    
    @IBAction func liked(_ sender: Any) {
//        let likeRef = Database.database().reference().child("posts").child(currentUser!).child("likes").child(post.postKey)
//        
//        likeRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            if let _ = snapshot.value as? NSNull {
//                self.post.adjustLikes(addLike: true)
//                likeRef.setValue(true)
//            } else {
//                self.post.adjustLikes(addLike: false)
//                likeRef.removeValue()
//            }
//        })
    }

}
