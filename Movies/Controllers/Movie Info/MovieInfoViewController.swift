//
//  MovieInfoViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 01/08/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import UICircularProgressRing
import TMDBSwift
import HGCircularSlider
import FirebaseStorage

class MovieInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, popupPassDataBack {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var runtime: UILabel!
    @IBOutlet weak var watchers: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var addButon: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var friendPhoto: UIImageView!
    @IBOutlet weak var friendButton: RoundButton!
    @IBOutlet weak var movieViewHeigth: NSLayoutConstraint!
    @IBOutlet weak var addButtonHeigth: NSLayoutConstraint!
    @IBOutlet weak var posterHeigth: NSLayoutConstraint!
    @IBOutlet weak var watchersTop: NSLayoutConstraint!
    @IBOutlet weak var runtimeTop: NSLayoutConstraint!
    @IBOutlet weak var releaseTop: NSLayoutConstraint!
    @IBOutlet weak var friendTop: NSLayoutConstraint!
    @IBOutlet weak var friendButtonHeigth: NSLayoutConstraint!
    @IBOutlet weak var friendPhotoheigth: NSLayoutConstraint!
    @IBOutlet weak var voteCircularSlider: CircularSlider!
    
    var id: Int!
    var movieDetailed: MovieDetailedMDB?
    var credits: MovieCreditsMDB?
    var similarMovies: [MovieMDB]?
    var images: ImagesMDB?
    var videos: [VideosMDB]?
    var watchedMoviesId: [Int]?
    var vote: Int = -1
    var tempVote: Int?
    
    var feelingIndexSelected = -1
    var actInd = UIActivityIndicatorView()
    
    var dataToPass = 0 // 1 se si passa cast 2 se si passa crew 3 se si passa array crew
    var personToPass: Any?
    var crewToPass: [Any]?
    
    var friendsWatchMovie = [UserFirebase]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftItemsSupplementBackButton = true

        tableView.delegate = self
        tableView.dataSource = self
        
        let headerNib = UINib.init(nibName: "HeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        self.showSpinner(onView: self.view)
        
        let myGroup = DispatchGroup()
        
        myGroup.enter()
        MovieMDB.movie(movieID: id) { (client, movieDetailed) in
            if let movieDetailed = movieDetailed{
                self.movieDetailed = movieDetailed
                MovieMDB.credits(movieID: self.id, completion: { (client, credits) in
                    self.credits = credits
                    MovieMDB.similar(movieID: self.id, page: 1, completion: { (client, movies) in
                        self.similarMovies = movies
                        MovieMDB.images(movieID: self.id, completion: { (client, images) in
                            self.images = images
                            MovieMDB.videos(movieID: self.id, completion: { (client, videos) in
                                self.videos = videos
                                if (currentUserFirebase?.followings != nil) {
                                    for i in 0...((currentUserFirebase?.followings?.count)! - 1) {
                                        myGroup.enter()
                                        if let user = currentUserFirebase?.followings![i] {
                                            UserFirebase.getUserByUID(id: (currentUserFirebase?.followings![i].uid)!) { (user) in
                                                if(user != nil) {
                                                    currentUserFirebase?.followings![i] = user!
                                                    myGroup.leave()
                                                }
                                            }
                                        } else {
                                        myGroup.leave()
                                    }
                                }
                                    
                                }
                                myGroup.leave()
                            })
                        })
                    })
                })
            }
        }
        
        myGroup.notify(queue: .main) {
            self.loadMovieInfo()
            self.tableView.reloadData()
            self.removeSpinner()
        }
    }
    
    func shouldHideSection(section: Int) -> Bool {
        switch section {
        case 0:  // Hide this section based on condition below
            var hide = 0
            if let moviesWatched = currentUserFirebase?.moviesWatchedId {
                var contain = 0
                for i in moviesWatched {
                    if(i.id == movieDetailed?.id) {
                        contain = 1
                    }
                }
                if(contain == 1) {
                        return false
                }
                hide += 1
            }
            var users = [UserFirebase]()
            if let friends = currentUserFirebase?.followings {
                for i in friends {
                    if let movies = i.moviesWatchedId {
                        for j in movies {
                            if(j.id == movieDetailed?.id) {
                                users.append(i)
                            }
                        }
                    }
                }
            }
            if(users.count != 0) {
                return false
            }
            hide += 1
            if(hide == 2) {
                return true
            }
            return false
        
        default:
            return false
        }
    }

