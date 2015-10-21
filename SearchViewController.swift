//
//  SearchViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/11/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    var location: String = ""
    var lat: Double = 0.0
    var long: Double = 0.0
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationTextField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func searchButtonPressed(sender: UIButton) {
        if locationTextField.text == "" {
            showAlertWithText("Location Field Empty", message: "Please enter a location.")
        } else {
            let loc = CLGeocoder()
            loc.geocodeAddressString(locationTextField.text!) { (placemarks, error) -> Void in
                
                if let firstPlacemark = placemarks?[0] {
                        
                    let coordinate = firstPlacemark.location?.coordinate

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate!
                    annotation.title = firstPlacemark.name
                    
                    self.location = firstPlacemark.name!
                    self.lat = firstPlacemark.location!.coordinate.latitude as Double
                    self.long = firstPlacemark.location!.coordinate.longitude as Double
                    
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotations([annotation])
                    self.mapView.setCenterCoordinate(coordinate!, animated: true)
                    self.mapView.region = self.mapView.regionThatFits(MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(CLLocationDegrees(5), CLLocationDegrees(5))))
                    
                    self.mapView.selectAnnotation(self.mapView.annotations[0], animated: true)
                    
                    let checkOK = UIAlertController(title: "How does this look?", message: "Do you want to submit this as your location?", preferredStyle: UIAlertControllerStyle.ActionSheet)
                    checkOK.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                        checkOK in
                        self.performSegueWithIdentifier("showCreateURL", sender: self)
                    }))
                    checkOK.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(checkOK, animated: true, completion: nil)
                    
                }  else {
                    self.showAlertWithText("Location Error", message: "Could not resolve \"" + self.locationTextField.text! + "\" to a location.")
                }
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        searchButtonPressed(UIButton())
        return true
    }
    

    func showAlertWithText (header : String = "Warning", message : String) {
            let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        self.mapView.alpha = 1.0
        self.activityIndicator.stopAnimating()
    }
    
    
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        self.mapView.alpha = 0.4
        self.activityIndicator.startAnimating()
    }

        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if DataModel.sharedInstance().shouldReload {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCreateURL" {
            let vc = segue.destinationViewController as! CreateURLViewController
            vc.passedLocation = location
            vc.passedLatitude = lat
            vc.passedLongitude = long
        }
    }
    
}