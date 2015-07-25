//
//  TodayViewController.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import UIKit
import CoreLocation

class TodayViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var iconWeather: UILabel!
    @IBOutlet weak var highTemp: UILabel!
    @IBOutlet weak var lowTemp: UILabel!
    @IBOutlet weak var cityText: UILabel!
    
    @IBOutlet weak var mailleOutfit: UIImageView!
    @IBOutlet weak var topOutfit: UIImageView!
    @IBOutlet weak var pantsOutfit: UIImageView!
    
    @IBOutlet weak var outfitCollectionView: UICollectionView!
    
    @IBOutlet weak var stylePicker: UIPickerView!
    
    var outfitDataSource: OutfitCollectionViewController!
    
    var styleData = ["business", "casual", "fashion", "sportwear"]
    
    
    override func viewDidLoad() {
         super.viewDidLoad()
    
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
       
        self.outfitDataSource = OutfitCollectionViewController(outfits: [[String:AnyObject]](), collectionView: outfitCollectionView)
        self.outfitCollectionView.dataSource = self.outfitDataSource
        self.outfitCollectionView.delegate = self.outfitDataSource
        
        self.stylePicker.delegate = self
        self.stylePicker.dataSource = self
        //sendClotheData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendClotheData(){
        let dal = ClothesDAL()
        let clothes = dal.fetch()
        for clothe in clothes {
            DressTimeService.saveClothe("myapi", clotheId: clothe.clothe_id, dressingCompleted: { (succeeded: Bool, msg: [[String: AnyObject]]) -> () in
                //println(msg)
            })
        }
    }
    
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
                            }
                        }
                    }

                }
            }
           
        })
    }
    
    func updateWeather(code:Int, high:String, low: String, city: String){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // Show the alert
            self.iconWeather.text = self.getValueWeatherCode(code)
            self.lowTemp.text = low
            self.highTemp.text = high
            self.cityText.text = city
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

extension TodayViewController : UIPickerViewDataSource,UIPickerViewDelegate {

    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.styleData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.styleData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?{
        let titleData = self.styleData[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let titleData = self.styleData[row]
        DressTimeService.getTodayOutfits("myapi", style: titleData, todayCompleted: { (succeeded: Bool, msg: [[String: AnyObject]]) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.outfitDataSource.collection = msg
                self.outfitCollectionView.reloadData()
            })
        })
    }
    
}

