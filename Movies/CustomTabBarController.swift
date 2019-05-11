//
//  CustomTabBarController.swift
//  Movies
//
//  Created by Andrea Spinazzola on 14/03/2019.
//  Copyright © 2019 Andrea Spinazzola. All rights reserved.
//

import UIKit

class CustomTabBarController:  UITabBarController, UITabBarControllerDelegate {
    
    var firstViewController: SearchMovieTableViewController!
    var secondViewController: DiscoverTableViewController!
    var thirdViewController: CurrentUserInfoViewController!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.delegate = self
        
        firstViewController = SearchMovieTableViewController()
        secondViewController = DiscoverTableViewController()
        thirdViewController = CurrentUserInfoViewController()
        
        viewControllers = [firstViewController, secondViewController, thirdViewController]
    }
    
    //MARK: UITabbar Delegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: CurrentUserInfoViewController.self) {
            let vc =  CurrentUserInfoViewController()
            vc.user = UserFirebase(userID: "prova")
            self.present(vc, animated: true, completion: nil)
            return false
        }
        return true
    }
    
}
