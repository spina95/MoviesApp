//
//  PersonInfoTableViewCell.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 27/06/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift

class BiographyPersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var expand: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class TextPersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class FilmographyTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var credits: PersonMovieCredits?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension FilmographyTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (credits != nil) {
            if ((credits?.cast.count)! + (credits?.crew.count)! < 16) {
                return (credits?.cast.count)! + (credits?.crew.count)!
            }
            return 16
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filmographyCollectionCell", for: indexPath) as! FilmographyCollectionViewCell
        if(indexPath.row < (credits?.cast.count)!) {
            if (credits?.cast[indexPath.row].poster_path != nil) {
                cell.picture.downloadImage(path: credits?.cast[indexPath.row].poster_path, placeholder: #imageLiteral(resourceName: "background"))
            }
            if let role = credits?.cast[indexPath.row].character {
                cell.roleLabel.text = role
            }
            MovieMDB.movie(movieID: credits?.cast[indexPath.row].id, completion: { (client, movie) in
                if(movie != nil) {
                    if let voteAverage = movie?.vote_average {
                        cell.averageLabel.text = String(format: "%.1f", voteAverage)
                        cell.averageGraph.vote = voteAverage
                        cell.setNeedsDisplay()
                    }
                }
            })
            cell.tag = indexPath.row - (credits?.cast.count)!
            cell.tag = indexPath.row
        } else {
            if (credits?.crew[indexPath.row - (credits?.cast.count)!].poster_path != nil) {
                cell.picture.downloadImage(path: credits?.crew[indexPath.row - (credits?.cast.count)!].poster_path, placeholder: #imageLiteral(resourceName: "background"))
            }
            if let role = credits?.crew[indexPath.row - (credits?.cast.count)!].job {
                cell.roleLabel.text = role
            }
            if (credits?.crew[indexPath.row - (credits?.cast.count)!].id != nil) {
            MovieMDB.movie(movieID: credits?.crew[indexPath.row - (credits?.cast.count)!].id, completion: { (client, movie) in
                if(movie != nil) {
                    if let voteAverage = movie?.vote_average {
                        cell.averageLabel.text = String(format: "%.1f", voteAverage)
                        cell.averageGraph.vote = voteAverage
                        cell.setNeedsDisplay()
                    }
                }
            })
            }
            cell.tag = indexPath.row - (credits?.cast.count)!
        }
        return cell
    }
}

class FilmographyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var averageGraph: GraphView!
    @IBOutlet weak var voteGraph: GraphView!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        view.roundCorners(value: 4)
    }
    
}

extension FilmographyTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 144, height: 217)
    }
}

// Image
class ImagesPersonTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var images: [Images_MDB]!
    
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

extension ImagesPersonTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(images != nil){
        if (images.count < 16) {
            return images.count
            }}
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagePersonCollectionCell", for: indexPath) as! ImagePersonCollectionViewCell
        if let img = images {
            if (img[indexPath.row] != nil) {
                cell.picture.downloadImage(path: img[indexPath.row].file_path!, placeholder: #imageLiteral(resourceName: "background"))
            }
            cell.tag = indexPath.row
        }
        return cell
    }
}

class ImagePersonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var picture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.roundCorners(value: 5)
    }
}

extension ImagesPersonTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 117)
    }
}



