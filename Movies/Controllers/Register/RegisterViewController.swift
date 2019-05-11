//
//  RegisterViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 16/07/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func nextTouched(_ sender: Any) {
        
        guard
            let email = email.text,
            let password = password.text,
            email.count > 0,
            password.count > 0
            else {
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Registration Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else {
                guard let firUser = Auth.auth().currentUser,
                    let username = self.username.text,
                    !username.isEmpty else { return }
                let userAttrs = ["username": username]
                let ref = Database.database().reference().child("users").child(firUser.uid)
                ref.setValue(userAttrs) { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                        return
                    }
                }
            }
        }
    }
}
