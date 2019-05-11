//
//  LoginViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 10/07/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        /*Auth.auth().addStateDidChangeListener() { auth, user in
            // 2
            if user != nil {
                // 3
                self.performSegue(withIdentifier: "login", sender: nil)
                self.username.text = nil
                self.password.text = nil
            }
        }*/
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginAction(_ sender: Any) {
        guard
            let email = username.text,
            let password = password.text,
            email.count > 0,
            password.count > 0
            else {
                return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            } else {
                let currentUser = Auth.auth().currentUser
                if currentUser != nil
                {
                    UserFirebase.getCurrentUser(completion: { (user) in
                        currentUserFirebase = user
                        UserFirebase.getMoviesIdWatched(user: currentUserFirebase!, completion: { (ids) in
                            currentUserFirebase?.moviesWatchedId = ids
                            UserFirebase.getMoviesIdFavourites(user: currentUserFirebase!, completion: { (ids) in
                                currentUserFirebase?.favouritesMoviesId = ids
                                self.performSegue(withIdentifier: "login", sender: nil)
                                self.username.text = nil
                                self.password.text = nil
                            })
                        })
                    })
                }
            }
        }
    }
}
