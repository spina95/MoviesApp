//
//  MovieInfoTableViewCell.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 21/03/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import SDWebImage
import YouTubePlayer
import TMDBSwift
import HGCircularSlider

class HeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var rightButton: UIButton!
}

class MovieInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

class friendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button1.roundCorners(value: Double(Int(button1.frame.height/2)))
        button1.layer.borderColor = UIColor.white.cgColor
        button1.layer.borderWidth = 2
        button2.roundCorners(value: Double(Int(button2.frame.height/2)))
        button2.layer.borderColor = UIColor.white.cgColor
        button2.layer.borderWidth = 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class VotesTableViewCell: UITableViewCell {

    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var averageGraph: CircularSlider!

    @IBOutlet weak var voteSlider: CircularSlider!
    @IBOutlet weak var voteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class PlotTableViewCell: UITableViewCell {
    
    @IBOutlet weak var overview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class ActorsTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView!
     var actors: [MovieCastMDB]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }    
}

extension ActorsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(actors != nil) {
            if(actors.count < 16) {
                return actors.count
            } else {
                return 16
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as! ActorsCollectionViewCell
        if (actors != nil) {
                if(actors.count != 0) {
                    if(actors[indexPath.row].profile_path != nil) {
                        if(actors[indexPath.row].profile_path != "") {
                            cell.picture.downloadImage(path: actors[indexPath.row].profile_path, placeholder: #imageLiteral(resourceName: "profile picture"))
                    }
                }
                cell.tag = indexPath.row
                cell.nameLabel.text = actors[indexPath.row].name
                cell.roleLabel.text = actors[indexPath.row].character
            }
        }
        return cell
    }
}

class ActorsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        picture.roundCorners(value: Double(Int(picture.frame.height/2)))
    }
}

extension ActorsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 117, height: 117)
    }
}

class TextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class similarMovieTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var movies: [MovieMDB]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension similarMovieTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (movies != nil) {
            if(movies.count < 16) {
                return movies.count
            }
            return 16
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionCell", for: indexPath) as! SimilarmovieCollectionViewCell
        if (movies?[indexPath.row].poster_path != nil) {
            if (movies?[indexPath.row].poster_path != "") {
                cell.picture.downloadImage(path:movies[indexPath.row].poster_path!, placeholder: #imageLiteral(resourceName: "background"))
            }
        }
        if let voteAverage = movies?[indexPath.row].vote_average {
            cell.averageLabel.text = String(format: "%.1f", voteAverage)
            cell.averageGraph.endPointValue = CGFloat(voteAverage)
            cell.setNeedsDisplay()
        }
        cell.userGraph.isHidden = true
        cell.userLabel.isHidden = true
        if let votes = currentUserFirebase?.votes {
            for i in votes{
                if(i.id == movies[indexPath.row].id) {
                    cell.userGraph.endPointValue = CGFloat(i.vote)
                    cell.userLabel.text = String(i.vote)
                    cell.userGraph.isHidden = false
                    cell.userLabel.isHidden = false
                }
                
            }
        }
        cell.tag = indexPath.row
        return cell
    }
}

class SimilarmovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var averageGraph: CircularSlider!
    @IBOutlet weak var userGraph: CircularSlider!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.roundCorners(value: 4)
    }
}

extension similarMovieTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 125, height: 188)
    }
}

// Image
class ImagesMovieTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var images: ImagesMDB!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension ImagesMovieTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (images.backdrops.count < 16) {
            return images.backdrops.count
        }
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollectionCell", for: indexPath) as! ImagemovieCollectionViewCell
        if (images.backdrops[indexPath.row] != nil) {
            cell.picture.downloadImage(path: images.backdrops[indexPath.row].file_path!, placeholder: #imageLiteral(resourceName: "background"))
        }
        cell.tag = indexPath.row
        return cell
    }
}

class ImagemovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var picture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.roundCorners(value: 5)
    }
}

extension ImagesMovieTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 117)
    }
}

// Video
class VideoMovieTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var videos: [VideosMDB]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension VideoMovieTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (videos.count < 16) {
            return videos.count
        }
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCollectionCell", for: indexPath) as! VideomovieCollectionViewCell
        if (videos?[indexPath.row] != nil) {
            let url = "http://img.youtube.com/vi/\(videos[indexPath.row].key!)/0.jpg"
            cell.picture.downloadImageURL(path: url)
            cell.titleLabel.text = videos[indexPath.row].name
            cell.video = videos?[indexPath.row]
        }
        cell.tag = indexPath.row
        return cell
    }
}

class VideomovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var video: VideosMDB?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.roundCorners(value: 5)
    }
    
    @IBAction func play(_ sender: Any) {
        if (video != nil) {
            if let url = video?.key {
                if let youtubeURL = URL(string: "youtube://\(url)"),
                    UIApplication.shared.canOpenURL(youtubeURL) {
                    // redirect to app
                    UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
                } else if let youtubeURL = URL(string: "https://www.youtube.com/watch?v=\(url)") {
                    // redirect through safari
                    UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

extension VideoMovieTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 117)
    }
}



