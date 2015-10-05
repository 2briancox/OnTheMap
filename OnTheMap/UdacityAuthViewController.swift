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

    
    func login() {
        
        guard let password: String = passwordTextField.text else {
            showAlertWithText("Password Error", message: "A password must be entered")
            return
        }
        
        guard let username: String = usernameTextField.text else {
            showAlertWithText("Username Errror", message: "A username must be entered")
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil { // Handle error…
                self.showAlertWithText("Server Error", message: "The server connection failed.  Please try again later.")
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            let parsed = (try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)) as! [String: AnyObject]
            
            let keys = Array(parsed.keys)
            print(keys)
            
            if keys[0] != "session" {
                print("Error logging in")
                self.showAlertWithText("Bad Login", message: "Either the email address or password is incorrect.")
                return
            } else {
                
                let object = UIApplication.sharedApplication().delegate
                let appDelegate = object as! AppDelegate
                
                let account = parsed["account"] as! Dictionary<String, AnyObject>
                
                let session = parsed["session"] as! Dictionary<String, AnyObject>
                
                appDelegate.key = account["key"] as! String
                appDelegate.id = session["id"] as! String
                
                print(appDelegate.key)
                print(appDelegate.id)
                
                self.performSegueWithIdentifier("loginCompleteSegue", sender: self)
            }
        }
        task.resume()
    }
    
    @IBAction func SignupButtonPressed(sender: UIButton) {
        let signupURL = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.sharedApplication().openURL(NSURL(string:signupURL)!)
    }

        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(passwordTextField) {
            textField.resignFirstResponder()
            login()
            return true
        }
        textField.resignFirstResponder()
        return true
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y = 0.0
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0.0
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
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
