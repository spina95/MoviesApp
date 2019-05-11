//
//  ViewAllImagesViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 09/07/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift

class ViewAllImagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var objectToSort: Any!
    var objects: Any?
    var imageToPass: Images_MDB?
    var titleName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        titleName = self.title

        if let objectsArray = objectToSort as? (ImagesMDB?) {
            objects = objectsArray
        }
        // Do any additional setup after loading the view.

        if let objectsArray = objectToSort as? [Images_MDB]? {
            objects = objectsArray
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = titleName
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let images = objects as? ImagesMDB {
            return images.backdrops.count + images.posters.count
        }
        if let objectsArray = objectToSort as? [Images_MDB]? {
            return (objectsArray?.count)!
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        // In this function is the code you must implement to your code project if you want to change size of Collection view
        let width  = (view.frame.width-10)/4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let images = objects as? ImagesMDB {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ViewAllImageCollectionViewCell
            if (indexPath.row <= images.backdrops.count - 1) {
                cell?.photo.downloadImage(path: images.backdrops[indexPath.row].file_path, placeholder: #imageLiteral(resourceName: "background"))
            } else {
                cell?.photo.downloadImage(path: images.posters[indexPath.row - images.backdrops.count].file_path, placeholder: #imageLiteral(resourceName: "background"))
            }
            return cell!
        }
         if let images = objects as? [Images_MDB]? {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ViewAllImageCollectionViewCell
            cell?.photo.downloadImage(path: images![indexPath.row].file_path, placeholder: #imageLiteral(resourceName: "background"))
            return cell!
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let images = objects as? ImagesMDB {
            if (indexPath.row <= images.backdrops.count - 1) {
                 imageToPass = images.backdrops[indexPath.row]
            } else {
                imageToPass = images.posters[indexPath.row - images.backdrops.count]
            }
        }
        if let images = objects as? [Images_MDB]? {
            imageToPass = images![indexPath.row]
        }
        self.performSegue(withIdentifier: "showImage", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage" {
            let vc = segue.destination as! ShowImageViewController
            vc.photoImage = imageToPass
            self.title = ""
        }
    }
}
