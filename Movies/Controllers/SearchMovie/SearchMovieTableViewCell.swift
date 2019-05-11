//
//  SearchMovieTableViewCell.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 28/03/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift

class SearchMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.1
    
    var movie: MovieMDB?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view.layer.cornerRadius = 8
        addButton.layer.cornerRadius = 15
        addButton.layer.borderColor = yellowColor.cgColor
        addButton.layer.borderWidth = 1
        view.clipsToBounds = true
                
        let shadowPath = UIBezierPath(roundedRect: self.view.bounds, cornerRadius: 15)
    
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: 8, height: 5);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class SearchPersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        //photoImage.roundCorners(value: Int(photoImage.frame.height/2))
        
        let shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: 5)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class SearchUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        let shadowPath = UIBezierPath(roundedRect: self.view.bounds, cornerRadius: 15)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: 8, height: 5);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
        photoImage.roundCorners(value: Double(Int(photoImage.frame.height/2)))
 
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}



