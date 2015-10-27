//
//  Client.swift
//  OnTheMap
//
//  Created by Brian on 10/9/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import Foundation

class Client : NSObject {
    
    // MARK: Properties
    
    var session: NSURLSession
    
    // MARK: Initializers
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    
    func performLogin(username: String, password: String, completionHandler: (key: String?, id: String?, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil || data == nil {
                completionHandler(key: nil, id: nil, errorString: "The login server could not be reached")
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            let parsed = (try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)) as! [String: AnyObject]
            
            let keys = Array(parsed.keys)
            
            if keys[0] != "session" {
                completionHandler(key: nil, id: nil, errorString: "Either the email address or password is incorrect.")
                return
            } else {
                let account = parsed["account"] as! Dictionary<String, AnyObject>
                let sessionID = parsed["session"] as! Dictionary<String, AnyObject>
                completionHandler(key: (account["key"] as! String), id: (sessionID["id"] as! String), errorString: nil)
            }
        }
        
        task.resume()
    }
    
    
    func getUserData(DataModelKey: String, completionHandler: (firstName: String?, lastName: String?, errorString: String?) -> Void) {

        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(DataModelKey)")!)
        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil || data == nil {
                completionHandler(firstName: nil, lastName: nil, errorString: "Could not get User Data from server.")
            } else {
                
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))

                let parsedData: [String: AnyObject] = (try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)) as! [String: AnyObject]

                let firstName = (parsedData["user"] as! [String: AnyObject])["first_name"] as! String

                let lastName = (parsedData["user"] as! [String: AnyObject])["last_name"] as! String
                
                completionHandler(firstName: firstName, lastName: lastName, errorString: nil)
            }
        }
        
        task.resume()
        
    }
    
    
    func getAllStudents(uniqueKey: String, completionHandler: (mediaURL: String?, longitude: Double?, latitude: Double?, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil || data == nil {
                completionHandler(mediaURL: nil, longitude: nil, latitude: nil, errorString: "Could not reach the student information server.")
                return
            } else {
                
                var parsedJSON: Dictionary<String, AnyObject>
                do {
                    parsedJSON = (try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! Dictionary<String, AnyObject>)
                } catch {
                    completionHandler(mediaURL: nil, longitude: nil, latitude: nil, errorString: "Could not reach the student information server.")
                    return
                }
                if parsedJSON["results"] == nil {
                    completionHandler(mediaURL: nil, longitude: nil, latitude: nil, errorString: "Could not reach the student information server.")
                    return
                }
                
                let personArray: [Dictionary<String, AnyObject>] = parsedJSON["results"] as! [Dictionary<String, AnyObject>]
                var userMediaURL: String? = nil
                var userLongitude: Double? = nil
                var userLatitude: Double? = nil
                DataModel.sharedInstance().people = []
                for peep in personArray {
                    let thisPerson: StudentInformation = StudentInformation(personDict: peep)
                    if thisPerson.uniqueKey == uniqueKey {
                        userMediaURL = thisPerson.mediaURL
                        userLongitude = thisPerson.longitude
                        userLatitude = thisPerson.latitude
                    }
                    DataModel.sharedInstance().people.append(thisPerson)
                }
                
                completionHandler(mediaURL: userMediaURL, longitude: userLongitude, latitude: userLatitude, errorString: nil)
                
            }
        }
        
        task.resume()
    }
    
    
    func performLogout(completionHandler: (errorString: String?) -> Void) {
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
            
            if error != nil || data == nil {
                completionHandler(errorString: "There was an error logging out of the server.")
                return
            }
            
            completionHandler(errorString: nil)
            return
        }
        
        task.resume()
    }
    
    
    func postStudentInfo(person: StudentInformation, completionHandler: (errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        
        request.HTTPMethod = "POST"
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        
        request.HTTPBody = "{\"uniqueKey\": \"\(person.uniqueKey)\", \"firstName\": \"\(person.firstName)\", \"lastName\": \"\(person.lastName)\",\"mapString\": \"\(person.mapString)\", \"mediaURL\": \"\(person.mediaURL)\",\"latitude\": \(person.latitude), \"longitude\": \(person.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil || data == nil {
                completionHandler(errorString: "There was an error posting your data to the server.")
                return
            }
            if NSString(data: data!, encoding: NSUTF8StringEncoding) != "" {
                completionHandler(errorString: nil)
                return
            } else {
                completionHandler(errorString: "There was an error posting your data to the server.")
                return
            }
            
        }
        
        task.resume()
    }
    
    func updateStudentInfo(id: String, person: StudentInformation, completionHandler: (data: NSData?, errorString: String?) -> Void) {
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(id)"
        
        let url = NSURL(string: urlString)
        
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "PUT"
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(person.uniqueKey)\", \"firstName\": \"\(person.firstName)\", \"lastName\": \"\(person.lastName)\",\"mapString\": \"\(person.mapString)\", \"mediaURL\": \"\(person.mediaURL)\",\"latitude\": \(person.latitude), \"longitude\": \(person.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
        
            if error != nil || data == nil {
                completionHandler(data: nil, errorString: "There was an error posting your update to the server.")
                return
            }
            if NSString(data: data!, encoding: NSUTF8StringEncoding) != "" {
                completionHandler(data: data!, errorString: nil)
                return
            } else {
                completionHandler(data: nil, errorString: "There was an error posting your update to the server.")
                return
            }
            
        }
        task.resume()
    }
    
    func queryStudentLocation(completionHandler: (objectID: String?, errorString: String?) -> Void) {
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(DataModel.sharedInstance().key)%22%7D"
        
        let url = NSURL(string: urlString)
        
        let request = NSMutableURLRequest(URL: url!)
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                if data == nil || error != nil {
                    completionHandler(objectID: nil, errorString: "There was an error posting your update to the server.")
                    return
                }
                
                let parseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                if parseString != "" {
                    let firstPart = parseString?.componentsSeparatedByString("\"objectId\":\"")[1]
                    
                    let objectID = firstPart?.componentsSeparatedByString("\"")[0]
                    
                    completionHandler(objectID: objectID, errorString: nil)
                    return
                } else {
                    completionHandler(objectID: nil, errorString: "There was an error posting your update to the server.")
                    return
                }
            }
        }
        
        task.resume()
    }
    

    class func sharedInstance() -> Client {
        
        struct Singleton {
            static var sharedInstance = Client()
        }
        
        return Singleton.sharedInstance
    }

}