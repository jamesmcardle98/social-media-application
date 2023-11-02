//
//  PostData.swift
//  Non-Editable-Social-Media
//
//  Created by James McArdle on 22/03/2021.
//

import Foundation
import Firebase
//import FirebaseDatabase

class PostData {
    var username: String!
    var userImg: String!
    var postImg: String!
    var likes: Int!
    private var _postKey: String!
    private var _postRef: DatabaseReference!
    
    init(imgUrl: String, likes: Int, username: String, userImg: String) {
        self.postImg = imgUrl
        self.likes = likes
        self.username = username
        self.userImg = userImg
    }
    
//    var username: String{
//        return _username
//    }
//
//    var userImg: String {
//        return _userImg
//    }
//
//    var postImg: String {
//        get {
//            return _postImg
//        } set {
//            _postImg = newValue
//        }
//    }
//
//    var likes: Int {
//        return _likes
//    }
//
//    var postKey: String {
//        return _postKey
//    }
//

//
//    init(postKey: String, postData: Dictionary<String, AnyObject>) {
//        _postKey = postKey
//
//        if let username = postData["username"] as? String {
//            _username = username
//        }
//
//        if let userImg = postData["userImg"] as? String {
//            _userImg = userImg
//        }
//
//        if let postImage = postData["imageURL"] as? String {
//            _postImg = postImage
//        }
//
//        if let likes = postData["likes"] as? Int {
//            _likes = likes
//        }
//
//        _postRef = Database.database().reference().child("posts").child(_postKey)
//    }
//
//    func adjustLikes(addLike: Bool) {
//        if addLike {
//            _likes += 1
//        }
//        _postRef.child("likes").setValue(_likes)
//    }
}
