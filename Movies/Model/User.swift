//
//  User.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 16/07/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import FirebaseAuth

class User {
    
    // MARK: - Properties
    var email: String?
    var uid: String?
    var username: String?
    var sex: String?
    var country: String?
    var profilePictureUrl: String?
    var profilePicture: UIImage?
    // MARK: - Init
    
    init(){}
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String,
            let sex = dict["sex"] as? String?,
            let country = dict["country"] as? String?,
            let profilePictureUrl = dict["user_photo"] as? String?

            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
        self.sex = sex
        self.country = country
        self.profilePictureUrl = profilePictureUrl
    }
}

