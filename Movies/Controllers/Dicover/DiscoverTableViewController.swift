//
//  DiscoverTableViewController.swift
//  Movies
//
//  Created by Andrea Spinazzola on 05/02/2019.
//  Copyright © 2019 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift

class DiscoverTableViewController: UITableViewController {
    
    var friends: [UserFirebase]!
    
    var suggestedMovies = [MovieDetailedMDB]()
    var colorsSuggestedMovies = [UIColor]()
    var posterSuggestedMovies = [UIImage]()
    
    var popularPersons = [PersonResults]()
    var inTheaters = [MovieMDB]()
    
    var popularMovies = [MovieDetailedMDB]()
    
    let genres = ["Action", "Adventure", "Animation", "Comedy"]

    override func viewDidLoad() {
        super.viewDidLoad()
        let headerNib = UINib.init(nibName: "TitleHeader", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "TitleHeader")
        
        self.showSpinner(onView: self.view)
        let myGroup = DispatchGroup()
        
        FriendSystem.system.addFollowingObserver {
            if(FriendSystem.system.followingList != nil){
                self.friends = FriendSystem.system.followingList
                if self.friends != nil {
                    for friend in self.friends {
                        myGroup.enter()
                        let sortedArray = friend.moviesWatchedId!.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
                        friend.moviesWatchedId = sortedArray
                        myGroup.leave()
                    }
                }
            }
        }
        
        var ids = [120, 671, 674, 675, 708, 804, 922, 1023]
        for i in ids {
            myGroup.enter()
            MovieMDB.movie(movieID: i) { (client, movie) in
                if(movie != nil) {
                    if let path = movie?.poster_path {
                        myGroup.enter()
                        let imageView = UIImageView()
                        imageView.downloadImage(path: path, placeholder: #imageLiteral(resourceName: "background")) {
                            if let image = imageView.image {
                                image.getColors({ (color) in
                                    self.colorsSuggestedMovies.append(color.primary)
                                    self.posterSuggestedMovies.append(image)
                                    self.suggestedMovies.append(movie!)
                                    myGroup.leave()
                                })
                            }
                        }
                    }
                }
                myGroup.leave()
            }
        }
        
        myGroup.enter()
        PersonMDB.popular(page: 1) { (client, persons) in
            if(persons != nil) {
                self.popularPersons = persons!
            }
            myGroup.leave()
        }
        
        myGroup.enter()
        MovieMDB.popular(language: "en", page: 1) { (client, movies) in
            if(movies != nil) {
                for i in movies! {
                    myGroup.enter()
                    MovieMDB.movie(movieID: i.id) { (client, movie) in
                        if(movie != nil) {
                            self.popularMovies.append(movie!)
                        }
                        myGroup.leave()
                    }
                }
            }
            myGroup.leave()
        }
        
        myGroup.enter()
        MovieDetailedMDB.nowplaying(language: "en", page: 1) { (client, movies) in
            if let movies = movies {
                self.inTheaters = movies
            }
            myGroup.leave()
        }
        
        myGroup.notify(queue: .main) {
            self.tableView.reloadData()
            self.removeSpinner()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.row == 0 && indexPath.section == 0) {
            return 90
        }
        if(indexPath.row == 0 && indexPath.section == 1) {
            return 210
        }
        if(indexPath.row == 0 && indexPath.section == 2) {
            return 340
        }
        if(indexPath.row == 0 && indexPath.section == 3) {
            return 160
        }
        if(indexPath.row == 0 && indexPath.section == 4) {
            return 116
        }
        if(indexPath.row == 0 && indexPath.section == 5) {
            return 260
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TitleHeader") as! HeaderView
        switch section {
            case 0:
                return nil
            case 1:
                headerView.headerTitle.text = "Activities"
                headerView.rightButton.isHidden = true
            case 2:
                headerView.headerTitle.text = "In Theatres"
                headerView.rightButton.isHidden = false
            case 3:
                headerView.headerTitle.text = "Suggested"
                headerView.rightButton.isHidden = true
            case 4:
                headerView.headerTitle.text = "Popular People"
                headerView.rightButton.isHidden = true
            case 5:
                headerView.headerTitle.text = "Popular Movies"
                headerView.rightButton.isHidden = true
            
            default: break
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 0
        }
        if(section == 1) {
            return 30
        }
        return 50
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0 && indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Genres", for: indexPath) as! GenresTableViewCell
            cell.genres = genres
            return cell
        }
        if(indexPath.row == 0 && indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WatchedFriends", for: indexPath) as! WatchedFriendsTableViewCell
            cell.friends = friends
            cell.friendsCollectionView.reloadData()
            cell.moviesCollectionView.reloadData()
            return cell
        }
        if(indexPath.row == 0 && indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "inTheathers", for: indexPath) as! InTheatersTableViewCell
            cell.movies = inTheaters
            cell.moviesCollectionView.reloadData()
            return cell
        }
        if(indexPath.row == 0 && indexPath.section == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedMoviesTableViewCell", for: indexPath) as! SuggestedMoviesTableViewCell
            cell.movies = suggestedMovies
            cell.colors = colorsSuggestedMovies
            cell.posters = posterSuggestedMovies
            cell.moviesCollectionView.reloadData()
            return cell
        }
        if(indexPath.row == 0 && indexPath.section == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "popularPeopleTableViewCell", for: indexPath) as! PopularPeopleTableViewCell
            cell.people = popularPersons
            cell.peopleCollectionView.reloadData()
            return cell
        }
        if(indexPath.row == 0 && indexPath.section == 5) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Popular", for: indexPath) as! PopularTableViewCell
            cell.movies = popularMovies
            cell.moviesCollectionView.reloadData()
            return cell
        }

        return UITableViewCell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "discoverToMovie" {
            if let collectionCell:  MoviesFriendsCollectionViewCell = sender as? MoviesFriendsCollectionViewCell {
                if let collectionView: UICollectionView = collectionCell.superview as? UICollectionView {
                    if let destination = segue.destination as? MovieInfoViewController {
                        let indexPath = IndexPath(row: 0, section: 0)
                        let cell = tableView.cellForRow(at: indexPath) as! WatchedFriendsTableViewCell
                        let vc = segue.destination as! MovieInfoViewController
                        let movie = friends[cell.indexSelected].moviesWatchedId![collectionCell.tag]
                        vc.id = movie.id
                        self.title = ""
                    }
                }
            }
        }
        
        if segue.identifier == "genre" {
            if let collectionCell:  GenreCollectionViewCell = sender as? GenreCollectionViewCell {
                if let collectionView: UICollectionView = collectionCell.superview as? UICollectionView {
                    if let destination = segue.destination as? DiscoverCollectionViewController {
                        let vc = segue.destination as! DiscoverCollectionViewController
                        let tag = collectionCell.tag
                        let g = genres[collectionCell.tag]
                        var genresIndex = [Int]()
                        for i in getGenresList(){
                            if i == g {
                                genresIndex.append(1)
                            } else {
                                genresIndex.append(0)
                            }
                        }
                        vc.genresIndex = genresIndex
                    }
                }
            }
        }
    }
}
