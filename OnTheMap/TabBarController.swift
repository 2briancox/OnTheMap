//
//  ViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/11/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController{
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.items!.first!.image = UIImage(named: "Map_Icon")
        self.tabBar.items!.last!.image = UIImage(named: "People_Icon")
    }
}
