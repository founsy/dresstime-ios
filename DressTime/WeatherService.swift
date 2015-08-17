//
//  WeatherService.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import CoreLocation

class WeatherService {

    class func getWeather(position: CLLocation, weatherCompleted : (succeeded: Bool, msg: [String: AnyObject]) -> ()){
        let profilDal = ProfilsDAL()
        var unit = "c"
        if let userId = SharedData.sharedInstance.currentUserId {
            if let user = profilDal.fetch(userId) {
                unit = user.temp_unit.lowercaseString
            }
            
            var query = "select * from weather.forecast where woeid in (select woeid from geo.placefinder where text=\"\(position.coordinate.latitude),\(position.coordinate.longitude)\" and gflags=\"R\") and u=\"\(unit)\""
            var q = "https://query.yahooapis.com/v1/public/yql?q=\(query)&format=json";
            
            var escapedQ = q.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
            JSONService.get(escapedQ, params: nil, getCompleted: { (succeeded: Bool, result: [String: AnyObject]) -> () in
                weatherCompleted(succeeded: succeeded, msg: result)
            })
        }
        
    }
    
    private func onFailure(statusCode: Int, error: NSError?)
    {
        println("HTTP status code \(statusCode) Error: \(error)")
    }
    
}