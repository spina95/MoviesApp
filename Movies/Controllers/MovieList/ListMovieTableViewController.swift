//
//  ListMovieTableViewController.swift
//  Movies
//
//  Created by Andrea Spinazzola on 15/02/2019.
//  Copyright © 2019 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift
import HGCircularSlider

class ListMovieTableViewController: UITableViewController {
    
    var list: List!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = list.name
      
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 0) {
            return 1
        }
        if(section == 1) {
            return list.moviesId.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) {
            return 55
        }
        if(indexPath.section == 1) {
            return 120
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "sharedCell", for: indexPath) as! SharedTableViewCell
            if(list.shared == true) {
                cell.toogle.setOn(true, animated: false)
            } else {
                cell.toogle.setOn(false, animated: false)
            }
            cell.toogle.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            return cell
        }
        
        if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "moviesCell", for: indexPath) as! MovieListTableViewCell
            let movieid = list.moviesId[indexPath.row]
            MovieMDB.movie(movieID: movieid, completion: { (client, movie) in
                if (movie?.poster_path != nil) {
                    cell.poster.downloadImage(path:movie?.poster_path, placeholder: #imageLiteral(resourceName: "background"))
                }
                if let voteAverage = movie?.vote_average {
                    cell.averageLabel.text = String(format: "%.1f", voteAverage)
                    cell.averageVote.endPointValue = CGFloat(voteAverage)
                }
                cell.userLabel.isHidden = true
                cell.userVote.isHidden = true
                if let votes = currentUserFirebase?.votes {
                    for i in votes{
                        if(i.id == movie?.id) {
                            cell.userVote.endPointValue = CGFloat(i.vote)
                            cell.userLabel.text = String(i.vote)
                            cell.userLabel.isHidden = false
                            cell.userVote.isHidden = false
                        }
                    }
                }
                cell.title.text = movie?.title
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let date = dateFormatter.date(from:(movie?.release_date)!)
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day, .hour], from: date!)
                let year = String(components.year!)
                let runtime = String((movie?.runtime)! / 60) + "h " + String((movie?.runtime)! % 60) + "min"
                var string = year + " • " + runtime
                cell.info.text = string
            })
            cell.check.setImage(UIImage(named: "add"), for: .normal)
            cell.check.layer.borderColor = yellowColor.cgColor
            cell.check.roundCorners(value: Double(Int(cell.check.frame.height/2)))
            cell.check.backgroundColor = UIColor.clear
            if let moviesWatched = currentUserFirebase?.moviesWatchedId {
                var contain = 0
                for i in moviesWatched {
                    if (i.id == movieid) {
                        contain = 1
                    }
                }
                if(contain == 1) {
                    cell.check.setImage(nil, for: .normal)
                    cell.check.layer.borderColor = UIColor.clear.cgColor
                    cell.check.setTitle("✓", for: .normal)
                    cell.check.backgroundColor = greenColor
                }
            }
            if let favourites = currentUserFirebase?.favouritesMoviesId {
                if(favourites.contains(movieid)) {
                    cell.check.setImage(#imageLiteral(resourceName: "favorite-heart-button"), for: .normal)
                    cell.check.backgroundColor = UIColor.clear
                    cell.check.layer.borderColor = UIColor.clear.cgColor
                }
            }
            cell.check.tag = indexPath.row
            cell.check.addTarget(self, action: #selector(self.buttonAction(_sender:)), for: UIControl.Event.touchUpInside)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(indexPath.section == 1) {
            if editingStyle == .delete {
                self.list.removeMovie(id: self.list.moviesId[indexPath.row]) { (error) in
                    if(error == nil) {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        if(sender.isOn) {
            list.changePrivateShared(value: true) { (error) in
            
            }
        } else {
            list.changePrivateShared(value: false) { (error) in
                
            }
        }
    }
    
    @objc func buttonAction(_sender:UIButton!) {
        let movieid = list.moviesId[_sender.tag]
        if(currentUserFirebase?.favouritesMoviesId != nil) {
            if((currentUserFirebase?.favouritesMoviesId?.contains(movieid))!) {
                UserFirebase.removeMovieFavourites(id: movieid, completion: { (error) in
                    self.tableView.reloadData()
                    return
                })
            }
        }
        if(currentUserFirebase?.moviesWatchedId != nil) {
            var contain = 0
            for i in (currentUserFirebase?.moviesWatchedId!)! {
                if(i.0 == movieid) {
                    contain = 1
                }
            }
            if(contain == 1) {
                UserFirebase.removeMovieWatched(id: movieid, completion: { (error) in
                    if(error == nil) {
                        self.tableView.reloadData()
                        return
                    }
                })
            }
        }
        UserFirebase.addMovieWatched(id: movieid, completion: { (error) in
            if(error == nil) {
                if(currentUserFirebase?.moviesWatchedId == nil) {
                    currentUserFirebase?.moviesWatchedId = [(Int, Date)]()
                }
                self.tableView.reloadData()
                return
            }
            else {
                print(error)
                return
            }
        })
    }
    
    @IBAction func deleteList(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to remove this list?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.list.removeList(completion: { (error) in
                if(error == nil) {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true)
    }
    
    
}

class SharedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var toogle: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class MovieListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var averageVote: CircularSlider!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var userVote: CircularSlider!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var check: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        poster.roundCorners(value: 2)
        check.layer.cornerRadius = check.frame.height/2
        check.layer.borderColor = yellowColor.cgColor
        check.layer.borderWidth = 1
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
