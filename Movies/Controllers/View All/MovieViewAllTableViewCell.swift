//
//  ViewAllTableViewCell.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 08/07/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import HGCircularSlider

class MovieViewAllTableViewCell: UITableViewCell {

    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var averageVote: CircularSlider!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var userVote: CircularSlider!
    @IBOutlet weak var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        poster.roundCorners(value: 4)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
