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
    class func GET(url: NSURL) -> SuccessHandler
    {
        let service = JSONService("GET", url)
        service.successHandler = SuccessHandler(service: service)
        return service.successHandler!
    }
    
    class func get(url: String, getCompleted:(succeeded: Bool, msg: [String: AnyObject]) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
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
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token: String = params["access_token"] as? String {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
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
    
    private init(_ name: String, _ url: NSURL)
    {
        self.name = name
        self.url  = url
    }
    
    class SuccessHandler
    {
        func success(
            closure: (json: AnyObject) -> (), // Array or dictionary
            queue:   NSOperationQueue? = nil ) // Background queue by default
            -> ErrorHandler
        {
            self.closure = closure
            self.queue = queue
            service.errorHandler = ErrorHandler(service: service)
            return service.errorHandler!
        }
        
        private init(service: JSONService)
        {
            self.service = service
            closure = { (_) in return }
        }
        
        private var
        closure: (json: AnyObject) -> (),
        queue:   NSOperationQueue?,
        service: JSONService
    }
    
    class ErrorHandler
    {
        func failure(
            closure: (statusCode: Int, error: NSError?) -> (),
            queue:   NSOperationQueue? ) // Background queue by default
        {
            self.closure = closure
            self.queue = queue
            service.execute()
        }
        
        private init(service: JSONService)
        {
            self.service = service
            closure = { (_,_) in return }
        }
        
        private var
        closure: (statusCode: Int, error: NSError?) -> (),
        queue:   NSOperationQueue?,
        service: JSONService
    }
    
    private func execute()
    {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = name
        NSURLSession.sharedSession().dataTaskWithRequest(request)
            {
                [weak self]
                data, response, error in
                
                // Reference self strongly via `this`
                if let this = self
                {
                    var statusCode = 0
                    if let httpResponse = response as? NSHTTPURLResponse
                    {
                        statusCode = httpResponse.statusCode
                    }
                    
                    var json: AnyObject?, jsonError: NSError?
                    switch JSONObjectWithData(data)
                    {
                    case .Success(let res): json = res
                    case .Failure(let err): jsonError = err
                    }
                    this.handleResult(json, error ?? jsonError, statusCode)
                }
            }.resume()
    }
    
    private func handleResult(json: AnyObject?, _ error: NSError?, _ statusCode: Int)
    {
        if json != nil
        {
            let handler  = successHandler!
            let success  = { handler.closure(json: json!) }
            if let queue = handler.queue { queue.addOperationWithBlock(success) }
            else                         { success() }
        }
        else
        {
            let handler  = errorHandler!
            let failure  = { handler.closure(statusCode: statusCode, error: error) }
            if let queue = handler.queue { queue.addOperationWithBlock(failure) }
            else                         { failure() }
        }
        
        // Break the retain cycles keeping this object graph alive.
        errorHandler = nil
        successHandler = nil
    }
    
    private var
    errorHandler:   ErrorHandler?,
    successHandler: SuccessHandler?
    
    private let
    name: String,
    url:  NSURL
}