//
//  DiscoverCollectionViewCell.swift
//  Movies
//
//  Created by Andrea Spinazzola on 02/05/2019.
//  Copyright © 2019 Andrea Spinazzola. All rights reserved.
//

import UIKit
import HGCircularSlider

class FiltersCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.roundCorners(value: Double(button.frame.height/2))
    }
}

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var info2: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var averageVote: CircularSlider!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var userVote: CircularSlider!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var containerPoster: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        poster.roundCorners(value: 4)
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerPoster.roundCorners(value: 4)
        container.roundCorners(value: 4)
    }
}

