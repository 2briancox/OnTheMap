//
//  WebViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/21/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    var theURL: NSURL? = nil
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = NSURLRequest(URL: theURL!)
        webView.loadRequest(request)
    }

    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
