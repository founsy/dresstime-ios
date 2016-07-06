//
//  NewHomeViewController.swift
//  DressTime
//
//  Created by Fab on 15/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Mixpanel


class HomeViewController: DTViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var bubbleImageView: UIImageView!
    
    @IBOutlet weak var weatherContainer: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var commentWeather: UILabel!
    
    var outfitsCell: HomeOutfitsListCell?
    var emptyAnimationCell: HomeEmptyAnimationCell?
    private var headerView: UIView!
    private var kTableHeaderHeight:CGFloat = 184.0
    
    private var currentStyleSelected: String?
    private var outfitSelected: Outfit?
    private var numberOfOutfits: Int = 0
    private var numberOfClothes: Int = 0
    private var arrowImageView: UIImageView?
    private var isEnoughClothes = true
    
    private var typeClothe:Int = -1
    private var currentWeather: Weather?
    private var needToReload = false
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation!
    private var locationFixAchieved : Bool = false
    private var outfitList = [Outfit]()
    private var brandClothesList = [ClotheModel]()
    
    private var loadingView: LaunchingView?
    
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "Home"
        
        addLoadingView()
        configNavBar()
        weatherContainer.roundCorners(.AllCorners, radius: 22.5)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        headerView = self.tableView.tableHeaderView
        self.tableView.tableHeaderView = nil
        if (self.isEnoughClothe()){
            self.tableView.addSubview(headerView)
            self.tableView.contentInset = UIEdgeInsets(top: (kTableHeaderHeight), left: 0, bottom: 0, right: 0)
            self.tableView.contentOffset = CGPoint(x: 0, y: (-kTableHeaderHeight))
        } else {
            self.tableView.contentInset = UIEdgeInsets(top: (64), left: 0, bottom: 0, right: 0)
            self.tableView.contentOffset = CGPoint(x: 0, y: (-64))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = false // for status bar hide
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.identify(mixpanel.distinctId)
        
        self.numberOfClothes = ClothesDAL().numberOfClothes()
        let lastStatus = self.isEnoughClothes
        self.isEnoughClothes = self.isEnoughClothe()
        mixpanel.people.set(["Clothes Number" : self.numberOfClothes])
            
        if (self.isEnoughClothes){
            //Meaning not enough clothes to Enough
            if (lastStatus != self.isEnoughClothes){
                //Need to add Shopping controller
                if (self.tabBarController!.viewControllers?.count == 2) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let vcCalendar = storyboard.instantiateViewControllerWithIdentifier("CalendarNavigationViewController") as! DTNavigationController
                    self.tabBarController!.viewControllers?.insert(vcCalendar, atIndex: 1)
                    
                    let vcShopping = storyboard.instantiateViewControllerWithIdentifier("ShoppingNavigationViewController") as! DTNavigationController
                    self.tabBarController!.viewControllers?.insert(vcShopping, atIndex: 3)
                    
                }
                //Remove Arrow image view
                for item in self.view.subviews {
                    if let imageview = item as? UIImageView {
                        if (imageview != self.bgView){
                            imageview.removeFromSuperview()
                        }
                    }
                }
                self.headerView.hidden = false
                self.tableView.addSubview(headerView)
                self.tableView.contentInset = UIEdgeInsets(top: (kTableHeaderHeight), left: 0, bottom: 0, right: 0)
                self.tableView.contentOffset = CGPoint(x: 0, y: (-kTableHeaderHeight))
                
                //Reload TableView with good cell
                self.tableView.reloadData()
                
            }
            if (!isLoaded && self.currentLocation != nil){
                //Call web service to get Outfits of the Day
                self.loadOutfits()
                //Reload TableView with good cell
                self.tableView.reloadData()
            }
            
        } else {
            self.tableView.reloadData()
            if (self.tabBarController!.viewControllers?.count > 3) {
                self.tabBarController!.viewControllers?.removeAtIndex(3)
                self.tabBarController!.viewControllers?.removeAtIndex(1)
            }
            self.bgView.image = UIImage(named: "backgroundEmpty")
            self.headerView.hidden = true
            self.tableView.contentInset = UIEdgeInsets(top: (64), left: 0, bottom: 0, right: 0)
            self.tableView.contentOffset = CGPoint(x: 0, y: (-64))
            ActivityLoader.shared.hideProgressView()
        }
        
    }
    
    var mask: CAShapeLayer?
    
    private func addLoadingView(){
       let currentWindow = UIApplication.sharedApplication().keyWindow!
       
        loadingView = NSBundle.mainBundle().loadNibNamed("LaunchingView", owner: self, options: nil)[0] as! LaunchingView
        loadingView!.frame = self.view.frame
        loadingView!.tag = 1000
        currentWindow.addSubview(loadingView!)
    }
    
    func animateMask() {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 1
        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        let initalBounds = NSValue(CGRect: mask!.bounds)
        let secondBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 90, height: 90))
        let finalBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 1500, height: 1500))
        keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.3, 1]
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        self.mask!.addAnimation(keyFrameAnimation, forKey: "bounds")
    }
    
    private func updateHeaderView(){
        
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: UIScreen.mainScreen().bounds.width, height: kTableHeaderHeight)
        if  tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.needToReload){
            self.loadOutfits()
            self.needToReload = false
        }
        if (!self.isEnoughClothes){
            if let cell = emptyAnimationCell {
                cell.createArrowImageView()
                cell.imageViewAnimation.startAnimating()
            }
        } else {
            if let imageView = self.arrowImageView {
                imageView.removeFromSuperview()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showOutfit"){
            let targetVC = segue.destinationViewController as! OutfitViewController
            targetVC.outfitObject = self.outfitSelected
            targetVC.currentOutfits = self.outfitSelected!.clothes
            targetVC.delegate = self
        } else if (segue.identifier == "AddClothe"){
            if (typeClothe >= 0) {
                let navController = segue.destinationViewController as! UINavigationController
                let targetVC = navController.topViewController as! TypeViewController
                targetVC.openItem(typeClothe)
            }
        }
    }
    
    func addButtonPressed(){
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
    
    func profilButtonPressed(){
        self.performSegueWithIdentifier("showProfil", sender: self)
    }
    
    private func addAddButtonToNavBar(){
        let regularButton = UIButton(frame: CGRectMake(0, 0, 35.0, 35.0))
        let historyButtonImage = UIImage(named: "AddIcon")
        regularButton.setBackgroundImage(historyButtonImage, forState: UIControlState.Normal)
        
        regularButton.setTitle("", forState: UIControlState.Normal)
        regularButton.addTarget(self, action: #selector(HomeViewController.addButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        let navBarButtonItem = UIBarButtonItem(customView: regularButton)
        self.navigationItem.rightBarButtonItem = navBarButtonItem
    }
    
    private func configNavBar(){
        addAddButtonToNavBar()
    }
    
    private func setTitleNavBar(city: String?){
        let myView = NSBundle.mainBundle().loadNibNamed("TitleNavBar", owner: self, options: nil)[0] as! TitleNavBar
        myView.frame = CGRectMake(0, 0, 300, 30)
        myView.cityLabel.text = city
        self.navigationItem.titleView = myView;
    }
    
    private func isEnoughClothe() -> Bool {
        let type = SharedData.sharedInstance.getType(SharedData.sharedInstance.sexe!)
        let clotheDAL = ClothesDAL()
        if (ClothesDAL().numberOfClothes() > 10){
            return true;
        }
        
        var result = true
        for i in 0 ..< type.count {
            result = result && (clotheDAL.fetch(type: type[i].lowercaseString).count >= 3)
        }
        return result
    }
    
    private func loadOutfits(){
        DressTimeService().GetOutfitsToday(self.currentLocation) { (isSuccess, object) -> Void in
            if (isSuccess){
                self.isLoaded = true
                
                self.currentWeather = Weather(json: object["weather"]["current"])
                let sentence = object["weather"]["comment"].stringValue
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.commentWeather.text = sentence
                    self.iconLabel.text = self.currentWeather!.icon != nil ? self.currentWeather!.icon! : ""
                    let temperature:Int = self.currentWeather!.temp != nil ? self.currentWeather!.temp! : 0
                    self.temperatureLabel.text = "\(temperature)°"
                    self.setTitleNavBar(self.currentWeather?.city)
                    if (self.isEnoughClothe()) {
                        if let code = self.currentWeather?.code {
                            self.bgView.image = UIImage(named: WeatherHelper.changeBackgroundDependingWeatherCondition(code))
                        }
                    }
                })
                
                if let outfits = object["outfits"].array {
                    self.outfitList = [Outfit]()
                    //Load the collection of Outfits
                    if let outfitsCell = self.outfitsCell {
                        for outfit in outfits {
                            let outfitItem = Outfit(json: outfit)
                            outfitItem.orderOutfit()
                            self.outfitList.append(outfitItem)
                        }
                        self.outfitList = self.outfitList.sort({ (outfit1, outfit2) -> Bool in
                            return outfit1.isPutOn && outfit2.isPutOn
                        })
                        
                        self.outfitsCell!.dataSource = self
                        outfitsCell.outfitCollectionView.reloadData()
                        
                    }
                    self.loadingView!.animateMask()
                }
            } else {
                //TO DO - ADD Error Messages
                self.isLoaded = false
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Error.GetOutfit, object: nil)
                dispatch_async(dispatch_get_main_queue(), {
                    self.loadingView!.animateMask()
                })
            }
        }
    }
}

