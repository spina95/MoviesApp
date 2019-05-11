//
//  SortTableViewController.swift
//  Movies
//
//  Created by Andrea Spinazzola on 21/02/2019.
//  Copyright © 2019 Andrea Spinazzola. All rights reserved.
//

import UIKit

protocol isAbleToReceiveData {
    func pass(data: Int, inverted: Bool)  //data: string is an example parameter
}

class SortTableViewController: UITableViewController {

    var selectedIndex: Int!
    var indexToPass: Int!
    var inverted: Bool = false
    var delegate: isAbleToReceiveData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate.pass(data: indexToPass, inverted: inverted) //call the func in the previous vc
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sortCell", for: indexPath) as! SortTableViewCell
        cell.dotView.isHidden = true
        cell.sortButton.isHidden = true

        if(indexPath.row == selectedIndex) {
            cell.dotView.isHidden = false
            cell.sortButton.isHidden = false
        }
        if(inverted == false){
            cell.sortButton.setImage(UIImage(named: "sort1"), for: .normal)
        }
        if(inverted == true){
            cell.sortButton.setImage(UIImage(named: "sort2"), for: .normal)
        }
        cell.sortButton.addTarget(self, action:#selector(invert), for: .touchUpInside)
        switch indexPath.row {
        case 0:
            cell.nameLabel.text = "Date added"
        case 1:
            cell.nameLabel.text = "Alphabetical by title"
        case 2:
            cell.nameLabel.text = "Average rating"
        case 3:
            cell.nameLabel.text = "Your rating"
        case 4:
            cell.nameLabel.text = "Runtime"
        default:
            cell.nameLabel.text = ""
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.tableView.reloadData()
    }
    
    
    @IBAction func sort(_ sender: Any) {
        indexToPass = selectedIndex
        navigationController?.popViewController(animated: true)
    }
    
    @objc func invert() {
        if(inverted == true) {
            inverted = false
        } else {
            inverted = true
        }
        self.tableView.reloadData()
    }
}

class SortTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sortButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dotView.roundCorners(value: Double(Int(dotView.frame.height/2)))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
