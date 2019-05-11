//
//  UserInfoViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 08/08/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseStorage
import TMDBSwift

class UserInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var header: ModeView!
    @IBOutlet weak var modeView: UIView!
    @IBOutlet weak var followButton: RoundButton!
    
    var mode = 0
    var reloadView = false
    
    var watchedMoviesId: [Int]?
    var dataToPass: [Any]?
    var nextTitle: String?
    
    var histogramChartPoints = [(x: UserFirebase, y: String)]()

    var user: UserFirebase!
    
    var currentLineChartButton: UIButton?
    
    var followersCount = 0
    var followingCount = 0
    var runtime = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0
        
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        
        let headerNib = UINib.init(nibName: "HeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        loadingView.backgroundColor = backgroundColor
        view.addSubview(loadingView)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray) // Create the activity indicator
        view.addSubview(activityIndicator) // add it as a  subview
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.3) // put in the middle
        activityIndicator.startAnimating()
        
        let myGroup = DispatchGroup()
        
        myGroup.enter()
        FriendSystem.system.addUserFollowingObserver(user: user) {
            if(FriendSystem.system.userFollowingList != nil){
                self.followingCount = FriendSystem.system.userFollowingList.count
                self.histogramChartPoints.removeAll()
                if let movieCounter = currentUserFirebase?.moviesWatchedId?.count {
                    self.histogramChartPoints.append((x: currentUserFirebase!, y: String(movieCounter)))
                } else {
                    self.histogramChartPoints.append((x: currentUserFirebase!, y: String(0)))
                }
                let a = FriendSystem.system.userFollowingList
                for i in FriendSystem.system.userFollowingList {
                    myGroup.enter()
                    UserFirebase.getMoviesIdWatched(user: i) { (ids) in
                        if(ids == nil) {
                        } else {
                            self.histogramChartPoints.append((x: i, y: String(ids!.count)))
                            myGroup.leave()
                        }
                    }
                }
            }
            myGroup.leave()
        }
        
        myGroup.enter()
        FriendSystem.system.addUserFollowersObserver(user: user) {
            self.followersCount = FriendSystem.system.userFollowersList.count
            myGroup.leave()
        }
        
        /*if let profilePictureURL = user!.profilePictureUrl {
            myGroup.enter()
            let filePath = "profile_images/\(profilePictureURL).png"
            // Assuming a < 10MB file, though you can change that
            let storageRef = Storage.storage().reference()
            storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                if data != nil {
                    let userPhoto = UIImage(data: data!)
                    self.user!.profilePicture = userPhoto
                    myGroup.leave()
                }
            })
        } */
 
        myGroup.notify(queue: .main) {
            self.tableView.reloadData()
            loadingView.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0
        tableView.reloadData()
    }
    
    func load(){
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        loadingView.backgroundColor = backgroundColor
        view.addSubview(loadingView)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray) // Create the activity indicator
        view.addSubview(activityIndicator) // add it as a  subview
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.3) // put in the middle
        activityIndicator.startAnimating()
        
        if(user.profilePictureUrl != nil) {
            UserFirebase.downloadUserImage(user: user, completion: { (user) in
                if(user.profilePicture == nil){
                    user.profilePicture = #imageLiteral(resourceName: "profile picture")
                }
            })
        }
        UserFirebase.getMoviesIdWatched(user: user, completion: { (ids) in
            self.user.moviesWatchedId = ids
            UserFirebase.getMoviesIdFavourites(user: self.user, completion: { (ids) in
                self.user.favouritesMoviesId = ids
                self.tableView.reloadData()
                activityIndicator.stopAnimating()
                loadingView.isHidden = true
            })
        })
        
        FriendSystem.system.addFollowingObserver {
            for friend in FriendSystem.system.followingList {
                if(friend.uid == self.user.uid) {
                    self.followButton.setTitle("    Following    ", for: .normal)
                    self.followButton.backgroundColor = greenColor
                    self.followButton.layer.borderColor = UIColor.clear.cgColor
                    self.followButton.setTitleColor(UIColor.white, for: .normal)
                    self.followButton.sizeToFit()
                }
            }
        }
        
        FriendSystem.system.addUserRequestObserver(user: user) {
            for i in FriendSystem.system.requestList {
                if(i.uid == currentUserFirebase?.uid) {
                    self.followButton.setTitle("    Request sent    ", for: .normal)
                    self.followButton.sizeToFit()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        // #warning Incomplete implementation, return the number of sections
        if(mode == 0) { return 2}
        if(mode == 1) { return 2}
        return 0    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) { return 1}
        
        if(mode == 0) {
            if(section == 1) { return 4}
        }
        if(mode == 1) {
            if(section == 1) { return 2}
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) { return 120}
        
        if(mode == 0) {
            if(indexPath.section == 1) { return 314}
        }
        if(mode == 1) {
            if(indexPath.section == 1 && indexPath.row == 0) { return 460}
            if(indexPath.section == 1 && indexPath.row == 1) { return 242}
            if(indexPath.section == 1 && indexPath.row == 2) { return 152}
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! CurrentUserInfoTableViewCell
            cell.username.text = user?.username
            if let movieCounter = user?.moviesWatchedId?.count {
                cell.moviesWatchedLabel.setTitle(String(movieCounter), for: .normal)
            }
            if(user?.profilePicture != nil) {
                cell.picture.setImage(user?.profilePicture, for: .normal)
            }
            cell.followers.setTitle(String(String(followersCount)), for: .normal)
            cell.following.setTitle(String(String(followingCount)), for: .normal)
            return cell
        }
        if(mode == 0) {
            if(indexPath.section == 1 && indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "watchedCell", for: indexPath) as! WatchedMoviesTableViewCell
                var movies = [(Int, Date)]()
                for i in (user?.favouritesMoviesId)! {
                    movies.append((i, Date()))
                }
                cell.moviesId = movies
                cell.collectionView.reloadData()
                cell.titleLabel.text = "Favourite movies"
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
                cell.moviesId = user?.moviesWatchedId
                cell.collectionView.reloadData()
                cell.titleLabel.text = "Watched movies"
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
        }
        
        if(mode == 1) {
            if(indexPath.section == 1 && indexPath.row == 0) {
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
                if(currentLineChartButton?.tag == 0) {
                    xAxisLabels = ["J", "F", "M", "A", "M", "J", "A", "S", "O", "N", "D"]
                    leftAxisLabels = ["5", "2", "10", "5", "7", "9", "1", "0", "3", "10", "11", "5"]
                    cell.yearButton.backgroundColor = color
                }
                if(currentLineChartButton?.tag == 1) {
                    
                    for i in 1...31{
                        xAxisLabels.append(String(i))
                        leftAxisLabels.append(String("5"))
                    }
                    cell.monthbutton.backgroundColor = color
                }
                if(currentLineChartButton?.tag == 2) {
                    xAxisLabels = ["Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"]
                    leftAxisLabels = ["5", "2", "10", "5", "7", "9", "1"]
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
            if(indexPath.section == 1 && indexPath.row == 1) {
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
        }
        
        return UITableViewCell()
    }
    
    
    @IBAction func followButtonTouched(_ sender: UIButton) {
        if(sender.titleLabel?.text == "    Follow    "){
            FriendSystem.system.sendFollowRequestToUser(user.uid!)
            sender.setTitle("    Request sent    ", for: .normal)
            followButton.sizeToFit()
        } else
        if(sender.titleLabel?.text == "    Following    "){
            FriendSystem.system.removeFollower(String(user.uid!))
            sender.backgroundColor = UIColor.clear
            sender.layer.borderColor = UIColor.lightGray as! CGColor
            sender.setTitle("    Follow    ", for: .normal)
            followButton.sizeToFit()
        }
    }
    
    @objc func viewAllSegue(sender: UIButton) {
        switch sender.tag {
        case 0:
            dataToPass = user.favouritesMoviesId
            nextTitle = "Favourites"
            self.performSegue(withIdentifier: "viewAll", sender: self)
        case 1:
            dataToPass = user.moviesWatchedId
            nextTitle = "Watched"
            self.performSegue(withIdentifier: "viewAll", sender: self)
        default:
            return
        }
    }
    
    @objc func changeLineChart(sender: UIButton) {
        
        currentLineChartButton = sender
        //self.tableView.reloadData()
        let index = IndexPath(row: 0, section: 1)
        let indexPath = IndexPath(item: 0, section: 1)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @IBAction func button1Touch(_ sender: Any) {
        if(mode == 1) {
            UIView.animateKeyframes(withDuration: 0.15, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
                self.modeView.frame.origin.x -= self.modeView.frame.width
            },completion: nil)
        }
        if(mode == 2) {
            UIView.animateKeyframes(withDuration: 0.15, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
                self.modeView.frame.origin.x -=  (self.modeView.frame.width * 2)
            },completion: nil)
        }
        self.tableView.reloadData()
        mode = 0
    }
    
    @IBAction func button2Touch(_ sender: Any) {
        if(mode == 0) {
            UIView.animateKeyframes(withDuration: 0.15, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
                self.modeView.frame.origin.x += self.modeView.frame.width
            },completion: nil)
        }
        if(mode == 2) {
            UIView.animateKeyframes(withDuration: 0.15, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
                self.modeView.frame.origin.x -= self.modeView.frame.width
            },completion: nil)
        }
        self.tableView.reloadData()
        mode = 1
    }
    
    @IBAction func button3Touch(_ sender: Any) {
        if(mode == 0) {
            UIView.animateKeyframes(withDuration: 0.15, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
                self.modeView.frame.origin.x += self.modeView.frame.width * 2
            },completion: nil)
        }
        if(mode == 1) {
            UIView.animateKeyframes(withDuration: 0.15, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
                self.modeView.frame.origin.x += self.modeView.frame.width
            },completion: nil)
        }
        self.tableView.reloadData()
        mode = 2
    }
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y
        if(offset > 50){
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationItem.title = self.user.username
            })
        }
        else {
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationItem.title = ""
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if segue.identifier == "viewAll" {
            let vc = segue.destination as! ViewAllViewController
            vc.objectArray = dataToPass!
            vc.title = nextTitle
            self.title = ""
        }*/
        if segue.identifier == "movieDetail" {
            if let collectionCell:  WatchedMovieCollectionViewCell = sender as? WatchedMovieCollectionViewCell {
                if let collectionView: UICollectionView = collectionCell.superview as? UICollectionView {
                    if let destination = segue.destination as? MovieInfoViewController {
                        // Pass some data to YourViewController
                        // collectionView.tag will give your selected tableView index
                        let vc = segue.destination as! MovieInfoViewController
                        if(collectionView.tag == 0) {
                            vc.id = user.favouritesMoviesId!.reversed()[collectionCell.tag]
                        }
                        if(collectionView.tag == 1) {
                            vc.id = user.moviesWatchedId!.reversed()[collectionCell.tag].id
                        }
                        self.title = ""
                    }
                }
            }
        }
    }
}
