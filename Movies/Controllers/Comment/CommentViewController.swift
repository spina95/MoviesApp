//
//  CommentViewController.swift
//  Movies
//
//  Created by Andrea Spinazzola on 01/12/2018.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import TMDBSwift
import IQKeyboardManagerSwift

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendbuttonView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    var post: Post!
    var movie: MovieMDB!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        textView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                bottomConstraint.constant = keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint.constant = 0

        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.translatesAutoresizingMaskIntoConstraints = true
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        if(newSize.height < 80) {
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        } else {
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: 80)
        }
        textView.frame = newFrame
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 0) {
            return 1
        }
        if(section == 1) {
            return post.postComments.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            cell.message.text = post.text
            let user = UserFirebase(userEmail: "", userID: String(post.userId!))
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
            /*if(postArray[indexPath.section].likes != nil) {
                if((postArray[indexPath.section].likes?.contains((currentUserFirebase?.uid)!))!) {
                    cell.likeImage.image = UIImage(named: "favorite-heart-button")
                } else {
                    cell.likeImage.image = UIImage(named: "hearth")
                }
            }
            cell.likeButton.tag = indexPath.section
            cell.likeButton.addTarget(self, action: #selector(self.likePressed(_:)), for: .touchUpInside)
            cell.commentButton.tag = indexPath.section
            cell.commentButton.addTarget(self, action: #selector(self.commentPressed(_:)), for: .touchUpInside) */
            return cell
        }
        if(indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
            cell.message.text = post.postComments[indexPath.row].text
            let user = UserFirebase(userEmail: "", userID: String(post.postComments[indexPath.row].userId))
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
        return UITableViewCell()
    }
    
    @IBAction func sendComment(_ sender: Any) {
        if(textView.text.characters.count != 0) {
            let postComment = PostComment(text: textView.text, userId: currentUserFirebase?.uid, date: "10 May 2018")
            post.addComment(movie: movie, message: textView.text) { (error) in
                if(error == nil) {
                    let postComment = PostComment(text: self.textView.text, userId: currentUserFirebase?.uid, date: "date")
                    self.post.postComments.append(postComment)
                    self.textView.text = ""
                    self.tableView.reloadData()
                    let indexPath = IndexPath(row: self.post.postComments.count - 1, section: 1)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }    
}
