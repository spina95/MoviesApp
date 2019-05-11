//
//  DiscoverCollectionViewController.swift
//  Movies
//
//  Created by Andrea Spinazzola on 02/05/2019.
//  Copyright © 2019 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift
import BottomPopup

class DiscoverCollectionViewController: UIViewController {
    
    
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    var filters = ["Genre", "Year", "Vote", "Country", "Cast", "Sort By"]
    var genresIndex = [Int]()
    var yearsIndex = [Int]()
    var year: Int?
    var vote: Int?
    var country: String?
    
    var dropDownMenu = DropDownMenu()
    
    var movies = [MovieDetailedMDB]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self

    
        if(genresIndex.count != getGenresList().count) {
            genresIndex.removeAll()
            for i in getGenresList(){
                genresIndex.append(0)
            }
        }
        if(yearsIndex.count != getYearsList().count){
            yearsIndex.removeAll()
            for i in getYearsList(){
                yearsIndex.append(0)
            }
        }
        
        loadMovies()
    }
    
    func loadMovies() {
        self.showSpinner(onView: self.view)
        
        var params = [DiscoverParam]()
        for (index, element) in getGenresList().enumerated(){
            if(genresIndex[index] == 1) {
                let genre = genreToId(genre: element)
                var param = DiscoverParam.with_genres(genre.rawValue)
                params.append(param)
            }
        }
        
        let myGroup = DispatchGroup()
        myGroup.enter()
        movies.removeAll()
        DiscoverMDB.discover(discoverType: DiscoverType.movie, params: params) { (client, movies, tvs) in
            if let movies = movies {
                for i in movies {
                    myGroup.enter()
                    MovieDetailedMDB.movie(movieID: i.id, language: "it") { (client, movie) in
                        if let movie = movie {
                            self.movies.append(movie)
                        }
                        myGroup.leave()
                    }
                }
            }
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            self.movieCollectionView.reloadData()
            self.removeSpinner()
        }
    }
    
}

extension DiscoverCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.tag == 0) {
            return filters.count + 1
        }
        if(collectionView.tag == 1) {
            return movies.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FiltersCollectionViewCell
            if(indexPath.row == 0){
                cell.button.setTitleColor(UIColor.white, for: .normal)
                cell.button.setTitle("Filters", for: .normal)
                cell.button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                cell.button.backgroundColor = UIColor.clear
            } else {
                let filter = filters[indexPath.row - 1 ]
                switch filter {
                case "Genre":
                    var genres = [String]()
                    for (index, element) in genresIndex.enumerated() {
                        if element == 1 {
                            genres.append(getGenresList()[index])
                        }
                    }
                    if(genres.count == 0){
                        cell.button.setTitle("Genres", for: .normal)
                        cell.button.setTitleColor(UIColor.white, for: .normal)
                        cell.button.backgroundColor = UIColor.clear
                        cell.button.layer.borderWidth = 1
                        cell.button.layer.borderColor = UIColor.white.cgColor
                    } else {
                        if(genres.count == 1) {
                            cell.button.setTitle(genres[0], for: .normal)
                        } else {
                            cell.button.setTitle(genres[0] + " + " + String(genres.count - 1), for: .normal)
                        }
                        cell.button.setTitleColor(UIColor.white, for: .normal)
                        cell.button.backgroundColor = mainColor
                        cell.button.layer.borderWidth = 0
                        cell.button.layer.borderColor = UIColor.clear.cgColor
                    }
                case "Years":
                    var years = [Int]()
                    for (index, element) in yearsIndex.enumerated() {
                        if element == 1 {
                            years.append(getYearsList()[index])
                        }
                    }
                    if(years.count == 0){
                        cell.button.setTitle("Years", for: .normal)
                        cell.button.setTitleColor(UIColor.white, for: .normal)
                        cell.button.backgroundColor = UIColor.clear
                        cell.button.layer.borderWidth = 1
                        cell.button.layer.borderColor = UIColor.white.cgColor
                    } else {
                        if(years.count == 1) {
                            cell.button.setTitle(String(years[0]), for: .normal)
                        } else {
                            cell.button.setTitle(String(years[0]) + " + " + String(years.count - 1), for: .normal)
                        }
                        cell.button.setTitleColor(UIColor.white, for: .normal)
                        cell.button.backgroundColor = mainColor
                        cell.button.layer.borderWidth = 0
                        cell.button.layer.borderColor = UIColor.clear.cgColor
                    }
                default:
                    cell.button.setTitle(filters[indexPath.row - 1], for: .normal)
                    cell.button.setTitleColor(UIColor.white, for: .normal)
                    cell.button.backgroundColor = UIColor.clear
                    cell.button.layer.borderWidth = 1
                    cell.button.layer.borderColor = UIColor.white.cgColor
                    break
                }
            }
            return cell
        }
        if (collectionView.tag == 1) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollection", for: indexPath) as! MovieCollectionViewCell
            cell.title.text = movies[indexPath.row].title
            if let poster = movies[indexPath.row].poster_path {
                cell.poster.downloadImage(path: poster, placeholder: UIImage())
            }
            var info = ""
            
            if(movies[indexPath.row].genres.count != 0){
                cell.info2.text = movies[indexPath.row].genres[0].name!
            }
            if let runtime = movies[indexPath.row].runtime {
                let h = runtime / 60
                let m = runtime % 60
                var runtime = String(h) + "h " + String(m) + "min"
                info = info + runtime
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
            
            if let voteAverage = movies[indexPath.row].vote_average {
                cell.averageLabel.text = String(format: "%.1f", voteAverage)
                cell.averageVote.endPointValue = CGFloat(voteAverage)
                cell.averageLabel.isHidden = false
                cell.averageVote.isHidden = false
            }
            cell.userVote.isHidden = true
            cell.userLabel.isHidden = true
            if let votes = currentUserFirebase?.votes {
                for i in votes{
                    if(i.id == movies[indexPath.row].id) {
                        cell.userVote.endPointValue = CGFloat(i.vote)
                        cell.userLabel.text = String(i.vote)
                        cell.userVote.isHidden = false
                        cell.userLabel.isHidden = false
                    }
                    
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView.tag == 0) {
            dropDownMenu = storyboard?.instantiateViewController(withIdentifier: "dropdownMenu") as! DropDownMenu
            dropDownMenu.popupDelegate = self
            dropDownMenu.height = 200
            dropDownMenu.topCornerRadius = 8
            dropDownMenu.presentDuration = 0.2
            dropDownMenu.dismissDuration = 0.2
            dropDownMenu.shouldDismissInteractivelty = true
            switch indexPath.row{
            case 1:
                dropDownMenu.mode = "Genre"
                dropDownMenu.genresIndex = genresIndex
                dropDownMenu.height = 400
            case 2:
                dropDownMenu.mode = "Years"
                dropDownMenu.yearsIndex = yearsIndex
                dropDownMenu.height = 600
            default:
                break
            }
            present(dropDownMenu, animated: true, completion: nil)
        }
    }
    
    
}

