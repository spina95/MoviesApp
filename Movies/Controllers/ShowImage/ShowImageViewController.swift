//
//  ShowImageViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 15/09/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift

class ShowImageViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    
    var photoImage: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        if(photoImage != nil) {
            if let image = photoImage as? Images_MDB {
                photo.downloadImage(path: image.file_path, placeholder: #imageLiteral(resourceName: "background"))
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
