//
//  CommentsTableViewController.swift
//  Movies
//
//  Created by Andrea Spinazzola on 04/10/2018.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseStorage
import TMDBSwift

class CommentsTableViewController: UITableViewController {
    
    var movie: MovieMDB!
    var postArray = [Post]()
    var postToPass = Post()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Post.getPost(movie: movie) { (postReturned) in
            if(postReturned != nil) {
                self.postArray = postReturned!
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = movie.title
        Post.getPost(movie: movie) { (postReturned) in
            if(postReturned != nil) {
                self.postArray = postReturned!
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return postArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(postArray[section].postComments.count < 3) {
            return 2 + postArray[section].postComments.count
        } else {
            return 5
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            cell.message.text = postArray[indexPath.section].text
            let user = UserFirebase(userEmail: "", userID: String(postArray[indexPath.section].userId!))
            UserFirebase.getUserByUID(id: user.uid!) { (returnUser) in
                if(returnUser != nil) {
                    cell.username.setTitle(returnUser!.username, for: .normal)
                    if let profilePictureURL = returnUser!.profilePictureUrl {
                        let filePath = "profile_images/\(profilePictureURL).png"
                        // Assuming a < 10MB file, though you can change that
                        let storageRef = Storage.storage().reference()
                        storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                            let userPhoto = UIImage(data: data!)
                            cell.profilePicture.image = userPhoto
                            cell.setNeedsDisplay()
                        })
                    }
                    /*if(self.postArray[indexPath.row].gifUrl != nil) {
                        cell.imageHeigth.constant = 130
                        let url = URL(string: self.postArray[indexPath.row].gifUrl!)
                        ImagePipeline.Configuration.isAnimatedImageDataEnabled = true

                        Nuke.loadImage(with: url!, into: cell.imagePost)
                    }*/
                }
            }
            if(postArray[indexPath.section].likes != nil) {
                if((postArray[indexPath.section].likes.contains((currentUserFirebase?.uid)!))) {
                    cell.likeImage.image = UIImage(named: "favorite-heart-button")
                } else {
                    cell.likeImage.image = UIImage(named: "hearth")
                }
            }
            cell.likeCounter.text = String(postArray[indexPath.section].likes.count)
            cell.likeCounter.text = String(postArray[indexPath.section].postComments.count)
            cell.likeButton.tag = indexPath.section
            cell.likeButton.addTarget(self, action: #selector(self.likePressed(_:)), for: .touchUpInside)
            cell.commentButton.tag = indexPath.section
            cell.commentButton.addTarget(self, action: #selector(self.commentPressed(_:)), for: .touchUpInside)
            return cell
        }
        if(indexPath.row > 0 && indexPath.row < 4 && indexPath.row < postArray[indexPath.section].postComments.count + 1  && postArray[indexPath.section].postComments.count != 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
            cell.message.text = postArray[indexPath.section].postComments[indexPath.row - 1].text
            let user = UserFirebase(userEmail: "", userID: String(postArray[indexPath.section].postComments[indexPath.row - 1].userId))
            UserFirebase.getUserByUID(id: user.uid!) { (returnUser) in
                if(returnUser != nil) {
                    cell.username.setTitle(returnUser!.username, for: .normal)
                    if let profilePictureURL = returnUser!.profilePictureUrl {
                        let filePath = "profile_images/\(profilePictureURL).png"
                        // Assuming a < 10MB file, though you can change that
                        let storageRef = Storage.storage().reference()
                        storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                            let userPhoto = UIImage(data: data!)
                            cell.profilePicture.image = userPhoto
                            cell.setNeedsDisplay()
                        })
                    }
                }
            }
            return cell
        }
        
        if((indexPath.row == postArray[indexPath.section].postComments.count + 1 && postArray[indexPath.section].postComments.count <= 3) || (indexPath.row == 4 && postArray[indexPath.section].postComments.count > 3)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "viewAllComments", for: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if((indexPath.row == postArray[indexPath.section].postComments.count + 1 && postArray[indexPath.section].postComments.count <= 3) || (indexPath.row == 4 && postArray[indexPath.section].postComments.count > 3)){
         
            postToPass = postArray[indexPath.section]
            self.performSegue(withIdentifier: "viewAllComments", sender: self)
        }
            
    }

    @objc func likePressed(_ sender: UIButton) {
        var done = 0
        if(self.postArray[sender.tag].likes != nil) {
            if((postArray[sender.tag].likes.contains((currentUserFirebase?.uid)!))) {
                done = 1
                postArray[sender.tag].removeLike(movie: movie) { (error) in
                    if(error == nil) {
                        var count = 0
                        for i in self.postArray[sender.tag].likes {
                            if(self.postArray[sender.tag].likes[count] == currentUserFirebase?.uid) {
                                self.postArray[sender.tag].likes.remove(at: count)
                            }
                            count += 1
                        }
                    }
                    self.tableView.reloadData()
                    return
                }
            }
        }
        if(done == 0) {
            postArray[sender.tag].addLike(movie: movie) { (error) in
                if(error == nil) {
                    if(self.postArray[sender.tag].likes == nil) {
                        self.postArray[sender.tag].likes = [currentUserFirebase?.uid] as! [String]
                    } else {
                        self.postArray[sender.tag].likes.append((currentUserFirebase?.uid)!)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func commentPressed(_ sender: UIButton) {
        postArray[sender.tag].addComment(movie: movie, message: "bel commento") { (error) in
            if(error == nil) {
                let comment = PostComment(text: "bel commento", userId: currentUserFirebase?.uid, date: "date")
                self.postArray[sender.tag].postComments.append(comment)
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createPost" {
            let vc = segue.destination as! CreatePostViewController
            vc.title = movie?.title
            vc.movie = movie
            self.title = ""
        }
        if segue.identifier == "viewAllComments" {
            let vc = segue.destination as! CommentViewController
            vc.post = postToPass
            vc.movie = movie
            vc.title = self.title
        }
    }
}
