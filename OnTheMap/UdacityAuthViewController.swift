//
//  UdacityAuthViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/3/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit

class UdacityAuthViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var appDelegate:AppDelegate = AppDelegate()
    
    @IBAction func LoginButtonPressed(sender: UIButton) {
        view.endEditing(true)
        login()
    }

    
    override func viewDidLoad() {
        let object = UIApplication.sharedApplication().delegate
        appDelegate = object as! AppDelegate
    }
    
    
    @IBAction func SignupButtonPressed(sender: UIButton) {
        let signupURL = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.sharedApplication().openURL(NSURL(string:signupURL)!)
    }
    
    
    func login() {
        
        guard let password: String = passwordTextField.text else {
            showAlertWithText("Password Error", message: "A password must be entered.")
            return
        }
        
        guard let username: String = usernameTextField.text else {
            showAlertWithText("Username Errror", message: "A username must be entered.")
            return
        }
        
        Client.sharedInstance().performLogin(username, password: password) { (key, id , errorString) in
            if errorString == nil {
                self.appDelegate.key = key!
                self.appDelegate.id = id!
                self.getUserData()
            } else {
                self.showAlertWithText("Error", message: errorString!)
            }
        }
    }
    
    
    func getUserData() {
        Client.sharedInstance().getUserData(appDelegate.key) { (firstName, lastName , errorString) in
            if errorString == nil {
                self.appDelegate.userFirstName = firstName!
                self.appDelegate.userLastName = lastName!
                self.getAllStudents()
            } else {
                self.showAlertWithText("Server Error", message: errorString!)
            }
        }
    }
    
    
    func getAllStudents() {
        Client.sharedInstance().getAllStudents(appDelegate.key) { (people, mediaURL, longitude, latitude, errorString) in
            if errorString == nil {
                self.appDelegate.people = people!
                self.appDelegate.userMediaURL = mediaURL!
                self.appDelegate.userLatitude = latitude!
                self.appDelegate.userLongitude = longitude!
                self.performSegueWithIdentifier("loginCompleteSegue", sender: self)
            } else {
                self.showAlertWithText("Server Error", message: errorString!)
            }
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(passwordTextField) {
            textField.resignFirstResponder()
            login()
            return true
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func showAlertWithText (header : String = "Warning", message : String) {
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}