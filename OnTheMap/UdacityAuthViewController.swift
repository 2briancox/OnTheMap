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
    
    @IBAction func LoginButtonPressed(sender: UIButton) {
        view.endEditing(true)
        login()
    }
    
    
    @IBAction func SignupButtonPressed(sender: UIButton) {
        let signupURL = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.sharedApplication().openURL(NSURL(string:signupURL)!)
    }
    
    
    override func viewDidLoad() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
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
                DataModel.sharedInstance().key = key!
                DataModel.sharedInstance().id = id!
                self.getUserData()
            } else {
                self.showAlertWithText("Login Error", message: errorString!)
            }
        }
    }
    
    
    func getUserData() {
        Client.sharedInstance().getUserData(DataModel.sharedInstance().key) { (firstName, lastName , errorString) in
            if errorString == nil {
                DataModel.sharedInstance().userFirstName = firstName!
                DataModel.sharedInstance().userLastName = lastName!
                self.getAllStudents()
            } else {
                self.showAlertWithText("Server Error", message: errorString!)
            }
        }
    }
    
    
    func getAllStudents() {
        Client.sharedInstance().getAllStudents(DataModel.sharedInstance().key) { (mediaURL, longitude, latitude, errorString) in
            if errorString == nil {
                DataModel.sharedInstance().userMediaURL = mediaURL!
                DataModel.sharedInstance().userLatitude = latitude!
                DataModel.sharedInstance().userLongitude = longitude!
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
            passwordTextField.becomeFirstResponder()
            return true
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        view.endEditing(true)
    }
    
    
    func showAlertWithText (header : String = "Warning", message : String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.animateBackgroundColor()
        }
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func animateBackgroundColor() {
        var finalColor: UIColor!

        finalColor = UIColor.redColor()
        
        let changeColor = CATransition()
        changeColor.type = kCATransitionFade
        changeColor.duration = 0.2
        
        let oldColor = view.backgroundColor
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock {
            self.view.backgroundColor = oldColor
            self.view.layer.addAnimation(changeColor, forKey: nil)
        }
        view.backgroundColor = finalColor
        view.layer.addAnimation(changeColor, forKey: nil)
        
        CATransaction.commit()
    }
    
}