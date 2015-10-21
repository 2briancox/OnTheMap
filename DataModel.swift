//
//  DataModel.swift
//  OnTheMap
//
//  Created by Brian on 10/20/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import Foundation

class DataModel : NSObject {
    
    var people: [StudentInformation] = []
    var key:String = ""
    var id:String = ""
    var userFirstName: String = ""
    var userLastName: String = ""
    var userMediaURL: String = ""
    var userLatitude: Double = 0.0
    var userLongitude: Double = 0.0
    var shouldReload: Bool = false
    
    class func sharedInstance() -> DataModel {
        struct Singleton {
            static var sharedInstance = DataModel()
        }
        return Singleton.sharedInstance
    }
    
}