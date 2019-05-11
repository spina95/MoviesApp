//
//  PersonInfoViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 08/08/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift

class PersonInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var infoViewHeigth: NSLayoutConstraint!
    @IBOutlet weak var addButtonHeigth: NSLayoutConstraint!
    @IBOutlet weak var pictureHeigth: NSLayoutConstraint!
    @IBOutlet weak var watchersTop: NSLayoutConstraint!
    @IBOutlet weak var releaseTop: NSLayoutConstraint!
    @IBOutlet weak var runtimeTop: NSLayoutConstraint!
    
    var id: Int!
    var person: PersonMDB?
    var credits: PersonMovieCredits?
    var images: [Images_MDB]?
    
    var selectedIndex = IndexPath()
    var shadowPath = UIBezierPath()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let headerNib = UINib.init(nibName: "HeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        loadingView.backgroundColor = backgroundColor
        view.addSubview(loadingView)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray) // Create the activity indicator
        view.addSubview(activityIndicator) // add it as a  subview
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.3) // put in the middle
        activityIndicator.startAnimating()
        
        PersonMDB.person_id(personID: id) { (client, person) in
            self.person = person
            PersonMDB.movie_credits(personID: self.id, language: "en", completion: { (client, personCredits) in
                self.credits = personCredits
                PersonMDB.images(personID: self.id, completion: { (client, images) in
                    self.images = images
                    self.loadPersonView()
                    self.tableView.reloadData()
                    activityIndicator.stopAnimating()
                    loadingView.isHidden = true
                })
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 0) { return 2}
        if(section == 1) { return 1}
        if(section == 2) { return 1}
        if(section == 3) { return 1}
        return 0
    }    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0 && indexPath.section == 1) {
            if(selectedIndex == indexPath) {
                return UITableView.automaticDimension
            }
            return 105
        }
        if (indexPath.row == 0 && indexPath.section == 2) {
            return 250
        }
        if (indexPath.section == 0) {
            if(indexPath.row == 0) {
                if( person?.birthday != nil) {
                    return UITableView.automaticDimension
                }
                return 0
            }
            if(indexPath.row == 1) {
                if( person?.deathday != nil) {
                    return 50
                }
                return 0
            }
        }
        //images
        if (indexPath.row == 0 && indexPath.section == 3) {
            if(images?.count != 0) { return 140 }
            else { return 0 }
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! HeaderView
        switch section {
        case 0:
            headerView.headerTitle.text = "Info"
            headerView.rightButton.isHidden = true
        case 1:
            headerView.headerTitle.text = "Biography"
            headerView.rightButton.isHidden = true
        case 2:
            headerView.headerTitle.text = "Credits"
            headerView.rightButton.tag = 0
            headerView.rightButton.addTarget(self, action:#selector(viewAllSegue(sender:)), for: .touchUpInside)
            headerView.rightButton.isHidden = false
        case 3:
            headerView.headerTitle.text = "Photos"
            headerView.rightButton.isHidden = false
            headerView.rightButton.addTarget(self, action:#selector(viewAllSegue(sender:)), for: .touchUpInside)
            headerView.rightButton.tag = 5
        default:
            headerView.headerTitle.text = ""
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) { return 60 }
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0 && indexPath.section == 1) {
            if(person != nil) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "biography", for: indexPath) as! BiographyPersonTableViewCell
                if(person?.biography != "") {
                    cell.label?.text = person?.biography
                }
                if(selectedIndex == indexPath) {
                    cell.expand.text = "Collapse"
                } else {
                    cell.expand.text = "Expand"
                }
                return cell
            }
        }
        
        if(indexPath.row == 0 && indexPath.section == 2) {
            if(credits != nil) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "filmographyTableViewCell", for: indexPath) as! FilmographyTableViewCell
                cell.credits = credits
                cell.collectionView.reloadData()
                return cell
            }
        }
        
        if(indexPath.section == 0) {
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextPersonTableViewCell
                if (person?.birthday != nil) {
                    var title = "Born: "
                    var date = String()
                    if(person?.place_of_birth != nil) {
                        date = convertDateFormatter(date: person!.birthday!) + " (" + (person?.place_of_birth!)! + ")"
                    } else {
                        date = convertDateFormatter(date: (person?.birthday!)!)
                    }
                    var string = title + date
                    let attributedText = NSMutableAttributedString(string: string)
                    
                    attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)], range: NSMakeRange(title.characters.count, (date.characters.count)))
                    cell.label.attributedText = attributedText
                } else { cell.isHidden = true }
                return cell
            }
            
            if(indexPath.row == 1){
                let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextPersonTableViewCell
                if (person?.deathday != nil) {
                    var title = "Death: "
                    var date = convertDateFormatter(date: (person?.deathday!)!)
                    var string = title + date
                    let attributedText = NSMutableAttributedString(string: string)
                    
                    attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)], range: NSMakeRange(title.characters.count, (date.characters.count)))
                    cell.label.attributedText = attributedText
                } else { cell.isHidden = true }
                return cell
            }
        }
        
        if(indexPath.row == 0 && indexPath.section == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imagesPersonCell", for: indexPath) as! ImagesPersonTableViewCell
            if(images != nil) {
                cell.images = images!
                cell.collectionView.reloadData()
            } else {
                cell.isHidden = true
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func loadPersonView() {
        
        picture.layer.borderWidth = 1
        picture.layer.borderColor = UIColor.white.cgColor
        picture.roundCorners(value: 2)
        
        addButton.roundCorners(value: 5)
        addButton.layer.borderColor = redColor.cgColor
        addButton.layer.borderWidth = 1
        
        picture.roundCorners(value: 2)
        if(person?.profile_path != nil) {
            picture.downloadImage(path: person?.profile_path!, placeholder: #imageLiteral(resourceName: "profile picture"))
        }
        name.text = person?.name
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0 && indexPath.section == 1) {
            if(selectedIndex == indexPath) {
                selectedIndex = IndexPath()
            } else {
                selectedIndex = indexPath
            }
            self.tableView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y
        if(offset > 2){
            UIView.animate(withDuration: 0.3, animations: {
                self.infoViewHeigth.constant = 40
                self.addButtonHeigth.constant = 0
                self.pictureHeigth.constant = 0
                self.runtimeTop.constant = -12
                self.releaseTop.constant = -12
                self.watchersTop.constant = -12
                self.view.layoutIfNeeded()
                self.navigationItem.title = self.person?.name
                self.name.text = ""
            })
        }
        else {
            UIView.animate(withDuration: 0.3, animations: {
                self.infoViewHeigth.constant = 162
                self.addButtonHeigth.constant = 30
                self.pictureHeigth.constant = 135
                self.runtimeTop.constant = 8
                self.releaseTop.constant = 8
                self.watchersTop.constant = 8
                self.view.layoutIfNeeded()
                self.navigationItem.title = ""
                self.name.text = self.person?.name
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let offset = tableView.contentOffset.y;
        if(offset > 2) {
            self.title = person?.name
        }
    }
    
    @objc func viewAllSegue(sender: UIButton) {
        switch sender.tag {
        case 0:
            self.performSegue(withIdentifier: "viewPersonCredits", sender: self)
        case 5:
            self.performSegue(withIdentifier: "viewAllImages", sender: self)
        default:
            return
        }
    }
    
    @IBAction func searchClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: {});
        self.navigationController?.popToRootViewController(animated: true);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieDetails" {
            if let collectionCell:  FilmographyCollectionViewCell = sender as? FilmographyCollectionViewCell {
                if let collectionView: UICollectionView = collectionCell.superview as? UICollectionView {
                    if let destination = segue.destination as? MovieInfoViewController {
                        let vc = segue.destination as! MovieInfoViewController
                        self.title = ""
                        if(collectionCell.tag < (credits?.cast.count)!) {
                            let id = credits?.cast[collectionCell.tag].id
                            vc.id = id
                        } else {
                            let id = credits?.crew[collectionCell.tag].id
                            vc.id = id
                        }
                    }
                }
            }
        }
    
        /*if segue.identifier == "viewPersonCredits"{
            let vc = segue.destination as! ViewAllViewController
            vc.personCredits = credits
            self.title = ""
            vc.title = person?.name
        }*/
        
        if segue.identifier == "viewAllImages" {
            let vc = segue.destination as! ViewAllImagesViewController
            vc.objectToSort = images
            vc.title = person?.name
            self.title = ""
        }
    }
}
