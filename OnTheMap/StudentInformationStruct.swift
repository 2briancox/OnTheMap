//
//  PersonStruct.swift
//  OnTheMap
//
//  Created by Brian on 10/9/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import Foundation

struct StudentInformation {
    var firstName: String = ""
    var lastName: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var mediaURL: String = ""
    var uniqueKey: String = ""
    var mapString: String = ""
    
    init (personDict: Dictionary<String, AnyObject>) {
        firstName = personDict["firstName"] as! String
        lastName = personDict["lastName"] as! String
        mediaURL = personDict["mediaURL"] as! String
        uniqueKey = personDict["uniqueKey"] as! String
        latitude = personDict["latitude"] as! Double
        longitude = personDict["longitude"] as! Double
        mapString = personDict["mapString"] as! String
    }
    
}
