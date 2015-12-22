//
//  AuthorizationManager.swift
//  DressTime
//
//  Created by Fab on 20/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import Foundation
import Alamofire

public class AuthorizationManager: Manager {
    
    public typealias NetworkSuccessHandler = (AnyObject?) -> Void
    public typealias NetworkFailureHandler = (NSHTTPURLResponse?, AnyObject?, NSError) -> Void
    
    private typealias CachedTask = (NSHTTPURLResponse?, AnyObject?, NSError?) -> Void
    
    private var cachedTasks = Array<CachedTask>()
    private var isRefreshing = false
    
    public func startRequest(
        method method: Alamofire.Method,
        URLString: URLStringConvertible,
        parameters: [String: AnyObject]?,
        encoding: ParameterEncoding,
        success: NetworkSuccessHandler?,
        failure: NetworkFailureHandler?) -> Request?
    {
        let cachedTask: CachedTask = { [weak self] URLResponse, data, error in
            if let strongSelf = self {
                if let error = error {
                    failure?(URLResponse, data, error)
                } else {
                    strongSelf.startRequest(
                        method: method,
                        URLString: URLString,
                        parameters: parameters,
                        encoding: encoding,
                        success: success,
                        failure: failure
                    )
                }
            }
        }
        
        if self.isRefreshing {
            self.cachedTasks.append(cachedTask)
            return nil
        }
        
        // Append your auth tokens here to your parameters
        
        let request = self.request(method, URLString, parameters: parameters, encoding: encoding)
        
        request.response { [weak self] request, response, data, error in
            if let strongSelf = self {
                if let response = response {
                    if response.statusCode == 401 {
                        strongSelf.cachedTasks.append(cachedTask)
                        strongSelf.refreshTokens()
                        return
                    }
                }
                
                if let error = error {
                    failure?(response, data, error)
                } else {
                    success?(data)
                }
            }
        }
        
        return request
    }
    
    public func startRequest(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil)
        -> Request?
    {
        let cachedTask: CachedTask = { [weak self] URLResponse, data, error in
            if let strongSelf = self {
                if let _ = error {
                    //failure?(URLResponse, data, error)
                } else {
                    strongSelf.startRequest(
                        method,
                        URLString,
                        parameters: parameters,
                        encoding: encoding,
                        headers: headers
                    )
                }
            }
        }
        
        if self.isRefreshing {
            self.cachedTasks.append(cachedTask)
            return nil
        }
        
        // Append your auth tokens here to your parameters
        
        let request = self.request(method, URLString, parameters: parameters, encoding: encoding)
        
        request.response { [weak self] request, response, data, error in
            if let strongSelf = self {
                if let response = response {
                    if response.statusCode == 401 {
                        strongSelf.cachedTasks.append(cachedTask)
                        strongSelf.refreshTokens()
                        return
                    }
                }
                
                /*if let error = error {
                    failure?(response, data, error)
                } else {
                    success?(data)
                } */
            }
        }
        
        return request
    }
    
    func refreshTokens() {
        self.isRefreshing = true
        
        // Make the refresh call and run the following in the success closure to restart the cached tasks
      /*
        let cachedTaskCopy = self.cachedTasks
        self.cachedTasks.removeAll()
        cachedTaskCopy.map { $0(nil, nil, nil) } */
        
        self.isRefreshing = false
    }
}