//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/3/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate{

    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        
        
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        let locations = hardCodedLocationData()
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for dictionary in locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
            let long = CLLocationDegrees(dictionary["longitude"] as! Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary["firstName"] as! String
            let last = dictionary["lastName"] as! String
            let mediaURL = dictionary["mediaURL"] as! String
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                self.showAlertWithText("Serever Error", message: "The server did not logout properly")
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            self.removeFromParentViewController()
            
            self.performSegueWithIdentifier("logoutMapSegue", sender: self)
        }
        
        task.resume()
    }
    
    func showAlertWithText (header : String = "Warning", message : String) {
            let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .InfoLight)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    
    func mapViewWillStartRenderingMap(mapView: MKMapView) {
        self.tabBarController?.tabBar.viewWithTag(2)
    }
    // MARK: - Sample Data
    
    // Some sample data. This is a dictionary that is more or less similar to the
    // JSON data that you will download from Parse.
    
    func hardCodedLocationData() -> [[String : AnyObject]] {
        return  [
            [
                "createdAt" : "2015-02-24T22:27:14.456Z",
                "firstName" : "Jessica",
                "lastName" : "Uelmen",
                "latitude" : 28.1461248,
                "longitude" : -82.75676799999999,
                "mapString" : "Tarpon Springs, FL",
                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
                "objectId" : "kj18GEaWD8",
                "uniqueKey" : 872458750,
                "updatedAt" : "2015-03-09T22:07:09.593Z"
            ], [
                "createdAt" : "2015-02-24T22:35:30.639Z",
                "firstName" : "Gabrielle",
                "lastName" : "Miller-Messner",
                "latitude" : 35.1740471,
                "longitude" : -79.3922539,
                "mapString" : "Southern Pines, NC",
                "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
                "objectId" : "8ZEuHF5uX8",
                "uniqueKey" : 2256298598,
                "updatedAt" : "2015-03-11T03:23:49.582Z"
            ], [
                "createdAt" : "2015-02-24T22:30:54.442Z",
                "firstName" : "Jason",
                "lastName" : "Schatz",
                "latitude" : 37.7617,
                "longitude" : -122.4216,
                "mapString" : "18th and Valencia, San Francisco, CA",
                "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
                "objectId" : "hiz0vOTmrL",
                "uniqueKey" : 2362758535,
                "updatedAt" : "2015-03-10T17:20:31.828Z"
            ], [
                "createdAt" : "2015-03-11T02:48:18.321Z",
                "firstName" : "Jarrod",
                "lastName" : "Parkes",
                "latitude" : 34.73037,
                "longitude" : -86.58611000000001,
                "mapString" : "Huntsville, Alabama",
                "mediaURL" : "https://linkedin.com/in/jarrodparkes",
                "objectId" : "CDHfAy8sdp",
                "uniqueKey" : 996618664,
                "updatedAt" : "2015-03-13T03:37:58.389Z"
            ]
        ]
    }
}
