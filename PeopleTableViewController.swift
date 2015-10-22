//
//  PeopleTableViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/4/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit
import MapKit

class PeopleTableViewController: UITableViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationButton: UIBarButtonItem!
    
    @IBAction func locationButtonPresed(sender: UIBarButtonItem) {
        DataModel.sharedInstance().shouldReload = false
        if DataModel.sharedInstance().userMediaURL == "" {
            self.performSegueWithIdentifier("tableToSearch", sender: self)
        } else {
            for var i = 0; i < DataModel.sharedInstance().people.count; i++ {
                if DataModel.sharedInstance().people[i].uniqueKey == DataModel.sharedInstance().key  {
                    tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: i, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                }
            }
            let checkOK = UIAlertController(title: "Location already entered", message: "Are you sure you want to change your existing OnTheMap location?", preferredStyle: UIAlertControllerStyle.Alert)
            checkOK.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                checkOK in
                self.performSegueWithIdentifier("tableToSearch", sender: self)
            }))
            checkOK.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(checkOK, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if DataModel.sharedInstance().userMediaURL != "" {
            locationButton.image = UIImage(named: "YourLocation")
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataModel.sharedInstance().people.count
    }
    

    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        Client.sharedInstance().performLogout() { (errorString) in
            if errorString != nil {
                self.showAlertWithText("Error", message: errorString!)
            } else {
                self.navigationController?.popToRootViewControllerAnimated(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell", forIndexPath: indexPath) as! StudentTableCell
        cell.nameLabel.text = DataModel.sharedInstance().people[indexPath.row].firstName + " " + DataModel.sharedInstance().people[indexPath.row].lastName
        if DataModel.sharedInstance().people[indexPath.row].uniqueKey == DataModel.sharedInstance().key  {
            cell.locationIcon.image = UIImage(named: "YourLocation")
        } else {
            cell.locationIcon.image = UIImage(named: "Location")
        }
        cell.locationLabel.text = DataModel.sharedInstance().people[indexPath.row].mapString
        cell.linkLabel.text = DataModel.sharedInstance().people[indexPath.row].mediaURL
        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: DataModel.sharedInstance().people[indexPath.row].mediaURL)!)
    }
    
    
    func showAlertWithText (header : String = "Warning", message : String) {
            let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
    }
}
