//
//  ViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/11/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        self.tabBar.backgroundColor = UIColor.whiteColor()
        for item in self.tabBar.items! {
            item.image!.awakeFromNib()
        }
        self.awakeFromNib()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
