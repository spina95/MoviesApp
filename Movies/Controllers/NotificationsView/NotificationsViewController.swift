//
//  NotificationsViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 08/08/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit

class NotificationsViewController: UITableViewController {
    
    var followRequest = [UserFirebase]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "Notifications"
        FriendSystem.system.addRequestObserver {
            self.followRequest = FriendSystem.system.requestList
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followRequest.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followRequestCell", for: indexPath) as! FollowRequestNotificationTableViewCell
        if(followRequest != nil){
            var user = followRequest[indexPath.row]
            if(user.uid != nil) {
                UserFirebase.getUserByUID(id: user.uid!) { (user) in
                    if let name = user?.username {
                        cell.message.text = "\(name) sent you a follow request"
                    }
                    cell.acceptButton.tag = indexPath.row
                    cell.refuseButton.tag = indexPath.row
                    cell.acceptButton.addTarget(self, action:#selector(self.acceptRequest(sender:)), for: .touchUpInside)
                }
                                    
            }
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func acceptRequest(sender: UIButton) {
        FriendSystem.system.acceptFollowerRequest(followRequest[sender.tag].uid!)
    }
        
}
