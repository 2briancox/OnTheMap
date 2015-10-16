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
    var appDelegate: AppDelegate = AppDelegate()
    
    @IBOutlet weak var urlTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let object = UIApplication.sharedApplication().delegate
        appDelegate = object as! AppDelegate
        urlTextField.delegate = self
    }
    
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        if urlTextField.text == "" {
            showAlertWithText("URL Error", message: "The URL must not be blank")
        } else if (urlTextField.text! as NSString).substringToIndex(8) != "https://" && (urlTextField.text! as NSString).substringToIndex(7) != "http://" {
            showAlertWithText("URL Error", message: "URLs must begin either with \"https://\" or \"http://\".")
        } else {
            let person: StudentInformation = StudentInformation(personDict: ["firstName": appDelegate.userFirstName, "lastName": appDelegate.userLastName, "mediaURL": self.urlTextField.text! as String, "uniqueKey": appDelegate.key, "latitude": passedLatitude, "longitude": passedLongitude, "mapString":passedLocation])
            if appDelegate.userMediaURL == ""
            {
                Client.sharedInstance().postStudentInfo(person) { (errorString) in
                    if errorString == nil {
                        self.getAllStudents()
                    } else {
                        self.showAlertWithText("Login Error", message: errorString!)
                    }
                }
                
            } else {
                Client.sharedInstance().updateStudentInfo(self.appDelegate.id, person: person) { (data, errorString) in
                    if errorString == nil {
                        let parsedJSON = (try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)) as! Dictionary<String, AnyObject>
                        if !Array(parsedJSON.keys).contains("results") {
                            self.showAlertWithText("Update Error", message: "The server was unable to update your account.")
                            return
                        }
                        if let responseArray: Dictionary<String, AnyObject> = (parsedJSON["results"] as! Dictionary<String, AnyObject>) {
                            print(responseArray)
                            if Array(responseArray.keys).contains("error") {
                                self.showAlertWithText("Update Error", message: "The server was unable to update your account.")
                                return
                            }
                        } else {
                            self.getAllStudents()
                        }
                    } else {
                        self.showAlertWithText("Update Error", message: errorString!)
                    }
                }
            }
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        shareButtonPressed(UIButton())
        return true
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    
    func getAllStudents() {
        Client.sharedInstance().getAllStudents(appDelegate.key) { (people, mediaURL, longitude, latitude, errorString) in
            if errorString == nil {
                self.appDelegate.people = people!
                self.appDelegate.userMediaURL = mediaURL!
                self.appDelegate.userLatitude = latitude!
                self.appDelegate.userLongitude = longitude!
                self.appDelegate.shouldReload = true
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.showAlertWithText("Server Error", message: errorString!)
            }
        }
    }
    
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func showAlertWithText (header : String = "Warning", message : String) {
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
