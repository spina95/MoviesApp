//
//  CommentTableViewCell.swift
//  Movies
//
//  Created by Andrea Spinazzola on 04/10/2018.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import FLAnimatedImage

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var date: UIView!
    @IBOutlet weak var imagePost: FLAnimatedImageView!
    @IBOutlet weak var imageHeigth: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var commentCounter: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.roundCorners(value: Double(Int(profilePicture.frame.height/2)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var date: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.roundCorners(value: Double(Int(profilePicture.frame.height/2)))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

