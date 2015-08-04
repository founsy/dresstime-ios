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
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let dict = params {
            if let token: String = dict["access_token"] as? String {
                request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            }
        }
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(strData)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? [String: AnyObject]
            if(err != nil) {
                getCompleted(succeeded: false, msg: ["error":"Error"])
            } else {
                if let parseJSON = json {
                    getCompleted(succeeded: true, msg: parseJSON)
                } else {
                    getCompleted(succeeded: false, msg: ["error":"Error"])
                }
            }
        })
        
        task.resume()
    
    }
    
    class func post(params : [String: AnyObject], url : String, postCompleted : (succeeded: Bool, msg: [String: AnyObject]) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token: String = params["access_token"] as? String {
            request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
        
        var dict = NSMutableDictionary(dictionary: params)
        dict.removeObjectForKey("access_token")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(dict, options: nil, error: &err)

        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(strData)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? [String: AnyObject]
            
            var msg = "No message"
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: ["error":"Error"])
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    postCompleted(succeeded: true, msg: parseJSON)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: ["error":"Error"])
                }
            }
        })
        
        task.resume()
    }
    
    
    class func post(params : [String: AnyObject], url : String, postCompleted : (succeeded: Bool, msg: [[String: AnyObject]]) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token: String = params["access_token"] as? String {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        var dict = NSMutableDictionary(dictionary: params)
        dict.removeObjectForKey("access_token")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(dict, options: nil, error: &err)

        println(request.allHTTPHeaderFields)
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println(response)
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(strData)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? [[String: AnyObject]]
            
            var msg = "No message"
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: [["error":"Error"]])
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    postCompleted(succeeded: true, msg: parseJSON)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: [["error":"Error"]])
                }
            }
        })
        
        task.resume()
    }
    
    
    class func delete(url: String, params : [String: AnyObject]?, deleteCompleted:(succeeded: Bool, msg: [String: AnyObject]) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let dict = params {
            if let token: String = dict["access_token"] as? String {
                request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            }
        }
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(strData)
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? [String: AnyObject]
            if(err != nil) {
                deleteCompleted(succeeded: false, msg: ["error":"Error"])
            } else {
                if let parseJSON = json {
                    deleteCompleted(succeeded: true, msg: parseJSON)
                } else {
                    deleteCompleted(succeeded: false, msg: ["error":"Error"])
                }
            }
        })
        
        task.resume()
        
    }
}