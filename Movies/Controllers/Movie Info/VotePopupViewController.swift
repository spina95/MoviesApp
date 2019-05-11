//
//  VotePopupViewController.swift
//  Movies
//
//  Created by Andrea Spinazzola on 04/03/2019.
//  Copyright © 2019 Andrea Spinazzola. All rights reserved.
//

import UIKit
import HGCircularSlider
import TMDBSwift

protocol popupPassDataBack {
    func pass(vote: Int)
}

class VotePopupViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var backgroundView: UIVisualEffectView!
    @IBOutlet weak var slider: CircularSlider!
    @IBOutlet weak var sliderLabel: UILabel!
    
    var vote = 0
    var tempVote = 0
    var movie: MovieDetailedMDB!
    var delegate: popupPassDataBack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 15
        if(vote != -1) {
            slider.endPointValue = CGFloat(vote)
            sliderLabel.text = String(vote)
        } else {
            slider.endPointValue = 1
            sliderLabel.text = String(1)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        let opaqueView = UIView()
        opaqueView.backgroundColor = UIColor.red
        let screenSize: CGRect = UIScreen.main.bounds
        opaqueView.frame.size = CGSize(width: screenSize.width, height: screenSize.height)
        opaqueView.layer.position = CGPoint(x: 0, y: -500)
        UIApplication.shared.keyWindow!.insertSubview(opaqueView, belowSubview: popupView)
        
        backgroundView.addGestureRecognizer(tap)
        backgroundView.frame = UIApplication.shared.keyWindow!.frame
        backgroundView.layer.frame = CGRect(x: 0, y: -100, width: 100, height: 100)
        backgroundView.isUserInteractionEnabled = true
        UIApplication.shared.keyWindow!.bringSubviewToFront(backgroundView)
        
        self.showAnimate()
        // Do any additional setup after loading the view.
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.delegate.pass(vote: self.vote)
                self.view.removeFromSuperview()
            }
        });
    }
    
    @IBAction func vote(_ sender: Any) {
        UserFirebase.voteMovie(movie: movie!, vote: tempVote) { (error) in
            if(error == nil) {
                self.vote = self.tempVote
                let vote = Vote(id: (self.movie?.id)!, vote: Double(self.vote))
                currentUserFirebase?.votes?.append(vote)
                self.removeAnimate()
            }
        }
    }
    
    @IBAction func sliderChange(_ sender: CircularSlider) {
        var value = Int(sender.endPointValue)
        if(value == 0) {
            value = 10
        }
        sliderLabel.text = String(value)
        sender.endPointValue = CGFloat(value)
        tempVote = value
    }

}