extension HomeViewController: OutfitViewControllerDelegate {
    func outfitViewControllerDelegate(outfitViewController: OutfitViewController, didModifyOutfit outfit: Outfit) {
        self.needToReload = true
        if let cell = self.outfitsCell {
            cell.outfitCollectionView.reloadData()
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    /***/
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false){
            locationFixAchieved = true
            
            self.currentLocation = locations[locations.count-1]
            locationManager.stopUpdatingLocation()
            loadOutfits()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        switch(CLLocationManager.authorizationStatus()) {
        case .NotDetermined, .Restricted, .Denied:
            
            let alert = UIAlertController(title: NSLocalizedString("homeLocErrTitle", comment: ""), message: NSLocalizedString("homeLocErrMessage", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("homeLocErrButton", comment: ""), style: .Default) { _ in })
            dispatch_async(dispatch_get_main_queue(), {
                self.loadingView!.animateMask()
                self.presentViewController(alert, animated: true, completion: nil)
            })
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            print("Access")
        }
    }
}

extension HomeViewController: HomeOutfitsListCellDelegate, HomeOutfitsListCellDataSource {
    
    /* Data Source */
    func numberOfItemsInHomeOutfitsListCell(homeOutfitsListCell: HomeOutfitsListCell) -> Int {
        return self.outfitList.count
    }
    
