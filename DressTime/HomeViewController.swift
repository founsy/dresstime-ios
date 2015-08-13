//
//  ViewController.swift
//  Today
//
//  Created by yof on 08/08/2015.
//  Copyright (c) 2015 dresstime. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController  {
    private var locationManager: CLLocationManager = CLLocationManager()
    private var currentLocation: CLLocation!
    private var outfitDataSource: OutfitCollectionViewController!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var isHide = false
    private var filterFrame: CGRect!
    
    private var datePickerView: AKPickerView?
    private var cityPickerView: AKPickerView?
    private var stylePickerView: AKPickerView?
    
    private var styles = [ "WORK - Business style", "BE CHIC - Casual style", "RELAX - Sportswear style", "PARTY - Fashion style" ]
    private let city = ["Paris", "Maisons-Laffitte"]
    private let date = ["Today", "Tomorrow"]
    private let styleData = ["business", "casual", "sportwear", "fashion"]
    
    private var currentStyle = 0
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var outfitCollectionView: UICollectionView!
    @IBOutlet weak var containerOutfit: UIVisualEffectView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet var mainView: UIView!
    
    
    @IBOutlet weak var dateListContainer: UIView!
    @IBOutlet weak var cityListContainer: UIView!
    @IBOutlet weak var styleListContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        
        // TODO: Cannot find how to make the background invisible !!!!
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        bar.tintColor = UIColor.whiteColor()
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.outfitDataSource = OutfitCollectionViewController(outfits: [[String:AnyObject]](), collectionView: outfitCollectionView)
        self.outfitCollectionView.dataSource = self.outfitDataSource
        self.outfitCollectionView.delegate = self.outfitDataSource
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.panGestureRecognizer.delegate = self
        self.containerOutfit.addGestureRecognizer(self.panGestureRecognizer)
        self.filterFrame = self.filterView.frame
        //self.filterView.roundCorners(UIRectCorner.TopLeft | UIRectCorner.TopRight, radius: 5.0)
        
        createPickerView(&self.datePickerView, subView: self.dateListContainer)
        createPickerView(&self.cityPickerView, subView: self.cityListContainer)
        createPickerView(&self.stylePickerView, subView:self.styleListContainer)
        
        self.filterView.layer.shadowColor = UIColor.blackColor().CGColor
        self.filterView.layer.shadowOpacity = 0.8
        self.filterView.layer.shadowRadius = 3.0
        self.filterView.layer.shadowOffset = CGSizeMake(2.0, 2.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.filterView.frame.origin.y = self.mainView.frame.height - 40.0
        hideFilterView()
    }
    
    private func createPickerView(inout picker: AKPickerView?, subView: UIView){
        picker = AKPickerView(frame: subView.bounds)
        picker!.delegate = self;
        picker!.dataSource = self;
        picker!.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        subView.addSubview(picker!)
        
        picker!.font = UIFont(name: "HelveticaNeue-Light", size: 20.0)! //[UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        picker!.highlightedFont =  UIFont(name: "HelveticaNeue", size:20)!
        picker!.interitemSpacing = 20.0
        picker!.textColor = UIColor.whiteColor()
        picker!.highlightedTextColor = UIColor.whiteColor()
        //self.pickerView.fisheyeFactor = 0.001
        picker!.pickerViewStyle = AKPickerViewStyle.Wheel
        picker!.maskDisabled = false
        
    }

    @IBAction func onGetDressedTouch(sender: AnyObject) {
        let titleData = self.styleData[self.currentStyle]
        DressTimeService.getTodayOutfits(SharedData.sharedInstance.currentUserId!, style: titleData, todayCompleted: { (succeeded: Bool, msg: [[String: AnyObject]]) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.outfitDataSource.collection = msg
                self.outfitCollectionView.reloadData()
                self.hideFilterView()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func exitView (sender: UIStoryboardSegue) {
        // Use to exit a view
    }
    
    @IBAction func onMoreFiltersTouch(sender: AnyObject) {
        if (!self.isHide){
            hideFilterView()
        } else{
            showFilterView()
        }
    }

}

extension HomeViewController: CLLocationManagerDelegate {
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
            self.iconLabel.text = self.getValueWeatherCode(code)
            self.temperatureLabel.text = "\(low)° - \(high)°"
            self.cityLabel.text = city
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

extension HomeViewController: FiltersViewControllerDelegate {
    func outfitsResults(outfits: [[String: AnyObject]]) {
        self.outfitDataSource.collection = outfits
        self.outfitCollectionView.reloadData()
    }
}

extension HomeViewController: UIGestureRecognizerDelegate {
    func handlePan(recognizer: UIPanGestureRecognizer){
        NSLog("handlepan")
    }
    
    func showFilterView(){
        self.isHide = false
        self.mainView.layoutIfNeeded() //// Ensures that all pending layout operations have been complete
        UIView.beginAnimations("Show", context: nil)
        UIView.setAnimationDuration(0.3)
        self.filterView.frame.origin.y = self.filterFrame.origin.y
        UIView.commitAnimations()
    }
    
    func hideFilterView(){
        if (!self.isHide){
            self.mainView.layoutIfNeeded() //// Ensures that all pending layout operations have been complete
            self.isHide = true
            UIView.beginAnimations("Hide", context: nil)
            UIView.setAnimationDuration(0.3)
            self.filterView.frame.origin.y = self.mainView.frame.height - 40.0
            UIView.commitAnimations()
        }
    }
}

extension HomeViewController: AKPickerViewDelegate, AKPickerViewDataSource {
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        if (pickerView === self.datePickerView) {
            return self.date.count
        } else if (pickerView === self.cityPickerView) {
            return self.city.count
        } else if (pickerView === self.stylePickerView) {
            return self.styles.count
        }
        return 0
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        if (pickerView === self.datePickerView) {
            return self.date[item]
        } else if (pickerView === self.cityPickerView) {
            return self.city[item]
        } else if (pickerView === self.stylePickerView) {
            return self.styles[item]
        }
        return ""
    }
    
     func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
         if (pickerView === self.stylePickerView) {
            self.currentStyle = item
        }
        
    }
}

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}
