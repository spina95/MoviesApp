//
//  NotificationsTableViewCell.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 08/08/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit

class FollowRequestNotificationTableViewCell: UITableViewCell {
   
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var refuseButton: UIButton!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var imagePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imagePicture.roundCorners(value: Double(Int(imagePicture.frame.height/2)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
