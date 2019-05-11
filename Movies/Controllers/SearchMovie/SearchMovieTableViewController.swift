//
//  SearchMovieTableViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 28/03/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import TMDBSwift

class SearchMovieTableViewController:UIViewController,UITableViewDelegate, UITableViewDataSource,  UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var modeView: UIView!
    @IBOutlet weak var moviesButton: UIButton!
    @IBOutlet weak var usersButton: UIButton!
    @IBOutlet weak var selectorView: UIView!
    
    var mode = 0
    
    var resultsArray = [Any]()
    var moviesWatchedId: [(Int, Date)]?

    var searchActive : Bool = false
    
    var view2 = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TMDBConfig.apikey = "fa7f8ec398c80ce982ed4ceb6d95871f"

        tableView.delegate = self
        tableView.dataSource = self
        
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
     
        searchBar.delegate = self
        for subView in searchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    var bounds: CGRect
                    bounds = textField.frame
                    bounds.size.height = 35 //(set height whatever you want)
                    textField.bounds = bounds
                    textField.layer.cornerRadius = 17
                    textField.textColor = UIColor.white
                }
            }
        }
        self.navigationItem.titleView = searchBar

        view2 = UIView(frame: CGRect(x: 0, y: 115, width: view.frame.width, height: view.frame.height - 115))
        view2.backgroundColor = backgroundColor
        view.addSubview(view2)
        view2.isHidden = true
        
        activityIndicator = UIActivityIndicatorView(style: .gray) // Create the activity indicator
        view.addSubview(activityIndicator) // add it as a  subview
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.3 + 40) // put in the middle
        
        UserFirebase.getCurrentUser { (user) in
            UserFirebase.getMoviesIdWatched(user: user!, completion: { (ids) in
                self.moviesWatchedId = ids
            })
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // se la search bar viene visualizzata allora ritorno il numero di elementi della lista filtrata se no quelli della lista spesa
        if (mode == 0) {
            return 1
        }
        if (mode == 1) {
            return 1
        }
        return 0
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (mode == 0) {
            return resultsArray.count
        }
        if (mode == 1) {
            return resultsArray.count
        }
        return 0
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // MODE = 0
        if (mode == 0) {
            if(resultsArray.count != 0) {
            if let movie = resultsArray[indexPath.row] as? MovieMDB {
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchMovieCell", for: indexPath) as! SearchMovieTableViewCell
                cell.movie = movie
                cell.addButton.backgroundColor = UIColor.clear
                cell.addButton.setImage(#imageLiteral(resourceName: "add"), for: .normal)
                if let moviesWatched = currentUserFirebase?.moviesWatchedId {
                    var contain = 0
                    for i in moviesWatched {
                        if (i.id == movie.id) {
                            contain = 1
                        }
                    }
                    if(contain == 1) {
                        cell.addButton.setImage(nil, for: .normal)
                        cell.addButton.layer.borderColor = UIColor.clear.cgColor
                        cell.addButton.setTitle("✓", for: .normal)
                        cell.addButton.backgroundColor = greenColor
                        cell.addButton.roundCorners(value: Double(Int(cell.addButton.frame.height/2)))
                    }
                }
                if let favourites = currentUserFirebase?.favouritesMoviesId {
                    if(favourites.contains(movie.id)) {
                        cell.addButton.setImage(#imageLiteral(resourceName: "favorite-heart-button"), for: .normal)
                        cell.addButton.backgroundColor = UIColor.clear
                    }
                }
                cell.addButton.tag = indexPath.row
                cell.addButton.addTarget(self, action: #selector(self.buttonAction(_sender:)), for: UIControl.Event.touchUpInside)
                var attributes = String()
                attributes.append(movie.title!)
                var anno = String()
                if (movie.release_date != "") {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    let date = dateFormatter.date(from:movie.release_date!)
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date!)
                    let finalDate = calendar.date(from:components)
                    let formatter = DateFormatter()
                    formatter.dateStyle = DateFormatter.Style.long
                    formatter.timeStyle = .medium
                    let year = calendar.component(.year, from: finalDate!)
                    attributes.append(" (" + String(year) + ")" )
                    anno = String(year)
                }
                if(movie.poster_path != nil) {
                    cell.poster.downloadImage(path: movie.poster_path, placeholder: #imageLiteral(resourceName: "background"))
                } else {
                    cell.poster.image = nil
                }
                
                if(movie.release_date != "") {
                    let attributedText = NSMutableAttributedString(string: attributes)
                    attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .light)], range: NSMakeRange((movie.title?.characters.count)! + 1, anno.characters.count+2)) // Blue color attribute
                    cell.titleLabel.attributedText = attributedText
                } else {
                    cell.titleLabel.text = movie.title
                }
                cell.tag = indexPath.row
                cell.addButton.tag = indexPath.row
                return cell
            }
            }
            /*if let person = resultsArray[indexPath.row] as? Person {
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchPersonCell", for: indexPath) as! SearchPersonTableViewCell
                let person = resultsArray[indexPath.row] as! Person
                cell.nameLabel.text = person.name
                if(person.profilePath != nil) {
                    downloadImage2(imageUrl: person.profilePath!, completion: { (image) in
                        if(image != nil) {
                            if(indexPath.row < self.resultsArray.count) {
                                cell.photoImage.image = image
                            }
                        }
                    })
                } else {
                    cell.photoImage.image = UIImage(named: "profile picture")
                }
                if(person.knownFor != nil) {
                    var text = String()
                    for i in person.knownFor! {
                        var count = 0
                        if(i.title != nil) {
                            if(count == (person.knownFor?.count)! - 1) { text.append(i.title!)}
                            else { text.append(i.title! + ", ")}
                        }
                    }
                    let text2 = person.name! + "\n" + text
                    let attributedText = NSMutableAttributedString(string: text2)
                    attributedText.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.darkGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .light)], range: NSMakeRange((person.name?.characters.count)! + 1, text.characters.count))
                    cell.nameLabel.attributedText = attributedText
                    
                }
                return cell
            } */
            }
            // MODE 1
            if(mode == 1) {
                if let person = resultsArray[indexPath.row] as? UserFirebase {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "searchUserCell", for: indexPath) as! SearchUserTableViewCell
                    let user = resultsArray[indexPath.row] as! UserFirebase
                    cell.nameLabel.text = user.username
                    if(user.profilePictureUrl != nil) {
                        UserFirebase.downloadUserImage(user: user, completion: { (user) in
                            if(user.profilePicture != nil){
                                cell.photoImage.image = user.profilePicture
                            }
                        })
                    } else {
                        cell.photoImage.image = UIImage(named: "profile picture")
                    }
                    return cell
                }
            }
        return UITableViewCell()
    }

     func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        print("Sto per iniziare una ricerca")
        
        view2.isHidden = false
        activityIndicator.startAnimating()
        resultsArray.removeAll()
        stopAllRequests()
        var frase = searchBar.text
        if(frase?.characters.count != 0) {
            if (mode == 0) {
                SearchMDB.movie(query: frase!, language: "en", page: 1, includeAdult: false, year: nil, primaryReleaseYear: nil, completion: { (client, movies) in
                    if(movies != nil) {
                        self.resultsArray = movies!
                    } else {
                        self.resultsArray.removeAll()
                    }
                    self.tableView.reloadData()
                    self.view2.isHidden = true
                    self.activityIndicator.stopAnimating()
                })
            }
            if (mode == 1) {
                UserFirebase.searchUsersByString(searchString: frase!, completion: { (users) in
                    if(users != nil){
                        self.resultsArray = users!
                        self.tableView.reloadData()
                        self.view2.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                })
            }
        } else {
            self.resultsArray.removeAll()
            self.tableView.reloadData()
            self.view2.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @objc func buttonAction(_sender:UIButton!) {
        if let movie = resultsArray[_sender.tag] as? MovieMDB {
            if(currentUserFirebase?.favouritesMoviesId != nil) {
            if(currentUserFirebase?.favouritesMoviesId?.contains((movie.id)!))! {
                UserFirebase.removeMovieFavourites(id: movie.id, completion: { (error) in
                    let indexPath = [IndexPath(item: _sender.tag, section: 0)]
                    self.tableView.reloadRows(at: indexPath, with: .none)
                    //self.tableView.reloadData()
                    return
                })
                }
            }
                if(currentUserFirebase?.moviesWatchedId != nil) {
                    if(currentUserFirebase?.moviesWatchedId?.count != 0) {
                        var contain = 0
                        for i in (currentUserFirebase?.moviesWatchedId!)! {
                            if(i.0 == movie.id) {
                                contain = 1
                            }
                        }
                        if(contain == 1) {
                            UserFirebase.removeMovieWatched(id: movie.id, completion: { (error) in
                                if(error == nil) {
                                    let indexPath = [IndexPath(item: _sender.tag, section: 0)]
                                    self.tableView.reloadRows(at: indexPath, with: .none)
                                    //self.tableView.reloadData()
                                    return
                                }
                            })
                        }
                    }
                }
                UserFirebase.addMovieWatched(id: movie.id, completion: { (error) in
                    if(error == nil) {
                        if(currentUserFirebase?.moviesWatchedId == nil) {
                            currentUserFirebase?.moviesWatchedId = [(Int, Date)]()
                        }
                        let indexPath = [IndexPath(item: _sender.tag, section: 0)]
                        self.tableView.reloadRows(at: indexPath, with: .none)
                        //self.tableView.reloadData()
                        return
                    }
                    else {
                        print(error)
                        return
                    }
                })
            }
        
    }
    
    @IBAction func userButtonTouched(_ sender: UIButton) {
        if(mode == 0) {
            UIView.animateKeyframes(withDuration: 0.15, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
                self.selectorView.frame.origin.x+=self.selectorView.frame.width
                
            },completion: nil)
            mode = 1
            self.searchBar.text = ""
            self.resultsArray.removeAll()
            self.tableView.reloadData()

        }
    }
    
    @IBAction func moviesButtonTouched(_ sender: UIButton) {
        if(mode == 1) {
            UIView.animateKeyframes(withDuration: 0.15, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
                self.selectorView.frame.origin.x-=self.selectorView.frame.width
                
            },completion: nil)
            mode = 0
            self.searchBar.text = ""
            self.resultsArray.removeAll()
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "movieDetails"{
            let indexpath = self.tableView.indexPathForSelectedRow
            let vc = segue.destination as! MovieInfoViewController
            let movie = resultsArray[(indexpath?.row)!] as! MovieMDB
            vc.id = movie.id
        }
        else if segue.identifier == "personDetails"{
            let indexpath = self.tableView.indexPathForSelectedRow
            let vc: PersonInfoViewController = segue.destination as! PersonInfoViewController
            let id = (resultsArray[(indexpath?.row)!] as! Person).id
            vc.id = id
        }
        else if segue.identifier == "showUser"{
            let indexpath = self.tableView.indexPathForSelectedRow
            let vc = segue.destination as! CurrentUserInfoViewController
            vc.user = resultsArray[(indexpath?.row)!] as! UserFirebase
        }
    }
}