    func shouldHideRow (section: Int) -> Int {
        switch section {
        case 0:  // Hide this section based on condition below
            if let moviesWatched = currentUserFirebase?.moviesWatchedId {
                var contain = 0
                for i in moviesWatched {
                    if(i.id == movieDetailed?.id) {
                        contain = 1
                    }
                }
                if(contain == 0) {
                    return 1
                }
            }
            var users = [UserFirebase]()
            if let friends = currentUserFirebase?.followings {
                for i in friends {
                    if let movies = i.moviesWatchedId {
                        for j in movies {
                            if(j.id == movieDetailed?.id) {
                                users.append(i)
                            }
                        }
                    }
                }
            }
            if(users.count == 0) {
                return 2
            }
            return 0
            
        default:
            return 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        dataToPass = 0
        let offset = tableView.contentOffset.y;
        if(offset > 2) {
            self.title = movieDetailed?.title
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch  section {
        case 0:
            if(shouldHideSection(section: section) == true) { return 0}
            return 2
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 3
        case 5:
            return 4
        case 6:
            return 1
        case 7:
            return 1
        case 8:
            return 1
        default:
            return 0
        }
    }
    
    // Hide footer(s)
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return shouldHideSection(section: section) ? 0.1 : 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.row == 0 && indexPath.section == 0) {
            if let moviesWatched = currentUserFirebase?.moviesWatchedId {
                var contain = 0
                for i in moviesWatched {
                    if(i.id == movieDetailed?.id) {
                        contain = 1
                    }
                }
                if(contain == 1) {
                    return 50
                }
            }
            return 0.01
        }
        if (indexPath.row == 1 && indexPath.section == 0) {
            var users = [UserFirebase]()
            if let friends = currentUserFirebase?.followings {
                for i in friends {
                    if let movies = i.moviesWatchedId {
                        for j in movies {
                            if(j.id == movieDetailed?.id) {
                                users.append(i)
                            }
                        }
                    }
                }
            }
            if(users.count != 0) {
                return 50
            }
            return 0.01
        }
        // review
        if (indexPath.row == 0 && indexPath.section == 1) {
            return 194
        }
        if (indexPath.row == 1 && indexPath.section == 1) {
            return 50
        }
        //plot
        if (indexPath.row == 0 && indexPath.section == 2) {
            return UITableView.automaticDimension
        }
        //cast
        if (indexPath.row == 0 && indexPath.section == 3) {
            if(credits?.cast.count != 0) { return 150 }
            else { return 0 }
        }
        //crew
            if (indexPath.row == 0 && indexPath.section == 4) {
                if(credits?.crew != nil) {
                    for member in (credits?.crew)! {
                        if (member.department == "Directing" && member.job == "Director") {
                            return 50
                        }
                    }
                }
                return 0
            }
            if (indexPath.row == 1 && indexPath.section == 4) {
                if(credits?.crew != nil) {
                    for member in (credits?.crew)! {
                        if (member.department == "Writing" && member.job == "Screenplay") {
                            return 50
                        }
                    }
                }
                return 0
            }
        if (indexPath.row == 2 && indexPath.section == 4) {
            return 50
        }
        
        //infos
            if( indexPath.row == 0 && indexPath.section == 5) {
                if( movieDetailed?.release_date != nil) {return 50}
                return 0
            }
            if( indexPath.row == 1 && indexPath.section == 5) {
                if( movieDetailed?.production_countries != nil) {return 50}
                return 0
            }
            if( indexPath.row == 2 && indexPath.section == 5) {
                if( movieDetailed?.original_language != nil) {return 50}
                return 0
            }
            if( indexPath.row == 3 && indexPath.section == 5) {
                if( movieDetailed?.spoken_languages != nil) {return 50}
                return 0
            }
        //images
        if (indexPath.row == 0 && indexPath.section == 6) {
            if(images?.backdrops.count != 0) { return 140 }
            else { return 0 }
        }
        //video
        if (indexPath.row == 0 && indexPath.section == 7) {
            if(videos?.count != 0) { return 140 }
            else { return 0 }
        }
        //similar movies
        if (indexPath.row == 0 && indexPath.section == 8) {
            if (similarMovies?.count != 0) { return 220 }
            else { return 0 }
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! HeaderView
        switch section {
        case 0:
            headerView.headerTitle.text = ""
            headerView.rightButton.isHidden = true
        case 1:
            headerView.headerTitle.text = "COMMUNITY"
            headerView.rightButton.isHidden = true
        case 2:
            headerView.headerTitle.text = "PLOT"
            if(movieDetailed?.genres != nil){
                var text = String()
                var count = 1
                for i in (movieDetailed?.genres)! {
                    if((count == movieDetailed?.genres.count && count < 3) || count == 3) {
                        text.append(i.name!)
                    } else if(count < (movieDetailed?.genres.count)! && count < 3) {
                        text.append(i.name! + " ・ ")
                    }
                    count += 1
                }
                let attributedText = NSMutableAttributedString(string: text)
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .light)], range: NSMakeRange(0, text.characters.count)) // Blue color attribute
                headerView.rightButton.setAttributedTitle(attributedText, for: .normal)
                headerView.rightButton.isHidden = false
                headerView.rightButton.isEnabled = false
            }
        case 3:
            headerView.headerTitle.text = "CAST"
            headerView.rightButton.isHidden = false
            headerView.rightButton.addTarget(self, action:#selector(viewAllSegue(sender:)), for: .touchUpInside)
            headerView.rightButton.tag = 2
        case 4:
            headerView.headerTitle.text = "CREW"
            headerView.rightButton.isHidden = true
        case 5:
            headerView.headerTitle.text = "INFO"
            headerView.rightButton.isHidden = true
        case 6:
            headerView.headerTitle.text = "PHOTOS"
            headerView.rightButton.addTarget(self, action:#selector(viewAllSegue(sender:)), for: .touchUpInside)
            headerView.rightButton.tag = 5
        case 7:
            headerView.headerTitle.text = "VIDEOS"
            headerView.rightButton.isHidden = true
        case 8:
            headerView.headerTitle.text = "SIMILAR MOVIES"
            headerView.rightButton.isHidden = true
        
        default:
            headerView.headerTitle.text = ""
            headerView.rightButton.isHidden = true
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) { return 0 }
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0 && indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friends", for: indexPath) as! friendsTableViewCell
            if let movies = currentUserFirebase?.moviesWatchedId {
                for i in movies {
                    if(i.id == movieDetailed?.id){
                        let df = DateFormatter()
                        df.dateFormat = "d MMMM yyyy"
                        let now = df.string(from: i.date)
                        cell.label.text = "Watched on " + now
                        cell.button2.isHidden = true
                        cell.labelConstraint.constant -= 28
                        cell.button1.setTitle("✓", for: .normal)
                        cell.button1.setImage(nil, for: .normal)
                        cell.button1.backgroundColor = greenColor
                    }
                }
            }
        }
        