    func homeOutfitsListCell(homeOutfitsListCell: HomeOutfitsListCell, outfitForItem item: Int) -> Outfit {
        return self.outfitList[item]
    }
    
    /* Delegate */
    func homeOutfitsListCell(homeOutfitsListCell: HomeOutfitsListCell, loadedOutfits outfitsCount: Int){
        self.numberOfOutfits = outfitsCount
        if (self.numberOfOutfits > 0){
            
        }
    }
    
    
    func homeOutfitsListCell(homeOutfitsListCell: HomeOutfitsListCell, didSelectItem item: Int) {
        self.outfitSelected = self.outfitList[item]
        self.performSegueWithIdentifier("showOutfit", sender: self)
    }
    
    
    func homeOutfitsListCell(homeOutfitsListCell: HomeOutfitsListCell, openCaptureType type: String) {
        if let intType = Int(type) {
            self.typeClothe = intType
        }
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
}

extension HomeViewController: HomeEmptyStepCellDelegate {
    func homeEmptyStepCell(homeEmptyStepCell: HomeEmptyStepCell, didSelectItem item: String) {
        switch(item.lowercaseString){
        case "maille":
            self.typeClothe = 0
            break;
        case "top":
            self.typeClothe = 1
            break;
        case "pants":
            self.typeClothe = 2
            break;
        case "dress":
            self.typeClothe = 3
            break;
        default:
            self.typeClothe = 0
            break;
        }
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!self.isEnoughClothes){
            return 2
        } else {
            return 1
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if (indexPath.row == 0) {
            if (!self.isEnoughClothes){
                let cell = self.tableView.dequeueReusableCellWithIdentifier("emptyStepCell") as? HomeEmptyStepCell
                cell?.delegate = self
                return cell!
            } else {
                self.outfitsCell = self.tableView.dequeueReusableCellWithIdentifier("myOutfitsCell") as? HomeOutfitsListCell
                self.outfitsCell!.delegate = self
                return self.outfitsCell!
            }
        } else if (indexPath.row == 1){
            if (!self.isEnoughClothes){
                self.emptyAnimationCell = self.tableView.dequeueReusableCellWithIdentifier("emptyAnimationCell") as? HomeEmptyAnimationCell
                self.emptyAnimationCell!.controller = self
                return self.emptyAnimationCell!
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0){
            if (!self.isEnoughClothes){
                return 186.0
            } else {
                return 400.0
            }
        } else if (indexPath.row == 1){
            return 400.0
        } else if (indexPath.row == 2){
            return 300.0
        } else {
            return 0.0
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.isEnoughClothes){
            updateHeaderView()
            if (tableView.contentOffset.y > -140){
                navigationController?.navigationBar.alpha = (CGFloat(abs(tableView.contentOffset.y))/140.0-0.5) > 0.3 ? (CGFloat(abs(tableView.contentOffset.y))/140.0-0.5) : 0
            } else {
                navigationController?.navigationBar.alpha = 1.0
            }
        }
    }
    
}