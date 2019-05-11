//
//  DiscoverTableViewCell.swift
//  Movies
//
//  Created by Andrea Spinazzola on 05/02/2019.
//  Copyright © 2019 Andrea Spinazzola. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import TMDBSwift
import HGCircularSlider

class WatchedFriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    var friends: [UserFirebase]!

    var indexSelected = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        friendsCollectionView.dataSource = self
        friendsCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        moviesCollectionView.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension WatchedFriendsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.tag == 0) {
            if let a = friends {
                return a.count
            }
        }
        if(collectionView.tag == 1) {
            if let a = friends {
                if let movies = a[indexSelected].moviesWatchedId {
                    return (movies.count)
                }
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsCollectionViewCell", for: indexPath) as! FriendsCollectionViewCell
            if (friends != nil) {
                if(friends.count != 0) {
                    if let profilePictureURL = friends[indexPath.row].profilePictureUrl {
                        let filePath = "profile_images/\(profilePictureURL).png"
                        let storageRef = Storage.storage().reference()
                        storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                            if data != nil {
                                let userPhoto = UIImage(data: data!)
                                self.friends[indexPath.row].profilePicture = userPhoto
                                cell.picture.image = userPhoto
                            }
                        })
                    }
                    cell.tag = indexPath.row
                    cell.nameLabel.text = friends[indexPath.row].username
                    if(indexSelected != indexPath.row) {
                        cell.roundView.isHidden = true
                    }
                }
            }
            return cell
        }
        if (collectionView.tag == 1) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviesFriendsCollectionViewCell", for: indexPath) as! MoviesFriendsCollectionViewCell
            if (friends != nil) {
                if(friends.count != 0) {
                    cell.tag = indexPath.row
                    if(friends[indexSelected].moviesWatchedId != nil) {
                        MovieMDB.movie(movieID: friends[indexSelected].moviesWatchedId![indexPath.row].0, completion: { (client, movie) in
                            if (movie?.poster_path != nil) {
                                cell.picture.downloadImage(path:movie?.poster_path, placeholder: #imageLiteral(resourceName: "background"))
                            }
                            let date = self.friends[self.indexSelected].moviesWatchedId![indexPath.row].date
                            if Calendar.current.isDateInYesterday(date) {
                                cell.nameLabel.text = "Yesterday"
                            } else if Calendar.current.isDateInToday(date) {
                                cell.nameLabel.text = "Today"
                            } else {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "dd MMM"
                                cell.nameLabel.text = dateFormatter.string(from: date)
                            }
                            
                    
                        })
                    }
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.tag == 0) {
            let cell = collectionView.cellForItem(at: indexPath) as! FriendsCollectionViewCell
            cell.roundView.isHidden = false
            self.indexSelected = indexPath.row
            collectionView.reloadData()
            moviesCollectionView.reloadData()
        }
    }
}

class FriendsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var whiteView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        picture.roundCorners(value: Double(Int(picture.frame.height/2)))
        roundView.roundCorners(value: Double(Int(roundView.frame.height/2)))
        whiteView.roundCorners(value: Double(Int(whiteView.frame.height/2)))

    }
}

class MoviesFriendsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundView.roundCorners(value: 4)
    }
}

extension WatchedFriendsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView.tag == 0) {
            return CGSize(width: 75, height: 100)
        }
        if(collectionView.tag == 1) {
            return CGSize(width: 73, height: 109)
        }
        return CGSize(width: 0, height: 0)
    }
    
}

class SuggestedMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    var movies: [MovieDetailedMDB]!
    var colors: [UIColor]?
    var posters: [UIImage]?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        moviesCollectionView.dataSource = self
        moviesCollectionView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension SuggestedMoviesTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let a = movies {
            return a.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedMovieCollectionViewCell", for: indexPath) as! SuggestedMovieCollectionViewCell
            if (movies != nil) {
                if(movies.count != 0) {
                    if let colorArray = colors {
                        cell.roundView.backgroundColor = colorArray[indexPath.row]
                    }
                    if let posterArray = posters {
                        cell.picture.image = posterArray[indexPath.row]
                    }
                    cell.pageControl.numberOfPages = movies.count
                    cell.tag = indexPath.row
                    cell.title.text = movies[indexPath.row].title
                    var info = ""
                    var genre = movies[indexPath.row].genres[0].name
                    info = info + genre!
                    if let runtime = movies[indexPath.row].runtime {
                        let h = runtime / 60
                        let m = runtime % 60
                        var runtime = String(h) + "h " + String(m) + "min"
                        info = info + "  •  " + runtime
                    }
                    if let date = movies[indexPath.row].release_date {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                        let date = dateFormatter.date(from:date)
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date!)
                        let finalDate = calendar.date(from:components)
                        let formatter = DateFormatter()
                        formatter.dateStyle = DateFormatter.Style.long
                        formatter.timeStyle = .medium
                        let year = calendar.component(.year, from: finalDate!)
                        info = info + "  •  " + String(year)
                    }
                    cell.info.text = info
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.tag == 0) {
            let cell = collectionView.cellForItem(at: indexPath) as! SuggestedMovieCollectionViewCell
            moviesCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let c = cell as! SuggestedMovieCollectionViewCell
        c.pageControl.currentPage = indexPath.row
    }
}

class SuggestedMovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var because: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundView.clipsToBounds = true
        container.backgroundColor = UIColor.clear
        container.layer.shadowOpacity = 1
        container.layer.shadowRadius = 4
        container.layer.shadowColor = UIColor.gray.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 0)
        roundView.layer.cornerRadius = 8
    }
}

extension SuggestedMoviesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return CGSize(width: screenWidth, height: 160)
    }
    
}

class PopularPeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var peopleCollectionView: UICollectionView!
    
    var people: [PersonResults]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        peopleCollectionView.dataSource = self
        peopleCollectionView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension PopularPeopleTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let a = people {
            return a.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularPersonCell", for: indexPath) as! PopularPersonCollectionViewCell
            if (people != nil) {
                if(people.count != 0) {
                    if (people?[indexPath.row].profile_path != nil) {
                        if (people?[indexPath.row].profile_path != "") {
                            cell.picture.downloadImage(path:people?[indexPath.row].profile_path, placeholder: #imageLiteral(resourceName: "background"))
                        }
                    }
                }
            }
            cell.title.text = people[indexPath.row].name
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.tag == 0) {
            let cell = collectionView.cellForItem(at: indexPath) as! PopularPersonCollectionViewCell
            peopleCollectionView.reloadData()
        }
    }
}

class PopularPersonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        picture.roundCorners(value: Double(Int(picture.frame.height/2)))
    }
}

extension PopularPeopleTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return CGSize(width: 100, height: 100)
    }
    
}

class PopularTableViewCell: UITableViewCell {
    
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    var movies: [MovieDetailedMDB]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moviesCollectionView.dataSource = self
        moviesCollectionView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension PopularTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let a = movies {
            return a.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularCollectionCell", for: indexPath) as! PopularMovieCollectionViewCell
            if (movies != nil) {
                if(movies.count != 0) {
                    if (movies?[indexPath.row].poster_path != nil) {
                        if (movies?[indexPath.row].poster_path != "") {
                            cell.picture.downloadImage(path:movies?[indexPath.row].poster_path, placeholder: #imageLiteral(resourceName: "background"))
                        }
                    }
                    if let voteAverage = movies?[indexPath.row].vote_average {
                        cell.averageLabel.text = String(format: "%.1f", voteAverage)
                        cell.averageGraph.endPointValue = CGFloat(voteAverage)
                    }
                    cell.userGraph.isHidden = true
                    cell.userLabel.isHidden = true
                    if let votes = currentUserFirebase?.votes {
                        for i in votes{
                            if(i.id == movies?[indexPath.row].id) {
                                cell.userGraph.endPointValue = CGFloat(i.vote)
                                cell.userLabel.text = String(i.vote)
                                cell.userGraph.isHidden = false
                                cell.userLabel.isHidden = false
                            }
                            
                        }
                    }
                    cell.title.text = movies[indexPath.row].title
                    cell.genre.text = movies[indexPath.row].genres[0].name
                    if let runtime = movies[indexPath.row].runtime {
                        let h = runtime / 60
                        let m = runtime % 60
                        cell.runtime.text = String(h) + "h " + String(m) + "min"
                    } else {
                        cell.runtime.text = ""
                    }
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.tag == 0) {
            let cell = collectionView.cellForItem(at: indexPath) as! PopularMovieCollectionViewCell
            moviesCollectionView.reloadData()
        }
    }
}

class PopularMovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var averageGraph: CircularSlider!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var userGraph: CircularSlider!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var runtime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundView.roundCorners(value: 4)
    }
}

extension PopularTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return CGSize(width: 112, height: 228)
    }
    
}

class InTheatersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    var movies: [MovieMDB]!
    var selectedIndex = 0
    var previousIndex = -1
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var plot: UILabel!
    @IBOutlet weak var actors: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moviesCollectionView.dataSource = self
        moviesCollectionView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension InTheatersTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let a = movies {
            return a.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InTheatersCollectionCell", for: indexPath) as! InTeathersCollectionViewCell
            if (movies != nil) {
                if(movies.count != 0) {
                    if (movies?[indexPath.row].poster_path != nil) {
                        if (movies?[indexPath.row].poster_path != "") {
                            cell.picture.downloadImage(path:movies?[indexPath.row].poster_path, placeholder: #imageLiteral(resourceName: "background"))
                        }
                    }
                    if let voteAverage = movies?[indexPath.row].vote_average {
                        cell.averageLabel.text = String(format: "%.1f", voteAverage)
                        cell.averageGraph.endPointValue = CGFloat(voteAverage)
                    }
                    cell.userGraph.isHidden = true
                    cell.userLabel.isHidden = true
                    if let votes = currentUserFirebase?.votes {
                        for i in votes{
                            if(i.id == movies?[indexPath.row].id) {
                                cell.userGraph.endPointValue = CGFloat(i.vote)
                                cell.userLabel.text = String(i.vote)
                                cell.userGraph.isHidden = false
                                cell.userLabel.isHidden = false
                            }
                            
                        }
                    }
                    if(selectedIndex == indexPath.row){
                        cell.selectedView.layer.borderColor = yellowColor.cgColor
                        cell.selectedView.layer.borderWidth = 2
                        if(previousIndex != indexPath.row) {
                            MovieMDB.movie(movieID: movies[indexPath.row].id, completion: { (client
                                , movie) in
                                if let movie = movie {
                                    self.previousIndex = self.selectedIndex
                                    self.title.text = ""
                                    self.plot.text = ""
                                    self.actors.text = ""
                                    self.info.text = ""
                                    var info = ""
                                    var genre = movie.genres[0].name
                                    info = info + genre!
                                    if let runtime = movie.runtime {
                                        let h = runtime / 60
                                        let m = runtime % 60
                                        var runtime = String(h) + "h " + String(m) + "min"
                                        info = info + "  •  " + runtime
                                    }
                                    if let date = movie.release_date {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                        let date = dateFormatter.date(from:date)
                                        let calendar = Calendar.current
                                        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date!)
                                        let finalDate = calendar.date(from:components)
                                        let formatter = DateFormatter()
                                        formatter.dateStyle = DateFormatter.Style.long
                                        formatter.timeStyle = .medium
                                        let year = calendar.component(.year, from: finalDate!)
                                        info = info + "  •  " + String(year)
                                    }
                                    self.actors.text = ""
                                    MovieMDB.credits(movieID: movie.id, completion: { (client, credits) in
                                        if let credits = credits {
                                            var castString = ""
                                            for (index, actor) in credits.cast.enumerated() {
                                                if(index < 3) {
                                                    castString = castString + actor.name + ", "
                                                }
                                            }
                                            if(castString.characters.count > 2) {
                                                castString.removeLast(2)
                                            }
                                            self.actors.text = castString
                                            self.title.text = movie.title
                                            self.plot.text = movie.overview
                                            self.info.text = info
                                        }
                                    })
                                }
                            })
                        }
                    } else {
                        cell.selectedView.layer.borderWidth = 0
                    }
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let cell = collectionView.cellForItem(at: indexPath) as! InTeathersCollectionViewCell
            selectedIndex = indexPath.row
            moviesCollectionView.reloadData()
    }
}

class InTeathersCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var averageGraph: CircularSlider!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var userGraph: CircularSlider!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundView.roundCorners(value: 4)
        selectedView.roundCorners(value: 6)
    }
}

extension InTheatersTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return CGSize(width: 120, height: 180)
    }
    
}

class GenresTableViewCell: UITableViewCell {
    
    @IBOutlet weak var genresCollectionView: UICollectionView!
    
    var genres: [String]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        genresCollectionView.dataSource = self
        genresCollectionView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension GenresTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenresCollectionCell", for: indexPath) as! GenreCollectionViewCell
            cell.name.text = genres[indexPath.row]
            switch genres[indexPath.row] {
            case "Action":
                    cell.picture.image = UIImage(named: "actionCover")
            case "Adventure":
                cell.picture.image = UIImage(named: "adventureCover")
            case "Animation":
                cell.picture.image = UIImage(named: "animationCover")
            case "Comedy":
                cell.picture.image = UIImage(named: "comedyCover")
            default:
                break
            }
            cell.tag = indexPath.row
            return cell
        }
        return UICollectionViewCell()
    }
}

class GenreCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        container.backgroundColor = UIColor.clear
        container.layer.shadowOpacity = 1
        container.layer.shadowRadius = 3
        container.layer.shadowColor = UIColor.gray.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 0)
        roundView.roundCorners(value: 6)
    }
}

extension GenresTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return CGSize(width: 150, height: 90)
    }
    
}
