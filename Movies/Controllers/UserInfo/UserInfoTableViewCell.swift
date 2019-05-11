//
//  UserInfoTableViewCell.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 08/08/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var followers: UIButton!
    @IBOutlet weak var following: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        picture.roundCorners(value: Double(Int(picture.frame.height/2)))
        picture.layer.borderColor = UIColor.white.cgColor
        picture.layer.borderWidth = 3
        followButton.layer.borderWidth = 1
        followButton.roundCorners(value: 5)
        followButton.layer.borderColor = mainColor.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
