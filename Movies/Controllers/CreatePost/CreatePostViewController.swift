//
//  CreatePostViewController.swift
//  Movies
//
//  Created by Andrea Spinazzola on 04/10/2018.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift
import FLAnimatedImage

class CreatePostViewController: UIViewController, SwiftyGiphyViewControllerDelegate {

    @IBOutlet weak var editorView: UIView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var imageHeigth: NSLayoutConstraint!
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var movie: MovieMDB!
    
    let gifController = SwiftyGiphyViewController()
    var gifSelected: GiphyItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        gifController.delegate = self
        imageHeigth.constant = 0
        username.setTitle(currentUserFirebase?.username, for: .normal)
        profilePicture.roundCorners(value: Double(Int(profilePicture.frame.height/2)))
        profilePicture.image = currentUserFirebase?.profilePicture
        let date1 = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date1)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        date.text = String(day!) + " " + String(month!) + " " + String(year!)
    }

    @IBAction func `public`(_ sender: Any) {
        let date = getTodayString()
        var post = Post()
        if(gifSelected != nil) {
            let gifURL : String = (gifSelected!.downsizedImage?.url?.absoluteString)!
            post = Post(id: nil, text: textField.text, userId: currentUserFirebase?.uid, date: date, gifUrl: gifURL)
        } else {
            post = Post(id: nil, text: textField.text, userId: currentUserFirebase?.uid, date: date, gifUrl: nil)
        }
        post.publishPost(movie: movie) { (error) in
            if(error == nil) {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func searchGif(_ sender: Any) {
        self.navigationController?.pushViewController(gifController, animated: true)
    }
    
    func giphyControllerDidSelectGif(controller: SwiftyGiphyViewController, item: GiphyItem) {
        gifSelected = item
        _ = navigationController?.popViewController(animated: true)
        gifSelected = item
        let gifURL : String = (item.downsizedImage?.url?.absoluteString)!
        let imageURL = UIImage.gif(url: gifURL)
        //let heigth = (item.downsizedImage?.width)! * Int(UIScreen.main.bounds.height) / (item.downsizedImage?.width)!
        imageHeigth.constant = 130
        imageToPost.image = imageURL

    }
    
    func giphyControllerDidCancel(controller: SwiftyGiphyViewController) {
        gifSelected = nil
        dismiss(animated: true, completion: nil)
    }
    
}
