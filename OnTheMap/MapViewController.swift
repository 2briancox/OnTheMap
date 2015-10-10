//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/3/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    var appDelegate:AppDelegate = AppDelegate()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let object = UIApplication.sharedApplication().delegate
        appDelegate = object as! AppDelegate
        
        mapView.delegate = self
        
        dispatch_async(dispatch_get_main_queue()) {
            let locations = self.appDelegate.people

            var annotations = [MKPointAnnotation]()
            
            for dictionary in locations {

                let lat = CLLocationDegrees(dictionary.latitude)
                let long = CLLocationDegrees(dictionary.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let first = dictionary.firstName
                let last = dictionary.lastName
                let mediaURL = dictionary.mediaURL
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                annotations.append(annotation)
            }
            
            self.mapView.addAnnotations(annotations)
        }
        
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
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
    
    
    func showAlertWithText (header : String = "Warning", message : String) {
            let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        self.mapView.alpha = 1.0
        self.activityIndicator.stopAnimating()
    }
    
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        self.mapView.alpha = 0.4
        self.activityIndicator.startAnimating()
    }
    
}