extension DiscoverCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView.tag == 0) {
            var button = UIButton(frame: CGRect.zero)
            if(indexPath.row == 0){
                button.setTitle("Filters", for: .normal)
            } else {
                let filter = filters[indexPath.row - 1 ]
                switch filter {
                case "Genre":
                    var genres = [String]()
                    for (index, element) in genresIndex.enumerated() {
                        if element == 1 {
                            genres.append(getGenresList()[index])
                        }
                    }
                    if(genres.count == 0){
                        button.setTitle("Genres", for: .normal)
                        
                    } else {
                        button.setTitle(genres[0] + " + " + String(genres.count - 1), for: .normal)
                    }
                default:
                    button.setTitle(filters[indexPath.row - 1 ], for: .normal)
                }
            }
            button.sizeToFit()
            return CGSize(width: button.frame.width + 8, height: 50)
        }
        if(collectionView.tag == 1) {
            return CGSize(width: UIScreen.main.bounds.width/2 - 12, height: 300)
        }
        return CGSize(width: 0, height: 0)
    }
    
}

extension DiscoverCollectionViewController: BottomPopupDelegate {
    
    func bottomPopupViewLoaded() {
        print("bottomPopupViewLoaded")
    }
    
    func bottomPopupWillAppear() {
        print("bottomPopupWillAppear")
    }
    
    func bottomPopupDidAppear() {
        print("bottomPopupDidAppear")
    }
    
    func bottomPopupWillDismiss() {
        print("bottomPopupWillDismiss")
        if(dropDownMenu.save == true){
            if(dropDownMenu.mode == "Genre") {
                genresIndex = dropDownMenu.genresIndex
                filtersCollectionView.reloadItems(at: [IndexPath(row: 1, section: 0)])
            }
            dropDownMenu.save = false
            loadMovies()
        }
    }
    
    func bottomPopupDidDismiss() {
        print("bottomPopupDidDismiss")
    }
    
    func bottomPopupDismissInteractionPercentChanged(from oldValue: CGFloat, to newValue: CGFloat) {
        print("bottomPopupDismissInteractionPercentChanged fromValue: \(oldValue) to: \(newValue)")
    }
}


