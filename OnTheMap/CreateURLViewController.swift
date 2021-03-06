//
//  CreateURLViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/14/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit

class CreateURLViewController: UIViewController, UITextFieldDelegate {
    
    var passedLocation: String = ""
    var passedLatitude: Double = 0.0
    var passedLongitude: Double = 0.0
    var objectID: String = ""
    
    var urlToPass: NSURL? = nil
    
    @IBOutlet weak var urlTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextField.delegate = self
    }
    
    
    @IBAction func testButtonPressed(sender: UIButton) {
        
        if urlTextField.text == "" {
            showAlertWithText("URL Error", message: "The URL must not be blank")
        } else if (urlTextField.text! as NSString).substringToIndex(8) != "https://" && (urlTextField.text! as NSString).substringToIndex(7) != "http://" {
            showAlertWithText("URL Error", message: "URLs must begin either with \"https://\" or \"http://\".")
        } else {
            let enteredURL = NSURL(string: urlTextField.text!)
            if enteredURL == nil {
                showAlertWithText("URL Error", message: "This is not a valid URL.  Please type a valid URL.")
            } else {
                urlToPass = enteredURL
                performSegueWithIdentifier("showWeb", sender: self)
            }
        }
    }
    
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        if urlTextField.text == "" {
            showAlertWithText("URL Error", message: "The URL must not be blank")
        } else if (urlTextField.text! as NSString).substringToIndex(8) != "https://" && (urlTextField.text! as NSString).substringToIndex(7) != "http://" {
            showAlertWithText("URL Error", message: "URLs must begin either with \"https://\" or \"http://\".")
        } else {
            if DataModel.sharedInstance().userMediaURL == "" {
                self.postStudentInfo()
            } else {
                self.queryStudentLocation()
            }
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        shareButtonPressed(UIButton())
        return true
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    
    func getAllStudents() {
        Client.sharedInstance().getAllStudents(DataModel.sharedInstance().key) { (mediaURL, longitude, latitude, errorString) in
            if errorString == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    DataModel.sharedInstance().userMediaURL = mediaURL!
                    DataModel.sharedInstance().userLatitude = latitude!
                    DataModel.sharedInstance().userLongitude = longitude!
                    DataModel.sharedInstance().shouldReload = true
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                self.showAlertWithText("Server Error", message: errorString!)
            }
        }
    }
    
    
    func postStudentInfo() {
        let person: StudentInformation = StudentInformation(personDict: ["firstName": DataModel.sharedInstance().userFirstName, "lastName": DataModel.sharedInstance().userLastName, "mediaURL": self.urlTextField.text! as String, "uniqueKey": DataModel.sharedInstance().key, "latitude": passedLatitude, "longitude": passedLongitude, "mapString":passedLocation])
        Client.sharedInstance().postStudentInfo(person) { (errorString) in
            if errorString == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.getAllStudents()
                }
            } else {
                self.showAlertWithText("Login Error", message: errorString!)
            }
        }
    }
    
    
    func queryStudentLocation() {
        Client.sharedInstance().queryStudentLocation() { (objectID, errorString) in
            if errorString == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.objectID = objectID!
                    self.updateStudentInfo()
                }
            } else {
                self.showAlertWithText("Login Error", message: errorString!)
            }
        }
    }
    
    
    func updateStudentInfo() {
        let person: StudentInformation = StudentInformation(personDict: ["firstName": DataModel.sharedInstance().userFirstName, "lastName": DataModel.sharedInstance().userLastName, "mediaURL": self.urlTextField.text! as String, "uniqueKey": DataModel.sharedInstance().key, "latitude": passedLatitude, "longitude": passedLongitude, "mapString":passedLocation])
        Client.sharedInstance().updateStudentInfo(objectID, person: person) { (data, errorString) in
            if errorString == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.getAllStudents()
                }
            } else {
                self.showAlertWithText("Update Error", message: errorString!)
            }
        }
    }
    
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWeb" {
            let vc = segue.destinationViewController as! WebViewController
            vc.theURL = urlToPass
        }
    }
    
    
    func showAlertWithText (header : String = "Warning", message : String) {
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
