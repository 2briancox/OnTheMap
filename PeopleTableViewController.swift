//
//  PeopleTableViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/4/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit

class PeopleTableViewController: UITableViewController {

    var appDelegate:AppDelegate = AppDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let object = UIApplication.sharedApplication().delegate
        appDelegate = object as! AppDelegate
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.people.count
    }
    

    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        Client.sharedInstance().performLogout() { (errorString) in
            if errorString != nil {
                self.showAlertWithText("Error", message: errorString!)
            } else {
                self.navigationController?.popToRootViewControllerAnimated(true)
                self.performSegueWithIdentifier("logoutMapSegue", sender: self)
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell", forIndexPath: indexPath) as! StudentTableCell
        cell.nameLabel.text = appDelegate.people[indexPath.row].firstName + " " + appDelegate.people[indexPath.row].lastName
        if appDelegate.people[indexPath.row].uniqueKey == appDelegate.key && appDelegate.people[indexPath.row].firstName == appDelegate.userFirstName && appDelegate.people[indexPath.row].lastName == appDelegate.userLastName {
            cell.locationIcon.image = UIImage(named: "YourLocation")
        } else {
            cell.locationIcon.image = UIImage(named: "Location")
        }
        cell.locationLabel.text = appDelegate.people[indexPath.row].mapString
        cell.linkLabel.text = appDelegate.people[indexPath.row].mediaURL
        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: appDelegate.people[indexPath.row].mediaURL)!)
    }
    
    
    func showAlertWithText (header : String = "Warning", message : String) {
            let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
    }
}
