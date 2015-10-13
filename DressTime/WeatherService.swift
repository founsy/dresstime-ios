//
//  WeatherService.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

class WeatherService {
    let appId = "77775d8069b7d87e421e7c1ec4f84bcc"
    
    func GetWeather(position: CLLocation, completion: (isSuccess: Bool, object: JSON) -> Void) {
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("weather"){
                let str = NSString(data: nsdata, encoding:NSUTF8StringEncoding)
                print(str)
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.getWeather(position, completion: completion)
        }
    
    }
    
    func GetCurrentWeather(position: CLLocation, completion: (isSuccess: Bool, object: JSON) -> Void) {
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("currentWeather"){
                _ = NSString(data: nsdata, encoding:NSUTF8StringEncoding)
                let json = JSON(data: nsdata)
                print(json)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.getCurrentWeather(position, completion: completion)
        }
        
    }
    
    func GetForecastWeather(position: CLLocation, completion: (isSuccess: Bool, object: JSON) -> Void) {
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("weather"){
                let str = NSString(data: nsdata, encoding:NSUTF8StringEncoding)
                print(str)
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.getForecastWeather(position, completion: completion)
        }
        
    }
    
    private func getCurrentWeather(position: CLLocation, completion: (isSuccess: Bool, object: JSON) -> Void){
        if let userId = SharedData.sharedInstance.currentUserId {
            let profilDal = ProfilsDAL()
            var unit = "c"
            if let user = profilDal.fetch(userId) {
                if (user.temp_unit!.lowercaseString == "c"){
                    unit = "metric"
                } else {
                    unit = ""
                }
            }
            
            let query = "http://api.openweathermap.org/data/2.5/weather?lat=\(position.coordinate.latitude)&lon=\(position.coordinate.longitude)&APPID=\(appId)&units=\(unit)"
            
            Alamofire.request(.GET, query).responseJSON { (response) -> Void in
                if response.result.isSuccess {
                    print(response.result.value)
                    let jsonDic = JSON(response.result.value!)
                    completion(isSuccess: true, object: jsonDic)
                } else {
                    completion(isSuccess: false, object: "")
                }
            }
        }

    }
    
    private func getForecastWeather(position: CLLocation, completion: (isSuccess: Bool, object: JSON) -> Void){
        if let userId = SharedData.sharedInstance.currentUserId {
            let profilDal = ProfilsDAL()
            var unit = "c"
            if let user = profilDal.fetch(userId) {
                if (user.temp_unit!.lowercaseString == "c"){
                    unit = "metric"
                } else {
                    unit = ""
                }
            }
            
            let query = "http://api.openweathermap.org/data/2.5/forecast/?lat=\(position.coordinate.latitude)&lon=\(position.coordinate.longitude)&APPID=\(appId)&units=\(unit)"
            
            Alamofire.request(.GET, query).responseJSON { (response) -> Void in
                if response.result.isSuccess {
                    print(response.result.value)
                    let jsonDic = JSON(response.result.value!)
                    completion(isSuccess: true, object: jsonDic)
                } else {
                    completion(isSuccess: false, object: "")
                }
            }
        }

    }
    
    /*************************************/
    /*           PRIVATE FUNCTION        */
    /*************************************/

    private func getWeather(position: CLLocation, completion: (isSuccess: Bool, object: JSON) -> Void) {
        if let userId = SharedData.sharedInstance.currentUserId {
            let profilDal = ProfilsDAL()
            var unit = "c"
            if let user = profilDal.fetch(userId) {
                unit = user.temp_unit!.lowercaseString
            }
            let query = "select * from weather.forecast where woeid in (select woeid from geo.placefinder where text=\"\(position.coordinate.latitude),\(position.coordinate.longitude)\" and gflags=\"R\") and u=\"\(unit)\""
            let q = "https://query.yahooapis.com/v1/public/yql?q=\(query)&format=json";
            
            let escapedQ = q.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
            
            Alamofire.request(.GET, escapedQ).responseJSON { (response) -> Void in
                if response.result.isSuccess {
                    print(response.result.value)
                    let jsonDic = JSON(response.result.value!)
                    completion(isSuccess: true, object: jsonDic)
                } else {
                    completion(isSuccess: false, object: "")
                }
            }
        }
    }
}