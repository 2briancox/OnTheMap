//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/3/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var appDelegate:AppDelegate = AppDelegate()
    var meAnnotation: Int = 200
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var locationBarButtonIcon: UIBarButtonItem!

    @IBAction func locationButtonPressed(sender: UIBarButtonItem) {
        if appDelegate.userMediaURL == "" {
            self.performSegueWithIdentifier("mapToSearch", sender: self)
        } else {
            selectMe()
            let checkOK = UIAlertController(title: "Location already entered", message: "Are you sure you want to change your existing OnTheMap location?", preferredStyle: UIAlertControllerStyle.ActionSheet)
            checkOK.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                checkOK in
                    self.performSegueWithIdentifier("mapToSearch", sender: self)
            }))
            checkOK.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(checkOK, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let object = UIApplication.sharedApplication().delegate
        appDelegate = object as! AppDelegate
        
        mapView.delegate = self
        
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        if appDelegate.userMediaURL != "" {
            locationBarButtonIcon.image = UIImage(named: "YourLocation")
        }
        if appDelegate.shouldReload {
            appDelegate.shouldReload = false
            loadData()
        }
    }
    
    func selectMe() {
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: appDelegate.userLatitude, longitude: appDelegate.userLongitude)
        mapView.region = mapView.regionThatFits(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(CLLocationDegrees(5.0), CLLocationDegrees(5.0))))
        var me = 200
        for var i = 0; i < mapView.annotations.count; i++ {
            if mapView.annotations[i].coordinate.latitude == appDelegate.userLatitude && mapView.annotations[i].coordinate.longitude == appDelegate.userLongitude {
                me = i
            }
        }
        mapView.selectAnnotation(mapView.annotations[me], animated: true)
    }
    
    func openSearch() {
        performSegueWithIdentifier("mapToSearch", sender: self)
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
                self.dismissViewControllerAnimated(true, completion: nil)
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
    
    
    func loadData() {
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
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
    }
    
}