        if(indexPath.row == 1 && indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friends", for: indexPath) as! friendsTableViewCell
            var users = [UserFirebase]()
            if let friends = currentUserFirebase?.followings {
                for i in friends {
                    if let movies = i.moviesWatchedId {
                        for j in movies {
                            if(j.id == movieDetailed?.id) {
                                users.append(i)
                            }
                        }
                    }
                }
            }
            if(users.count != 0) {
                if(users.count == 1) {
                    cell.label.text = users[0].username! + " watched this movie"
                    UserFirebase.downloadUserImage(user: users[0]) { (user) in
                        if(user != nil) {
                            cell.button1.setImage(user.profilePicture, for: .normal)
                            cell.accessoryType = .disclosureIndicator
                        }
                    }
                    cell.button2.isHidden = true
                    cell.labelConstraint.constant -= 28
                    
                } else {
                    cell.label.text = users[0].username! + "and " + String(users.count - 1) + " other friends watched this movie"
                    UserFirebase.downloadUserImage(user: users[0]) { (user) in
                        if(user != nil) {
                            cell.button2.setImage(user.profilePicture, for: .normal)
                        }
                    }
                }
            }
            return cell
        }

        if(indexPath.row == 0 && indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "votes", for: indexPath) as! VotesTableViewCell
            if let voteAverage = movieDetailed?.vote_average {
                cell.averageLabel.text = String(format: "%.1f", voteAverage)
                cell.averageGraph.endPointValue = CGFloat(voteAverage)
                
                if let votes = currentUserFirebase?.votes {
                    for vote in votes {
                        if (vote.id == movieDetailed?.id) {
                            self.vote = Int(vote.vote)
                            cell.voteSlider.endPointValue = CGFloat(self.vote)
                        }
                    }
                }
                if self.vote == -1 {
                    cell.voteLabel.text = "?"
                    cell.voteSlider.endPointValue = CGFloat(self.vote)
                } else {
                    cell.voteLabel.text = String(self.vote)
                    cell.voteSlider.endPointValue = CGFloat(self.vote)
                }
            }
            return cell
        }
        
        if(indexPath.row == 0 && indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Plot", for: indexPath) as! PlotTableViewCell
            if(movieDetailed?.overview != "") { cell.overview.text = movieDetailed?.overview}
            else { cell.overview.text = "Plot not avaiable"}
            return cell
        }
        
        if(indexPath.row == 0 && indexPath.section == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actors", for: indexPath) as! ActorsTableViewCell
            if let a = self.credits?.cast {
                cell.actors = a
            } else {
                cell.isHidden = true
            }
            cell.collectionView.reloadData()
            return cell
        }
        
        if(indexPath.row == 0 && indexPath.section == 4) {
            if (credits?.crew != nil) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextTableViewCell
                var directors = [CrewMDB]()
                for member in (credits?.crew)! {
                    if (member.department == "Directing" && member.job == "Director") {
                        directors.append(member)
                    }
                }
                var count = 0
                var title = "Director: "
                var directorsString = String()
                for a in directors {
                    if (count == 0) {
                        directorsString = directorsString + a.name!
                    }
                    else if (count == directors.count - 1) {
                        directorsString = directorsString + " and " + a.name!
                    } else {
                        directorsString = directorsString + ", " + a.name!
                    }
                    count = count + 1
                    cell.accessoryType = .disclosureIndicator
                }
                
                var string = title + directorsString
                let attributedText = NSMutableAttributedString(string: string)
                
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)], range: NSMakeRange(title.characters.count, directorsString.characters.count)) // Blue color attribute
                cell.label.attributedText = attributedText
                cell.accessoryType = .disclosureIndicator
                if(directors.count == 0) { cell.isHidden = true}
                return cell
            }
        }
        
        if(indexPath.row == 1 && indexPath.section == 4) {
            
            if (credits?.crew != nil) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextTableViewCell
                var screenwriters = [CrewMDB]()
                for member in (credits?.crew)! {
                    if (member.department == "Writing" && member.job == "Screenplay") {
                        screenwriters.append(member)
                    }
                }
                var count = 0
                var title = "Screenwriters: "
                var screenwritersString = String()
                for a in screenwriters {
                    if (count == 0) {
                        screenwritersString = screenwritersString + a.name!
                    }
                    else if (count == screenwriters.count - 1) {
                        screenwritersString = screenwritersString + " and " + a.name!
                    } else {
                        screenwritersString = screenwritersString + ", " + a.name!
                    }
                    count = count + 1
                }
                var string = title + screenwritersString
                let attributedText = NSMutableAttributedString(string: string)
                
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)], range: NSMakeRange(title.characters.count, screenwritersString.characters.count)) // Blue color attribute
                cell.label.attributedText = attributedText
                if(screenwriters.count == 1) {
                    cell.accessoryType = .none
                }
                if(screenwriters.count == 0) { cell.isHidden = true}
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        }
        
        if(indexPath.row == 2 && indexPath.section == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextTableViewCell
            cell.label.text = "All cast and crew"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        if(indexPath.row == 0 && indexPath.section == 5) {
            if (movieDetailed?.release_date != nil) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextTableViewCell
                var title = "Release date: "
                var date = convertDateFormatter(date: (movieDetailed?.release_date!)!)
                var string = title + date
                let attributedText = NSMutableAttributedString(string: string)
                
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)], range: NSMakeRange(title.characters.count, date.characters.count)) // Blue color attribute
                cell.label.attributedText = attributedText
                if(date.characters.count == 0) { cell.isHidden = true}
                
                cell.accessoryType = .none
                return cell
            }
        }
        
        if(indexPath.row == 1 && indexPath.section == 5) {
            if (movieDetailed?.production_countries != nil) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextTableViewCell
                var title = "Countries: "
                var countries = String()
                var count = 0
                for a in (movieDetailed?.production_countries!)! {
                    if (count == 0) {
                        countries.append(a.name!)
                    }
                    else if (count == (movieDetailed?.production_countries?.count)! - 1) {
                        countries = countries + " and " + a.name!
                    } else {
                        countries = countries + ", " + a.name!
                    }
                    count = count + 1
                }
                
                var string = title + countries
                let attributedText = NSMutableAttributedString(string: string)
                
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)], range: NSMakeRange(title.characters.count, countries.characters.count)) // Blue color attribute
                cell.label.attributedText = attributedText
                cell.accessoryType = .none
                if ( movieDetailed?.production_countries?.count == 0) { cell.isHidden = true}
                return cell
            }
        }
        
        if(indexPath.row == 2 && indexPath.section == 5) {
            if (movieDetailed?.original_language != nil) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextTableViewCell
                var title = "Original language: "
                var languages = String()
                var count = 0
                if(movieDetailed?.original_language != nil) {
                    var language = movieDetailed?.original_language
                    language = LanguageHelper.getLanguageStringFrom(code: language!)
                    let string = title + language!
                    let attributedText = NSMutableAttributedString(string: string)
                
                    attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)], range: NSMakeRange(title.characters.count, (language?.characters.count)!)) // Blue color attribute
                    cell.label.attributedText = attributedText
                    cell.accessoryType = .none
                    if(movieDetailed?.original_language?.count == 0) { cell.isHidden = true}
                }
                return cell
            }
        }
        
        if(indexPath.row == 3 && indexPath.section == 5) {
            if (movieDetailed?.spoken_languages != nil) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextTableViewCell
                var title = "Languages spoken: "
                var languages = String()
                var count = 0
                for a in (movieDetailed?.spoken_languages!)! {
                    if (count == 0) {
                        languages.append(a.name!)
                    }
                    else if (count == (movieDetailed?.spoken_languages?.count)! - 1) {
                        languages = languages + " and " + a.name!
                    } else {
                        languages = languages + ", " + a.name!
                    }
                    count = count + 1
                }
                var string = title + languages
                let attributedText = NSMutableAttributedString(string: string)
                
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)], range: NSMakeRange(title.characters.count, languages.characters.count)) // Blue color attribute
                cell.label.attributedText = attributedText
                if(movieDetailed?.spoken_languages?.count == 1) {
                    cell.accessoryType = .none
                }
                if(movieDetailed?.spoken_languages?.count == 0) { cell.isHidden = true}
                return cell
            }
        }
        
        if(indexPath.row == 0 && indexPath.section == 6) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imagesMovieCell", for: indexPath) as! ImagesMovieTableViewCell
            if(images?.backdrops != nil) {
                cell.images = images!
            } else {
                cell.isHidden = true
            }
            cell.collectionView.reloadData()
            return cell
            }
        
        //Video
        if(indexPath.row == 0 && indexPath.section == 7) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "videoMovieCell", for: indexPath) as! VideoMovieTableViewCell
            if(videos != nil) {
                cell.videos = videos
            } else {
                cell.isHidden = true
            }
            cell.collectionView.reloadData()
            return cell
        }
        
        if(indexPath.row == 0 && indexPath.section == 8) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "similarMovieCell", for: indexPath) as! similarMovieTableViewCell
            if let a = similarMovies {
                cell.movies = a
            } else {
                cell.isHidden = true
            }
            cell.collectionView.reloadData()
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 2 && indexPath.section == 4) {
            dataToPass = 2
            self.performSegue(withIdentifier: "castViewAll", sender: self)
        }
        if(indexPath.row == 0 && indexPath.section == 4) {
            var directors = [CrewMDB]()
            for member in (credits?.crew)! {
                if (member.department == "Directing" && member.job == "Director") {
                    directors.append(member)
                }
            }
            if(directors.count == 1) {
                personToPass = directors[0]
                self.performSegue(withIdentifier: "personDetail", sender: self)
            }
            if(directors.count > 1) {
                dataToPass = 3
                crewToPass = directors
                self.performSegue(withIdentifier: "castViewAll", sender: self)
            }
        }
        
        if(indexPath.row == 1 && indexPath.section == 4) {
            var screenwriters = [CrewMDB]()
            for member in (credits?.crew)! {
                if (member.department == "Writing" && member.job == "Screenplay") {
                    screenwriters.append(member)
                }
            }
            if(screenwriters.count == 1) {
                personToPass = screenwriters[0]
                self.performSegue(withIdentifier: "personDetail", sender: self)
            }
            if(screenwriters.count > 1) {
                dataToPass = 3
                crewToPass = screenwriters
                self.performSegue(withIdentifier: "castViewAll", sender: self)
            }
        }
    }

    func loadMovieInfo (){

        addButon.roundCorners(value: 4)
        let window = UIApplication.shared.keyWindow!
        if let moviesWatched = currentUserFirebase?.moviesWatchedId {
            var contain = 0
            for i in moviesWatched {
                if(i.id == movieDetailed?.id) {
                    contain = 1
                }
            }
            if(contain == 1) {
            addButon.layer.backgroundColor = greenColor.cgColor
            addButon.setTitleColor(UIColor.white, for: .normal)
            addButon.setTitle("✓ Watched", for: .normal)
        } else {
            addButon.layer.borderColor = redColor.cgColor
            addButon.layer.borderWidth = 1
            }
        } else {
            addButon.layer.borderColor = redColor.cgColor
            addButon.layer.borderWidth = 1
        }
        if let favourites = currentUserFirebase?.favouritesMoviesId {
            if(favourites.contains((movieDetailed?.id)!)) {
                favouriteButton.setImage(#imageLiteral(resourceName: "favorite-heart-button"), for: .normal)
            }
        }
        
        friendPhoto.roundCorners(value: Double(Int(friendPhoto.frame.height/2)))
        
        poster.roundCorners(value: 2)
        
        if(movieDetailed?.poster_path != nil) {
            poster.downloadImage(path: movieDetailed?.poster_path!, placeholder: #imageLiteral(resourceName: "background"))
        }
        titleLabel.text = movieDetailed?.title
        if let duration = movieDetailed?.runtime {
            runtime.text = String(duration)
        } else {
            runtime.text = "?"
        }
        if(movieDetailed?.release_date != "") {
            let realeaseDate = movieDetailed?.release_date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            let date = dateFormatter.date(from:realeaseDate!)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date!)
            let finalDate = calendar.date(from:components)
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.long
            formatter.timeStyle = .medium
            let year = calendar.component(.year, from: finalDate!)
            releaseLabel.text = String(year)
        } else {
            releaseLabel.text = "?"
        }
        
        if(friendsWatchMovie.count != 0) {
            if(friendsWatchMovie.count == 1) {
                friendButton.setTitle("watched this", for: .normal)
            } else {
                friendButton.setTitle("+ " + String(friendsWatchMovie.count-1) + " friends", for: .normal)
            }
            if let profilePictureURL = friendsWatchMovie[0].profilePictureUrl {
                let filePath = "profile_images/\(profilePictureURL).png"
                let storageRef = Storage.storage().reference()
                storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                    let userPhoto = UIImage(data: data!)
                    self.friendPhoto.image = userPhoto
                })
            }
        } else {
            friendButton.isHidden = true
            friendPhoto.isHidden = true
        }
    }
    
    @IBAction func addWatched(_ sender: Any) {
        if(currentUserFirebase?.moviesWatchedId != nil) {
            var contain = 0
            for i in (currentUserFirebase?.moviesWatchedId)! {
                if (i.id == movieDetailed?.id) {
                    contain = 1
                }
            }
        if(contain == 1) {
            UserFirebase.removeMovieWatched(id: movieDetailed!.id, completion: { (error) in
                if(error == nil) {
                    self.addButon.layer.borderColor = redColor.cgColor
                    self.addButon.layer.borderWidth = 1
                    self.addButon.backgroundColor = UIColor.clear
                    self.addButon.setTitleColor(redColor, for: .normal)
                    self.addButon.setTitle("Unwatched", for: .normal)
                    return
                }
            })
            }
        }
            UserFirebase.addMovieWatched(id: movieDetailed!.id, completion: { (error) in
                if(error == nil) {
                    if(currentUserFirebase?.moviesWatchedId == nil) {
                        currentUserFirebase?.moviesWatchedId = [(Int, Date)]()
                    }
                    self.addButon.layer.backgroundColor = greenColor.cgColor
                    self.addButon.layer.borderColor = UIColor.clear.cgColor
                    self.addButon.setTitleColor(UIColor.white, for: .normal)
                    self.addButon.setTitle("✓ Watched", for: .normal)
                    return
                }
                else {
                    print(error)
                    return
                }
            })
        
    }
    
    @IBAction func addFavourites(_ sender: Any) {
        if (currentUserFirebase?.favouritesMoviesId != nil) {
            if(currentUserFirebase?.favouritesMoviesId?.contains((movieDetailed?.id)!))! {
            UserFirebase.removeMovieFavourites(id: movieDetailed!.id, completion: { (error) in
                if(error == nil) {
                    self.favouriteButton.setImage(#imageLiteral(resourceName: "hearth"), for: .normal)
                    return
                }
            })
            }
        }
        UserFirebase.addMovieFavourites(movie: movieDetailed!, completion: { (error) in
            if(error == nil) {
                if(currentUserFirebase?.favouritesMoviesId == nil) {
                    currentUserFirebase?.favouritesMoviesId = [Int]()
                }
                self.favouriteButton.setImage(#imageLiteral(resourceName: "favorite-heart-button"), for: .normal)
                return
            }
            else {
                print(error)
                return
            }
        })
    }
    
    @IBAction func showAlert(_ sender: Any) {
  
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add to a list", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "addList", sender: self)
        }))
        
        if((currentUserFirebase?.toWatchId?.contains((movieDetailed?.id)!))!){
            alert.addAction(UIAlertAction(title: "Remove to 'To watch", style: .default , handler:{ (UIAlertAction)in
                UserFirebase.removeToWatch(id: (self.movieDetailed?.id)!, completion: { (error) in
                    if(error == nil) {
                        
                    }
                })
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Add to 'To watch'", style: .default , handler:{ (UIAlertAction)in
                UserFirebase.addToWach(id: self.movieDetailed!.id, completion: { (error) in
                    if(error == nil) {
                    }
                })
            }))
        }
        alert.addAction(UIAlertAction(title: "Suggest to a friend", style: .default , handler:{ (UIAlertAction)in
            print("User click Edit button")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            print("cancel")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y
        if(offset > 2){
            UIView.animate(withDuration: 0.3, animations: {
                self.movieViewHeigth.constant = 40
                self.addButtonHeigth.constant = 0
                self.posterHeigth.constant = 0
                self.friendButtonHeigth.constant = 0
                self.friendButton.alpha = 0
                self.addButon.alpha = 0
                self.friendPhotoheigth.constant = 0
                self.view.layoutIfNeeded()
                self.runtimeTop.constant = -12
                self.releaseTop.constant = -12
                self.watchersTop.constant = -12
                self.friendTop.constant = 0
                self.navigationItem.title = self.movieDetailed?.title
                self.titleLabel.text = ""
            })
        }
        else {
            UIView.animate(withDuration: 0.3, animations: {
                self.movieViewHeigth.constant = 162
                self.addButtonHeigth.constant = 30
                self.posterHeigth.constant = 135
                self.friendButtonHeigth.constant = 21
                self.friendPhotoheigth.constant = 21
                self.friendButton.alpha = 1
                self.addButon.alpha = 1
                self.runtimeTop.constant = 8
                self.releaseTop.constant = 8
                self.watchersTop.constant = 8
                self.friendTop.constant = -8
                self.view.layoutIfNeeded()
                self.navigationItem.title = ""
                self.titleLabel.text = self.movieDetailed?.title
            })
        }
    }
    
    @objc func viewAllSegue(sender: UIButton) {
        switch sender.tag {
        case 2:
            dataToPass = 1
            self.performSegue(withIdentifier: "castViewAll", sender: self)
        case 5:
            self.performSegue(withIdentifier: "viewAllImages", sender: self)
        default:
            return
        }
    }
        
    @IBAction func insertVote(_ sender: Any) {
        
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! VotePopupViewController
        popOverVC.vote = vote
        popOverVC.movie = movieDetailed
        popOverVC.delegate = self
        self.addChild(popOverVC)
        self.view.addSubview(popOverVC.view)
        UIApplication.shared.keyWindow!.addSubview(popOverVC.view)
        popOverVC.view.frame = self.view.frame
        popOverVC.didMove(toParent: self)
    }
    
    func pass(vote: Int) {
        self.vote = vote
        self.tempVote = vote
        self.tableView.reloadRows(at: [IndexPath(item: 0, section: 1)], with: .none)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "actorDetails" {
            if let collectionCell:  ActorsCollectionViewCell = sender as? ActorsCollectionViewCell {
                if let collectionView: UICollectionView = collectionCell.superview as? UICollectionView {
                    if let destination = segue.destination as? PersonInfoViewController {
                        // Pass some data to YourViewController
                        // collectionView.tag will give your selected tableView index
                        let vc = segue.destination as! PersonInfoViewController
                        vc.id = credits?.cast[collectionCell.tag].id
                        self.title = ""
                    }
                }
            }
        }
        
        if segue.identifier == "similarMovie" {
            if let collectionCell:  SimilarmovieCollectionViewCell = sender as? SimilarmovieCollectionViewCell {
                if let collectionView: UICollectionView = collectionCell.superview as? UICollectionView {
                    if let destination = segue.destination as? MovieInfoViewController {
                        // Pass some data to YourViewController
                        // collectionView.tag will give your selected tableView index
                        let vc = segue.destination as! MovieInfoViewController
                        let movie = similarMovies![collectionCell.tag]
                        vc.id = movie.id
                        self.title = ""
                    }
                }
            }
        }
        
        /*if segue.identifier == "castViewAll" {
            let vc = segue.destination as! ViewAllViewController
            if(dataToPass == 1) {
                vc.castMovie = (credits?.cast)!
            }
            if(dataToPass == 2) {
                vc.crewMovie = (credits?.crew)!
            }
            if(dataToPass == 3) {
                vc.crewMovie = crewToPass as! [CrewMDB]
            }
            vc.title = self.movieDetailed?.title
            self.title = ""
        }*/
        
        if segue.identifier == "viewAllImages" {
            let vc = segue.destination as! ViewAllImagesViewController
            vc.objectToSort = images
            vc.title = movieDetailed?.title
            self.title = ""
        }
        
        if segue.identifier == "personDetail" {
            if let person = personToPass as? CrewMDB {
                let vc = segue.destination as! PersonInfoViewController
                vc.id = person.id
                vc.title = person.name
                self.title = ""
            }
        }
        if segue.identifier == "viewComments" {
            let vc = segue.destination as! CommentsTableViewController
            vc.title = movieDetailed?.title
            vc.movie = movieDetailed
            self.title = ""
        }
        if segue.identifier == "addList" {
            let vc = segue.destination as! AllListTableViewController
            vc.movie = movieDetailed
            self.title = ""
        }
    }
}
