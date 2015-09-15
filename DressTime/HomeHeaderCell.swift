//
//  HomeHeaderCell.swift
//  DressTime
//
//  Created by Fab on 15/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol HomeHeaderCellDelegate {
    func weatherFinishing()
}
class HomeHeaderCell: UITableViewCell {

    @IBOutlet weak var wheaterIcon: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    
    private var locationManager: CLLocationManager = CLLocationManager()
    private var currentLocation: CLLocation!
    
    let cellHeight = 100.0
    
    var delegate: HomeHeaderCellDelegate?
    
    
    override func awakeFromNib() {
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

    }
    
}

extension HomeHeaderCell: CLLocationManagerDelegate {
    /***/
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.currentLocation = locations[locations.count-1] as! CLLocation
        locationManager.stopUpdatingLocation()
        WeatherService.getWeather(self.currentLocation, weatherCompleted: { (succeeded: Bool, msg: [String: AnyObject]) -> () in
            if let query:AnyObject = msg["query"] {
                if let results:AnyObject = query["results"] {
                    if let channel:AnyObject = results["channel"] {
                        if let item:AnyObject = channel["item"]{
                            if let condition: AnyObject = item["condition"]{
                                let location:AnyObject = channel["location"] as AnyObject!
                                let city = location["city"] as! String
                                let forecast = item["forecast"] as! [AnyObject]
                                let today: AnyObject = forecast[0] as AnyObject
                                self.updateWeather((condition["code"] as! String).toInt()!, high:  today["high"] as! String, low:  today["low"] as! String, city: city)
                                if let del = self.delegate {
                                    del.weatherFinishing()
                                }
                            }
                        }
                    }
                    
                }
            }
            
        })
    }
    
    func updateWeather(code:Int, high:String, low: String, city: String){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            SharedData.sharedInstance.weatherCode = String(code)
            SharedData.sharedInstance.lowTemp = low
            SharedData.sharedInstance.highTemp = high
            SharedData.sharedInstance.city = city
            self.wheaterIcon.text = self.getValueWeatherCode(code)
            self.highTempLabel.text = "\(high)°"
            self.lowTempLabel.text = "\(low)°"
            //TODO
            //self.loadTodayOutfits()
        })
    }
    
    func getValueWeatherCode(code: Int) -> String{
        switch code {
        case 0:
            return ":"
        case 1:
            return "p"
        case 2:
            return "S"
        case 3:
            return "Q"
        case 4:
            return "S"
        case 5:
            return "W"
        case 6:
            return "W"
        case 7:
            return "W"
        case 8:
            return "W"
        case 9:
            return "I"
        case 10:
            return "W"
        case 11:
            return "I"
        case 12:
            return "I"
        case 13:
            return "I"
        case 14:
            return "I"
        case 15:
            return "W"
        case 16:
            return "I"
        case 17:
            return "W"
        case 18:
            return "U"
        case 19:
            return "Z"
        case 20:
            return "Z"
        case 21:
            return "Z"
        case 22:
            return "Z"
        case 23:
            return "Z"
        case 24:
            return "E"
        case 25:
            return "E"
        case 26:
            return "3"
        case 27:
            return "a"
        case 28:
            return "A"
        case 29:
            return "a"
        case 30:
            return "A"
        case 31:
            return "6"
        case 32:
            return "1"
        case 33:
            return "6"
        case 34:
            return "1"
        case 35:
            return "W"
        case 36:
            return "1"
        case 37:
            return "S"
        case 38:
            return "S"
        case 39:
            return "S"
        case 40:
            return "M"
        case 41:
            return "W"
        case 42:
            return "I"
        case 43:
            return "W"
        case 44:
            return "a"
        case 45:
            return "S"
        case 46:
            return "U"
        case 47:
            return "S"
        default:
            return "."
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
}