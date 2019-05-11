//
//  UserInfoViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 15/07/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseStorage
import TMDBSwift
import Charts

class CurrentUserInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var modeView: UIView!
    @IBOutlet var header: ModeView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var user: UserFirebase?
    
    var mode = 0
    var reloadView = false
    
    var watchedMovies: [Int]?
    var watchedMoviesDetailed = [MovieMDB]()
    
    var dataToPass = [(Int, Date?)]()
    var nextTitle: String?
    
    var histogramChartPoints = [(x: UserFirebase, y: String)]()
    
    var currentLineChartButton: UIButton?
    
    var followersCount = 0
    var followingCount = 0
    var runtime = 0
    
    var privateAccount = true
    
    var actorCount = [Counter]()
    var actorArray = [PersonMDB]()
    var actressCount = [Counter]()
    var actressArray = [PersonMDB]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layer.shadowOpacity = 0
        let headerNib = UINib.init(nibName: "HeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "HeaderView")
        self.showSpinner(onView: self.view)
        if(user == nil) {
            user = currentUserFirebase
            self.privateAccount = false
            loadUserInfo()
        } else {
            UserFirebase.getUserByUID(id: user!.uid!) { (user) in
                self.user = user
                var contain = 0
                if let followings = currentUserFirebase?.followings {
                    for i in followings {
                        if(user?.uid == user?.uid) {
                            contain == 1
                        }
                    }
                }
                if(user?.privateProfile == true && contain == 0) {
                    self.privateAccount = true
                } else {
                    self.privateAccount = false
                }
                self.navigationItem.leftBarButtonItem = nil
                self.loadUserInfo()
            }
        }
    }
    
    func loadUserInfo() {
        let myGroup = DispatchGroup()
        var count = 0
        
        if (currentUserFirebase?.followings != nil) {
            self.histogramChartPoints.removeAll()
            if let movieCounter = currentUserFirebase?.moviesWatchedId?.count {
                self.histogramChartPoints.append((x: currentUserFirebase!, y: String(movieCounter)))
            } else {
                self.histogramChartPoints.append((x: currentUserFirebase!, y: String(0)))
            }
            for i in 0...((currentUserFirebase?.followings?.count)! - 1) {
                myGroup.enter()
                count += 1
                if (currentUserFirebase?.followings![i].username == nil) {
                    UserFirebase.getUserByUID(id: (currentUserFirebase?.followings![i].uid)!) { (user) in
                        if(user != nil) {
                            currentUserFirebase?.followings![i] = user!
                            if(user?.moviesWatchedId! != nil) {
                                self.histogramChartPoints.append((x: user!, y: String((user?.moviesWatchedId!.count)!)))
                            }
                            myGroup.leave()
                            count -= 1
                        }
                    }
                } else {
                    self.histogramChartPoints.append((x: (currentUserFirebase?.followings![i])!, y: String((currentUserFirebase?.followings![i].moviesWatchedId!.count)!)))
                    myGroup.leave()
                    count -= 1
                }
            }
        }
        
        if let profilePictureURL = user?.profilePictureUrl {
            myGroup.enter()
            count += 1
            let filePath = "profile_images/\(profilePictureURL).png"
            let storageRef = Storage.storage().reference()
            storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                if data != nil {
                    let userPhoto = UIImage(data: data!)
                    self.user?.profilePicture = userPhoto
                    myGroup.leave()
                    count -= 1
                }
            })
        }
        
        if let movies = user?.moviesWatchedId {
            for id in movies {
                myGroup.enter()
                count += 1
                MovieMDB.movie(movieID: id.id) { (client, movie) in
                    if(movie?.id != nil) {
                        if let time = movie?.runtime {
                            self.runtime += time
                        }
                        myGroup.enter()
                        MovieMDB.credits(movieID: movie?.id, completion: { (client, credits) in
                            if let credits = credits?.cast {
                                var present = 0
                                for i in credits {
                                    var present = 0
                                    for j in self.actorCount {
                                        if(j.id == i.id) {
                                            j.count += 1
                                            present = 1
                                        }
                                    }
                                    if(present == 0) {
                                        self.actorCount.append(Counter(id: i.id, count: 1))
                                    }
                                }
                                myGroup.leave()
                            }
                        })
                        self.watchedMoviesDetailed.append(movie!)
                        myGroup.leave()
                        count -= 1
                    }
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            self.tableView.reloadData()
            self.removeSpinner()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        FriendSystem.system.removeFollowingObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0
        var indexPaths = [IndexPath]()
        if(mode == 0) {
            indexPaths = [IndexPath(item: 0, section: 1), IndexPath(item: 1, section: 1), IndexPath(item: 2, section: 1), IndexPath(item: 3, section: 1)]
        }
        if(mode == 1) {
            indexPaths = [IndexPath(item: 0, section: 0), IndexPath(item: 0, section: 1), IndexPath(item: 0, section: 1)]
        }
        tableView.reloadRows(at: indexPaths, with: .none)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var contain = 0
        if let followings = currentUserFirebase?.followings {
            for i in followings {
                if(user?.uid == user?.uid) {
                    contain == 1
                }
            }
        }
        if(self.privateAccount == true) {
            return nil
        }
        if(section == 1){
            if(mode == 0){
                header.selector.isHidden = false
                header.selector2.isHidden = true
                header.selector3.isHidden = true
            }
            if(mode == 1) {
                header.selector.isHidden = true
                header.selector2.isHidden = false
                header.selector3.isHidden = true
            }
            if(mode == 2) {
                header.selector.isHidden = true
                header.selector2.isHidden = true
                header.selector3.isHidden = false
            }
            return header
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) { return 0}
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(self.privateAccount == true) {
            return 1
        }
        if(mode == 0) { return 2}
        if(mode == 1) { return 2}
        if(mode == 2) { return 2}
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.privateAccount == true) {
            return 1
        }
        
        if(section == 0) { return 1}
        
        if(mode == 0) {
            if(section == 1) { return 4}
        }
        if(mode == 1) {
            if(section == 1) { return 4}
        }
        if(mode == 2) {
            if(section == 1) { return 3}
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(self.privateAccount == true) {
            return self.view.frame.height
        }
        if(indexPath.section == 0) { return 120}
        
        if(mode == 0) {
            if(indexPath.section == 1 && indexPath.row == 0) { return 280}
            if(indexPath.section == 1 && indexPath.row == 1) { return 280}
            if(indexPath.section == 1 && indexPath.row == 2) { return 220}
            if(indexPath.section == 1 && indexPath.row == 3) { return 280}
        }
        if(mode == 1) {
            if(indexPath.section == 1 && indexPath.row == 0) { return 50}
            if(indexPath.section == 1 && indexPath.row == 1) { return 400}
            if(indexPath.section == 1 && indexPath.row == 2) { return 262}
            if(indexPath.section == 1 && indexPath.row == 3) { return 180}
        }
        if(mode == 2) {
            if(indexPath.section == 1 && indexPath.row == 0) { return 50}
            if(indexPath.section == 1 && indexPath.row == 1) { return 50}
            if(indexPath.section == 1 && indexPath.row == 2) { return 50}
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(self.privateAccount == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "privateCell", for: indexPath) as! PrivateTableViewCell
            cell.label.text = "This account is private \nSend a follow request"
            return cell
        }
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! CurrentUserInfoTableViewCell
            cell.username.text = user?.username
            if let movieCounter = user?.moviesWatchedId?.count {
                cell.moviesWatchedLabel.setTitle(String(movieCounter), for: .normal)
            }
            if(user?.profilePicture != nil) {
                cell.picture.setImage(user?.profilePicture, for: .normal)
            }
            
            if let followers = user?.followers {
                cell.followers.setTitle(String(followers.count), for: .normal)
            } else {
                cell.followers.setTitle(String(0), for: .normal)
            }
            
            if let following = user?.followings {
                cell.following.setTitle(String(following.count), for: .normal)
            } else {
                cell.following.setTitle(String(0), for: .normal)
            }
            return cell
        }
        if(mode == 0) {
            if(indexPath.section == 1 && indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "watchedCell", for: indexPath) as! WatchedMoviesTableViewCell
                if let favouriteMovies = user?.favouritesMoviesId {
                    var movies = [(Int, Date)]()
                    for i in (user?.favouritesMoviesId)! {
                        movies.append((i, Date()))
                    }
                    cell.moviesId = movies.reversed()
                    cell.collectionView.reloadData()
                }
                cell.titleLabel.text = "FAVOURITE"
                cell.collectionView.tag = 0
                if(user?.favouritesMoviesId == nil) {
                    cell.viewAllButton.isHidden = true
                } else {
                    cell.viewAllButton.tag = 0
                    cell.viewAllButton.isHidden = false
                    cell.viewAllButton.addTarget(self, action:#selector(viewAllSegue(sender:)), for: .touchUpInside)
                }
                return cell
            }
            
            if(indexPath.section == 1 && indexPath.row == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "watchedCell", for: indexPath) as! WatchedMoviesTableViewCell
                let sortedArray = user?.moviesWatchedId?.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
                cell.moviesId = sortedArray
                cell.collectionView.reloadData()
                cell.titleLabel.text = "WATCHED"
                cell.collectionView.tag = 1
                if(user?.moviesWatchedId == nil) {
                    cell.viewAllButton.isHidden = true
                } else {
                    cell.viewAllButton.tag = 1
                    cell.viewAllButton.isHidden = false
                    cell.viewAllButton.addTarget(self, action:#selector(viewAllSegue(sender:)), for: .touchUpInside)
                }
                return cell
            }
            
            if(indexPath.section == 1 && indexPath.row == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTableViewCell
                cell.titleLabel.text = "LISTS"
                if let listArray = user?.lists {
                    cell.listArray = listArray
                }
                cell.collectionView.tag = 2
                cell.collectionView.reloadData()
                cell.addList.addTarget(self, action:#selector(createList(sender:)), for: .touchUpInside)
                return cell
            }
            
            if(indexPath.section == 1 && indexPath.row == 3) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "watchedCell", for: indexPath) as! WatchedMoviesTableViewCell
                if let toWatchMovies = user?.toWatchId {
                    var movies = [(Int, Date)]()
                    for i in (user?.toWatchId)! {
                        movies.append((i, Date()))
                    }
                    cell.moviesId = movies.reversed()
                    cell.collectionView.reloadData()
                }
                cell.titleLabel.text = "TO WATCH"
                cell.collectionView.tag = 3
                if(user?.toWatchId == nil) {
                    cell.viewAllButton.isHidden = true
                } else {
                    cell.viewAllButton.tag = 2
                    cell.viewAllButton.isHidden = false
                    cell.viewAllButton.addTarget(self, action:#selector(viewAllSegue(sender:)), for: .touchUpInside)
                }
                
                return cell
            }
        }
        if(mode == 1) {
            if(indexPath.section == 1 && indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                return cell
            }
            if(indexPath.section == 1 && indexPath.row == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "moviesStats", for: indexPath) as! MovieStatsTableViewCell
                
                cell.yearButton.tag = 0
                cell.yearButton.addTarget(self, action: #selector(changeLineChart(sender:)), for: .touchUpInside)
                cell.monthbutton.tag = 1
                cell.monthbutton.addTarget(self, action: #selector(changeLineChart(sender:)), for: .touchUpInside)
                cell.weekButton.tag = 2
                cell.weekButton.addTarget(self, action: #selector(changeLineChart(sender:)), for: .touchUpInside)
                
                if(currentLineChartButton == nil) {
                    currentLineChartButton = cell.yearButton
                    cell.yearButton.backgroundColor = mainColor.withAlphaComponent(0.3)
                }
                var xAxisLabels = [String]()
                var leftAxisLabels = [String]()
                cell.yearButton.backgroundColor = UIColor.white
                cell.monthbutton.backgroundColor = UIColor.white
                cell.weekButton.backgroundColor = UIColor.white

                let color = mainColor.withAlphaComponent(0.3)
                
                let date = Date()
                let calendar = Calendar.current
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                let weekday = calendar.component(.weekday, from: date)
                
                if let movies = user?.moviesWatchedId {
                    var date = Date()
                    var year = 0
                    var month = 0
                    var week = 0
                    for m in movies {
                        if(m.date.isInSameYear(date: date)){
                            year = year + 1
                        }
                        if(m.date.isInSameMonth(date: date)){
                            month = month + 1
                        }
                        if(m.date.isInSameWeek(date: date)){
                            week = week + 1
                        }
                    }
                    cell.yearTotal.text = String(year)
                    cell.monthTotal.text = String(month)
                    cell.weekTotal.text = String(week)
                }
             
                // Anno
                if(currentLineChartButton?.tag == 0) {
                    var months = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
                    var dates = [Date]()
                    var counter = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    var date = Date()
                    for i in 1...12 {
                        if let movies = user?.moviesWatchedId {
                            for m in movies {
                                if(m.date.isInSameMonth(date: date)){
                                    counter[i-1] = counter[i-1] + 1
                                }
                            }
                        }
                        date = date.monthBefore
                    }
                    counter.reverse()
                    months = months.shiftRight(amount: month)
                    xAxisLabels = months
                    for a in counter {
                        leftAxisLabels.append(String(a))
                    }
                    cell.yearButton.backgroundColor = color
                }
                
                //Mese
                if(currentLineChartButton?.tag == 1) {
                    var dates = [Date]()
                    var counter = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    var date = Date()
                    for i in 1...30 {
                        dates.append(date)
                        if let movies = user?.moviesWatchedId {
                            for m in movies {
                                if(m.date.isInSameDay(date: date)){
                                    counter[i-1] = counter[i-1] + 1
                                }
                            }
                        }
                        xAxisLabels.append(String(date.day))
                        date = date.dayBefore
                    }
                    xAxisLabels.reverse()
                    counter.reverse()
                    for a in counter {
                        leftAxisLabels.append(String(a))
                    }
                    cell.monthbutton.backgroundColor = color
                }
                
                //Giorno
                if(currentLineChartButton?.tag == 2) {
                    xAxisLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    var counters = [0, 0, 0, 0, 0, 0, 0]
                    xAxisLabels = xAxisLabels.shiftRight(amount: weekday)
                    let lastWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
                    var totalCount = 0
                    if let movies = user?.moviesWatchedId {
                        for i in movies {
                            let w = calendar.component(.weekday, from: i.date)
                            if (i.date > lastWeekDate && i.date < Date()) {
                                counters[w - 1] = counters[w - 1] + 1
                            }
                        }
                    }
                    counters = counters.shiftRight(amount: weekday)
                    for a in counters {
                        leftAxisLabels.append(String(a))
                    }
                    cell.weekButton.backgroundColor = color
                }
                cell.chart.setLineChart(dataPoints: xAxisLabels, values: leftAxisLabels)
                
                let months = runtime/43200
                let days = (runtime % 43200) / 1440
                let hours = ((runtime % 43200) % 1400) / 60
                cell.months.text = String(months)
                cell.days.text = String(days)
                cell.hours.text = String(hours)
                cell.chart.setNeedsDisplay()
                return cell
            }
            if(indexPath.section == 1 && indexPath.row == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "histogramCell", for: indexPath) as! FriendHistogramCell
                if(histogramChartPoints.count != 0) {
                    var names = [String]()
                    var count = [String]()
                    var result =  [(x: UserFirebase, y: String)]()
                    for j in 0...histogramChartPoints.count - 1 {
                        var found = 0
                        if(result.count != 0) {
                        for m in 0...result.count - 1 {
                            if(histogramChartPoints[j].x.uid == result[m].x.uid) {
                                found = 1
                            }
                            }}
                        if(found == 0){
                            result.append(histogramChartPoints[j])
                        }
                        }
                    for i in result{
                        if(i.x.uid == user?.uid){
                            if let count = user?.moviesWatchedId?.count {
                                 names.append("You\n" + String(count))
                            } else {
                                names.append("You")
                            }
                        } else {
                            names.append(i.x.username! + "\n" + i.y)
                        }
                        count.append(i.y)
                    }
                    cell.chart.setBarChart(dataPoints: names, values: count)
                }
                return cell
            }
            if(indexPath.section == 1 && indexPath.row == 3) {
                                
                let cell = tableView.dequeueReusableCell(withIdentifier: "GenresCell", for: indexPath) as! GenresPieChartCell
                if(watchedMoviesDetailed.count != 0) {
                    var genresArray: [GenreCount] = []
                    for movie in watchedMoviesDetailed {
                        for g in movie.genres {
                            var present = 0
                            for i in genresArray {
                                if(i.id == g.id){
                                    i.count = i.count + 1
                                    present = 1
                                }
                            }
                            if(present == 0) {
                                let a = GenreCount(id: g.id!, name: g.name!)
                                genresArray.append(a)
                            }
                        }
                    }
                    genresArray.sort { $0.count > $1.count }
                    var genres: [GenreCount] = []
                    for i in genresArray {
                        if(genres.count < 6) {
                            genres.append(i)
                        }
                    }
                    var genresString = [String]()
                    var values = [Double]()
                    for i in genres {
                        genresString.append(i.name)
                        values.append(Double(i.count))
                    }
                    if(genresArray.count != 0) {
                        cell.setChart(dataPoints: genresString, values: values)
                    }
                }
                return cell
            }
            
        }
        if(mode == 2) {
            if(indexPath.section == 1 && indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                return cell
            }
            
            if(indexPath.section == 1 && indexPath.row == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! InfoTableViewCell
                cell.label.text = "31 January 1995"
                cell.picture.image = UIImage(named: "cake1x")
                return cell
            }
            if(indexPath.section == 1 && indexPath.row == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! InfoTableViewCell
                cell.label.text = "Italy"
                cell.picture.image = UIImage(named: "country1x")
                return cell
            }
        }
        return UITableViewCell()
    }
    
    @objc func viewAllSegue(sender: UIButton) {
        dataToPass.removeAll()
        switch sender.tag {
        case 0:
            for i in (user?.favouritesMoviesId)! {
                dataToPass.append((i, nil))
            }
            nextTitle = "Favourites"
            self.performSegue(withIdentifier: "viewAll", sender: self)
        case 1:
            for i in (user?.moviesWatchedId)! {
                dataToPass.append((i.id, i.date))
            }
            nextTitle = "Watched"
            self.performSegue(withIdentifier: "viewAll", sender: self)
        default:
            return
        }
    }
    
    @objc func changeLineChart(sender: UIButton) {
        currentLineChartButton = sender
        let index = IndexPath(row: 1, section: 1)
        let indexPath = IndexPath(item: 1, section: 1)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc func createList(sender: UIButton) {
        let alertController = UIAlertController(title: "New list", message: "Insert the title for the list", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Title"
            textField.autocapitalizationType = .sentences

        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            UserFirebase.createList(nameList: firstTextField.text!) { (error) in
                if(error == nil){
                    let indexPath = [IndexPath(item: 2, section: 1)]
                    self.tableView.reloadRows(at: indexPath, with: .none)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func button1Touch(_ sender: Any) {
        if(mode == 1) {
            UIView.animate(withDuration: 0.15, animations: {
                self.header.selector2.frame.origin.x -= self.header.selector2.frame.width
            }) { (true) in
                self.mode = 0
                self.tableView.reloadData()
                self.tableView.setContentOffset(.zero, animated: false)
            }
        }
        if(mode == 2) {
            UIView.animate(withDuration: 0.15, animations: {
                self.header.selector3.frame.origin.x -=  (self.header.selector3.frame.width * 2)
            }) { (true) in
                self.mode = 0
                self.tableView.reloadData()
                self.tableView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    @IBAction func button2Touch(_ sender: Any) {
        if(mode == 0) {
            UIView.animate(withDuration: 0.15, animations: {
                self.header.selector.frame.origin.x += self.header.selector.frame.width
            }) { (true) in
                self.mode = 1
                self.tableView.reloadData()
                self.tableView.setContentOffset(.zero, animated: false)
            }
        }
        if(mode == 2) {
            UIView.animate(withDuration: 0.15, animations: {
                self.header.selector3.frame.origin.x -= self.header.selector3.frame.width
            }) { (true) in
                self.mode = 1
                self.tableView.reloadData()
                self.tableView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    @IBAction func button3Touch(_ sender: Any) {
        if(mode == 0) {
            UIView.animate(withDuration: 0.15, animations: {
                self.header.selector.frame.origin.x += self.header.selector.frame.width * 2
            }) { (true) in
                self.mode = 2
                self.tableView.reloadData()
                self.tableView.setContentOffset(.zero, animated: false)
            }
        }
        if(mode == 1) {
            UIView.animate(withDuration: 0.15, animations: {
                self.header.selector2.frame.origin.x += self.header.selector2.frame.width
            }) { (true) in
                self.mode = 2
                self.tableView.reloadData()
                self.tableView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y
        if(offset > 60){
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationItem.title = "Your profile"
            })
        }
        else {
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationItem.title = ""
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewAll" {
            let vc = segue.destination as! ViewAllViewController
            vc.moviesId = dataToPass
            vc.title = nextTitle
        }
        if segue.identifier == "movieDetail" {
            if let collectionCell:  WatchedMovieCollectionViewCell = sender as? WatchedMovieCollectionViewCell {
                if let collectionView: UICollectionView = collectionCell.superview as? UICollectionView {
                    if let destination = segue.destination as? MovieInfoViewController {
                        let vc = segue.destination as! MovieInfoViewController
                        if(collectionView.tag == 0) {
                            vc.id = user?.favouritesMoviesId!.reversed()[collectionCell.tag]
                        }
                        if(collectionView.tag == 1) {
                            vc.id = user?.moviesWatchedId![collectionCell.tag].id
                        }
                        if(collectionView.tag == 3) {
                            vc.id = user?.toWatchId!.reversed()[collectionCell.tag]
                        }
                    }
                }
            }
        }
        if segue.identifier == "viewList" {
            if let collectionCell:  ListCollectionViewCell = sender as? ListCollectionViewCell {
                if let collectionView: UICollectionView = collectionCell.superview as? UICollectionView {
                    if let destination = segue.destination as? ListMovieTableViewController {
                        let vc = segue.destination as! ListMovieTableViewController
                        vc.list = user?.lists![collectionCell.tag]
                    }
                }
            }
        }
    }
}
