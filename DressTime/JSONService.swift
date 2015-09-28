//
//  WebServiceCall.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation

/** A simple HTTP client for fetching JSON data. */
class JSONService
{
    /** Prepares a GET request for the specified URL. */
    class func get(url: String, params : [String: AnyObject]?, getCompleted:(succeeded: Bool, msg: [String: AnyObject]) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let dict = params {
            if let token: String = dict["access_token"] as? String {
                request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            }
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let dataCheck = data {
                let strData = NSString(data: dataCheck, encoding: NSUTF8StringEncoding)
                print(strData)
                var json: [String: AnyObject]?
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? [String: AnyObject]
                    getCompleted(succeeded: true, msg: json!)
                } catch let error as NSError {
                    print(error)
                    getCompleted(succeeded: false, msg: ["error":"Error"])
                }
            } else {
                 getCompleted(succeeded: false, msg: ["error":"Error"])
            }
        })
        
        task.resume()
    
    }
    
    class func post(params : [String: AnyObject], url : String, postCompleted : (succeeded: Bool, msg: [String: AnyObject]) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token: String = params["access_token"] as? String {
            request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
        
        let dict = NSMutableDictionary(dictionary: params)
        dict.removeObjectForKey("access_token")
        
         do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions())
         } catch let error as NSError {
            print(error)
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let dataSend = data {
                let strData = NSString(data: dataSend, encoding: NSUTF8StringEncoding)
                print(strData)
                var json : [String: AnyObject]?
                do {
                  json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? [String: AnyObject]
                } catch let error as NSError {
                    print(error)
                    postCompleted(succeeded: false, msg: ["error":"Error"])
                }

                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    postCompleted(succeeded: true, msg: parseJSON)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                    
                }
            } else {
                postCompleted(succeeded: false, msg: ["error":"Error"])
            }
        })
        
        task.resume()
    }
    
    
    class func post(params : [String: AnyObject], url : String, postCompleted : (succeeded: Bool, msg: [[String: AnyObject]]) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token: String = params["access_token"] as? String {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let dict = NSMutableDictionary(dictionary: params)
        dict.removeObjectForKey("access_token")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions())
        } catch let error as NSError {
            print(error)
        }
        
        print(request.allHTTPHeaderFields)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print(response)
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(strData)

            var json : [[String: AnyObject]]?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? [[String: AnyObject]]
            } catch let error as NSError {
                print(error)
                  postCompleted(succeeded: false, msg: [["error":"Error"]])
            }

                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    postCompleted(succeeded: true, msg: parseJSON)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: [["error":"Error"]])
                }
        })
        
        task.resume()
    }
    
    
    class func delete(url: String, params : [String: AnyObject]?, deleteCompleted:(succeeded: Bool, msg: [String: AnyObject]) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let dict = params {
            if let token: String = dict["access_token"] as? String {
                request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            }
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(strData)
            var json : [String: AnyObject]?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? [String: AnyObject]
            } catch let error as NSError {
                print(error)
                 deleteCompleted(succeeded: false, msg: ["error":"Error"])
            }
           if let parseJSON = json {
                    deleteCompleted(succeeded: true, msg: parseJSON)
            } else {
                deleteCompleted(succeeded: false, msg: ["error":"Error"])
            }

        })
        
        task.resume()
        
    }
}