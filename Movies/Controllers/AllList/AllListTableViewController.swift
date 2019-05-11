//
//  AllListTableViewController.swift
//  Movies
//
//  Created by Andrea Spinazzola on 13/02/2019.
//  Copyright © 2019 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift

class AllListTableViewController: UITableViewController {
    
    var movie: MovieMDB!

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let lists = currentUserFirebase?.lists {
            return lists.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as! AllListTableViewCell

        cell.nameLabel.text = currentUserFirebase?.lists![indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = currentUserFirebase?.lists![indexPath.row]
        var contain = 0
        for i in (list?.moviesId)! {
            if(movie.id == i) {
                contain = 1
            }
        }
        if(contain == 0) {
            list?.addMovie(id: movie.id, completion: { (error) in
                if(error == nil) {
                    let alert = UIAlertController(title: "The movie has been added to your list", message: nil, preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when){
                        // your code with delay
                        alert.dismiss(animated: true, completion: nil)
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            })
        } else {
            let alert = UIAlertController(title: "This movies is already present in your list", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
}

class AllListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
