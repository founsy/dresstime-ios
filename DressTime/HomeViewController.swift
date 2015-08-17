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
    private var swipeGestureRecognizer: UISwipeGestureRecognizer!
    private var isHide = false
    private var filterFrame: CGRect!
    
    private let styleData = ["business", "casual", "sportwear", "fashion"]
    
    private var currentStyle = 0
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var outfitCollectionView: UICollectionView!
    @IBOutlet weak var containerOutfit: UIVisualEffectView!
    //@IBOutlet weak var filterView: UIView!
    @IBOutlet var mainView: UIView!
    
    private var filterView: FilterView!
    
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
        
        var contentViewXib: NSArray = NSBundle.mainBundle().loadNibNamed("FilterView", owner: nil, options: nil)
        self.filterView = contentViewXib[0] as! FilterView
        
        self.filterView.initialize()
        self.filterView.frame = self.containerOutfit.frame
        
        self.swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "hideFilterView")
        self.swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        var upSwipeGesture = UISwipeGestureRecognizer(target:self, action:"showFilterView")
        upSwipeGesture.direction = UISwipeGestureRecognizerDirection.Up
        
        self.filterView.addGestureRecognizer(upSwipeGesture)
        self.filterView.addGestureRecognizer(self.swipeGestureRecognizer)
        self.filterView.delegate = self
        self.view.addSubview(self.filterView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        hideFilterView()
        self.filterView.filterViewContainer.roundCorners(UIRectCorner.TopLeft | UIRectCorner.TopRight, radius: 10.0)
        self.filterView.drawIconViewCircle()
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


    private var gravity: UIGravityBehavior!
    private var animator: UIDynamicAnimator!
    private var collision: UICollisionBehavior!

extension HomeViewController: UIGestureRecognizerDelegate {
    func handlePan(recognizer: UIPanGestureRecognizer){
        NSLog("handlepan")
        if ((recognizer.state == UIGestureRecognizerState.Changed) ||
            (recognizer.state == UIGestureRecognizerState.Ended)){
            var velocity = recognizer.velocityInView(self.mainView)
            // panning down
            if (velocity.y>0){
                self.hideFilterView()
            } // panning up
            else {
                self.showFilterView()
                //self.animationShow()
            }
        }
    }
    
    func animationShow(){
        self.filterView.frame.origin.y = self.containerOutfit.frame.origin.y
        
        animator = UIDynamicAnimator(referenceView: self.view)
        gravity = UIGravityBehavior(items: [self.filterView])
        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior(items: [self.filterView])
        collision.translatesReferenceBoundsIntoBoundary = true
        // collision.addBoundaryWithIdentifier("barrier", fromPoint: CGPointMake(self.view.frame.origin.x, 350), toPoint: CGPointMake(self.view.frame.origin.x + self.view.frame.width, 350))
        animator.addBehavior(collision)
    }
    
    func showFilterView(){
        if (self.isHide){
            self.isHide = false
            self.mainView.layoutIfNeeded() //// Ensures that all pending layout operations have been complete
            
            UIView.animateWithDuration(0.5, delay: 0,
                options: .CurveEaseOut, animations: {
                    self.filterView.frame.origin.y = self.containerOutfit.frame.origin.y
                    self.filterView.showConstrainte(self.containerOutfit)
                    self.filterView.alpha = 1.0
                    self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func hideFilterView(){
        if (!self.isHide){
            self.mainView.layoutIfNeeded() //// Ensures that all pending layout operations have been complete
            self.isHide = true
            UIView.animateWithDuration(0.5, delay: 0,
                options: .CurveEaseOut, animations: {
                    self.filterView.frame.origin.y = self.mainView.frame.height - 40.0
                    self.filterView.hideContrainte(self.containerOutfit)
                    self.filterView.alpha = 0.5
                    self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

extension HomeViewController: FilterViewDelegate {
    func onMoreFilterClick() {
        if (self.isHide){
            //self.showFilterView()
            self.animationShow()
        } else {
            self.hideFilterView()
        }
    }
    
    func onGetDressedClothe(type: Int) {
        let titleData = self.styleData[type]
        DressTimeService.getTodayOutfits(SharedData.sharedInstance.currentUserId!, style: titleData, todayCompleted: { (succeeded: Bool, msg: [[String: AnyObject]]) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.outfitDataSource.collection = msg
                self.outfitCollectionView.reloadData()
                self.hideFilterView()
            })
        })
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
