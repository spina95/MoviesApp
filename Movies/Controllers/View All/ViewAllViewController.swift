//
//  ViewAllViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 08/07/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift

class ViewAllViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, isAbleToReceiveData {
    
    @IBOutlet weak var tableView: UITableView!
    
    var moviesId = [(Int, Date?)]()
    var movies = [MovieDetailedMDB]()
    var sortedMode: Int = 0
    var inverted: Bool = false
    var previousSortedMode: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.showSpinner(onView: self.view)
        let myGroup = DispatchGroup()
        var moviesDetailed = [MovieDetailedMDB]()
        for i in moviesId {
            myGroup.enter()
            MovieMDB.movie(movieID: i.0, language: "en") { (client, movie) in
                if(movie != nil) {
                    moviesDetailed.append(movie!)
                    myGroup.leave()
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            self.movies.removeAll()
            self.movies = moviesDetailed
            self.tableView.reloadData()
            self.removeSpinner()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func pass(data: Int, inverted: Bool) { //conforms to protocol
        // implement your own implementation
        self.sortedMode = data
        self.inverted = inverted
        if(previousSortedMode != sortedMode) {
            tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            sort()
        }
        if(inverted == true) {
            moviesId.reverse()
            movies.reverse()
        }
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "allMoviesCell", for: indexPath) as! MovieViewAllTableViewCell
        if(moviesId.count == movies.count) {
            let movieid = moviesId[indexPath.row]
            let movie = movies[indexPath.row]
            if (movie.poster_path != nil) {
                cell.poster.downloadImage(path:movie.poster_path, placeholder: #imageLiteral(resourceName: "background"))
            }
            if let voteAverage = movie.vote_average {
                cell.averageLabel.text = String(format: "%.1f", voteAverage)
                cell.averageVote.endPointValue = CGFloat(voteAverage)
            }
            cell.userLabel.isHidden = true
            cell.userVote.isHidden = true
            if let votes = currentUserFirebase?.votes {
                for i in votes{
                    if(i.id == movie.id) {
                        cell.userVote.endPointValue = CGFloat(i.vote)
                        cell.userLabel.text = String(i.vote)
                        cell.userLabel.isHidden = false
                        cell.userVote.isHidden = false
                    }
                }
            }
            cell.title.text = movie.title
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            let date = dateFormatter.date(from:(movie.release_date)!)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date!)
            let year = String(components.year!)
            let runtime = String((movie.runtime)! / 60) + "h " + String((movie.runtime)! % 60) + "min"
            var string = year + " • " + runtime
            cell.info.text = string
            return cell
        }
        return UITableViewCell()
    }
    
    func sort() {
        switch sortedMode {
            case 0:
                // Date added
                moviesId.sort(by: {$0.1! > $1.1!})
                var sorted = [MovieDetailedMDB]()
                for i in moviesId {
                    for j in movies {
                        if(i.0 == j.id) {
                            sorted.append(j)
                        }
                    }
                }
                movies = sorted
                return
            // Alphabetically
            case 1:
                movies.sort(by: {$0.title! < $1.title!})
                var sortedIds = [(Int, Date?)]()
                for i in movies {
                    var found = 0
                    for j in moviesId {
                        if(j.0 == i.id && found == 0){
                            sortedIds.append(j)
                            found = 1
                        }
                    }
                }
                moviesId.removeAll()
                moviesId = sortedIds
                sortedIds.removeAll()
                return
            // Average Rating
            case 2:
                movies.sort(by: {$0.vote_average! > $1.vote_average!})
                var sortedIds = [(Int, Date?)]()
                for i in movies {
                    var found = 0
                    for j in moviesId {
                        if(j.0 == i.id && found == 0){
                            sortedIds.append(j)
                            found = 1
                        }
                    }
                }
                moviesId.removeAll()
                moviesId = sortedIds
                sortedIds.removeAll()
                return
            // User Rating
            case 3:
                var votes = currentUserFirebase?.votes
                votes?.sort(by: {$0.vote > $1.vote})
                var sortedIds = [(Int, Date?)]()
                var noVoteIds = [(Int, Date?)]()
                for i in votes! {
                    var found = 0
                    for j in moviesId {
                        if(j.0 == i.id && found == 0){
                            sortedIds.append(j)
                            found = 1
                        }
                    }
                }
                for i in moviesId {
                    var present = 0
                    for j in sortedIds {
                        if(j.0 == i.0) {
                            present = 1
                        }
                    }
                    if(present == 0){
                        noVoteIds.append(i)
                    }
                }
                sortedIds.append(contentsOf: noVoteIds)
                var sorted = [MovieDetailedMDB]()
                for i in sortedIds {
                    for j in movies {
                        if(i.0 == j.id) {
                            sorted.append(j)
                        }
                    }
                }
                movies = sorted
                moviesId = sortedIds
                return
            //Runtime
            case 4:
                movies.sort(by: {$0.runtime! > $1.runtime!})
                var sortedIds = [(Int, Date?)]()
                for i in movies {
                    var found = 0
                    for j in moviesId {
                        if(j.0 == i.id && found == 0){
                            sortedIds.append(j)
                            found = 1
                        }
                    }
                }
                moviesId.removeAll()
                moviesId = sortedIds
                sortedIds.removeAll()
                return
            default:
                return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sort" {
            let destination = segue.destination as? MovieInfoViewController
            let vc = segue.destination as! SortTableViewController
            vc.selectedIndex = sortedMode
            vc.inverted = inverted
            vc.delegate = self
            vc.indexToPass = sortedMode
        }
    }
}

