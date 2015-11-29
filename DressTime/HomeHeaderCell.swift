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
    func weatherFinishing(weather: Weather)
}

class HomeHeaderCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    private var locationManager: CLLocationManager = CLLocationManager()
    private var currentLocation: CLLocation!
    private let cellIdentifier = "WeatherCell"
    private var selectedWeather = 0
    
    private var weatherList = [Weather]()
    
    let cellHeight = 100.0
    
    var delegate: HomeHeaderCellDelegate?
    
    
    override func awakeFromNib() {
        self.collectionView.registerNib(UINib(nibName: "WeatherCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        //self.collectionView.collectionViewLayout = HomeHeaderCellFlowLayout()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

    }
    
}

extension HomeHeaderCell: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.weatherList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! WeatherCell
        if (indexPath.row == self.selectedWeather){
            cell.viewContainer.backgroundColor = UIColor(red: 235.0/255.0, green: 175.0/255.0, blue: 73.0/255.0, alpha: 0.8)
        } else {
            cell.viewContainer.backgroundColor = UIColor(red: 235.0/255.0, green: 175.0/255.0, blue: 73.0/255.0, alpha: 0.2)
        }
        let weather = weatherList[indexPath.row]
        cell.weatherIcon.text = weather.icon!
        cell.timeText.text = NSLocalizedString(weather.time!, comment: "")
        let temperature:Int = weather.temp!
        cell.temperatureText.text = "\(temperature)°"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/3, height: 100);
    }
    
}

extension HomeHeaderCell: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       if (self.selectedWeather != indexPath.row){
            var cell = collectionView.cellForItemAtIndexPath(indexPath) as! WeatherCell
            cell.viewContainer.backgroundColor = UIColor(red: 235.0/255.0, green: 175.0/255.0, blue: 73.0/255.0, alpha: 0.8)
        
            let indexPathSelected = NSIndexPath(forRow: self.selectedWeather, inSection: indexPath.section)
            cell = collectionView.cellForItemAtIndexPath(indexPathSelected) as! WeatherCell
            cell.viewContainer.backgroundColor = UIColor(red: 235.0/255.0, green: 175.0/255.0, blue: 73.0/255.0, alpha: 0.2)
        
            self.selectedWeather = indexPath.row
            if let del = self.delegate {
                //Return current weather
                del.weatherFinishing( self.weatherList[self.selectedWeather])
            }
        }
        
    }

}

class HomeHeaderCellFlowLayout: UICollectionViewFlowLayout {
    override func collectionViewContentSize() -> CGSize {
        return CGSizeMake(75, 75)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElementsInRect(rect)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if let cellAttributes = super.layoutAttributesForItemAtIndexPath(indexPath) {
            // Add inset to the collection view if there are not enough cells to fill the width.
            let cellSpacing:CGFloat = self.minimumLineSpacing;
            let cellWidth:CGFloat =  self.itemSize.width;
            let cellCount:Int = collectionView!.numberOfItemsInSection(1)
            let inset = (collectionView!.bounds.size.width - (CGFloat(cellCount) * (cellWidth + cellSpacing))) * 0.5;
            
            if (indexPath.row > 0){
                // configure CellAttributes
                cellAttributes.frame = CGRectMake(cellAttributes.frame.origin.x + inset, cellAttributes.frame.origin.y, cellAttributes.frame.width, cellAttributes.frame.height)
            }
            return cellAttributes
        }
        return nil
    }
}

extension HomeHeaderCell: CLLocationManagerDelegate {
    /***/
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[locations.count-1]
        locationManager.stopUpdatingLocation()
        
        WeatherService().GetCurrentWeather(self.currentLocation) { (isSuccess, object) -> Void in
            WeatherService().GetForecastWeather(self.currentLocation, completion: { (isSuccess, result) -> Void in
                if (isSuccess) {
                    self.weatherList = WeatherWrapper().wrapListWeather(object, forecast: result)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.collectionView.reloadData()
                    })
                    self.updateWeather(self.weatherList[0].code!, high: String(self.weatherList[0].tempMax!), low: String(self.weatherList[0].tempMin!), city: self.weatherList[0].city!)
                    if let del = self.delegate {
                        //Return current weather
                        del.weatherFinishing(self.weatherList[0])
                    }
                }
            })
        }
    }
    
    func updateWeather(code:Int, high:String, low: String, city: String){
        SharedData.sharedInstance.weatherCode = String(code)
        SharedData.sharedInstance.lowTemp = low
        SharedData.sharedInstance.highTemp = high
        SharedData.sharedInstance.city = city
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}
