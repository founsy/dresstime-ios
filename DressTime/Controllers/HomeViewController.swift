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


class HomeViewController: DTViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var bubbleImageView: UIImageView!
    
    var outfitsCell: HomeOutfitsListCell?
    var homeHeaderCell: HomeHeaderCell?
    var brandOutfitsCell: HomeBrandOutfitsListCell?
    var emptyAnimationCell: HomeEmptyAnimationCell?
    
    private var currentStyleSelected: String?
    private var outfitSelected: Outfit?
    private var numberOfOutfits: Int = 0
    private var numberOfClothes: Int = 0
    private var arrowImageView: UIImageView?
    private var isEnoughClothes = true
    
    private var typeClothe:Int = -1
    private var currentWeather: Weather?
    
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation!
    private var locationFixAchieved : Bool = false
    private var weatherList = [Weather]()
    private var outfitList = [Outfit]()
    private var brandClothesList = [ClotheModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "Home"
        
        configNavBar()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        DressTimeService().GetBrandOutfitsToday { (isSuccess, object) -> Void in
            if (isSuccess){
                self.brandClothesList = [ClotheModel]()
                for (var i = 0; i < object.arrayValue.count; i++){
                    self.brandClothesList.append(ClotheModel(json: object[i]))
                }
                if let cell = self.brandOutfitsCell {
                    
                    cell.collectionView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = false // for status bar hide
        self.numberOfClothes = ClothesDAL().numberOfClothes()
        let lastStatus = self.isEnoughClothes
        self.isEnoughClothes = self.isEnoughClothe()
        
        if (self.isEnoughClothes){
            //Meaning not enough clothes to Enough
            if (lastStatus != self.isEnoughClothes){
                //Need to add Shopping controller
                if (self.tabBarController!.viewControllers?.count == 2) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("ShoppingViewController") as! ShoppingViewController
                    self.tabBarController!.viewControllers?.append(vc)
                    //shoppingController.tabBarItem = UITabBarItem(title: "Shopping", image: UIImage(named: "shoppingIcon"), tag: 3)
                }
                //Remove Arrow image view
                for item in self.view.subviews {
                    if let imageview = item as? UIImageView {
                        if (imageview != self.bgView){
                            imageview.removeFromSuperview()
                        }
                    }
                }
                //Reload TableView with good cell
                self.tableView.reloadData()
                //Call web service to get Outfits of the Day
                self.loadOutfits()
            }
        } else {
            self.tableView.reloadData()
            if (self.tabBarController!.viewControllers?.count > 2) {
                self.tabBarController!.viewControllers?.removeAtIndex(2)
            }
            self.bgView.image = UIImage(named: "backgroundEmpty")
            ActivityLoader.shared.hideProgressView()
        }
    }   
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
            targetVC.currentOutfits = self.outfitSelected!.outfit
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
        regularButton.addTarget(self, action: "addButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        let navBarButtonItem = UIBarButtonItem(customView: regularButton)
        self.navigationItem.rightBarButtonItem = navBarButtonItem
    }
    
    private func configNavBar(){
        addAddButtonToNavBar()
       
    }
    
    private func setTitleNavBar(city: String){
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
        for (var i = 0; i < type.count; i++){
            result = result && (clotheDAL.fetch(type: type[i].lowercaseString).count >= 3)
        }
        return result
    }
    
    private func loadOutfits(){
        ActivityLoader.shared.showProgressView(self.view)
        DressTimeService().GetOutfitsToday(self.currentLocation) { (isSuccess, object) -> Void in
            if (isSuccess){
                self.weatherList = WeatherWrapper().arrayOfWeather(object["weather"])
                if (self.weatherList.count > 0){
                    self.currentWeather = self.weatherList[0]
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let headerCell = self.homeHeaderCell {
                            headerCell.collectionView.reloadData()
                        }
                        self.setTitleNavBar(self.currentWeather!.city!)
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            if (self.isEnoughClothe()) {
                                self.bgView.image = UIImage(named: WeatherHelper.changeBackgroundDependingWeatherCondition(self.currentWeather!.code!))
                            }
                        })
                    })
                    self.outfitList = [Outfit]()
                    //Load the collection of Outfits
                    if let outfitsCell = self.outfitsCell {
                        for (var i = 0; i < object["outfits"].arrayValue.count; i++){
                            self.outfitList.append(Outfit(json: object["outfits"][i]))
                        }
                        self.outfitsCell!.dataSource = self
                        outfitsCell.outfitCollectionView.reloadData()
                    }
                }
            } else {
                print("Error \(object.stringValue)")
            }
            ActivityLoader.shared.hideProgressView()
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
        ActivityLoader.shared.hideProgressView()

        switch(CLLocationManager.authorizationStatus()) {
        case .NotDetermined, .Restricted, .Denied:
            let alert = UIAlertController(title: NSLocalizedString("homeLocErrTitle", comment: ""), message: NSLocalizedString("homeLocErrMessage", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("homeLocErrButton", comment: ""), style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            print("Access")
        }
    }
}

extension HomeViewController: HomeHeaderCellDelegate {
    func numberOfItemsInHomeHeaderCell(homeHeaderCell: HomeHeaderCell) -> Int {
        return self.weatherList.count
    }
    
    func homeHeaderCell(homeHeaderCell: HomeHeaderCell, weatherForItem item: Int) -> Weather {
        return self.weatherList[item]
    }
    
    func homeHeaderCell(homeHeaderCell: HomeHeaderCell, didSelectItem item: Int) {
        self.currentWeather = self.weatherList[item];
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

extension HomeViewController: HomeBrandOutfitsListCellDelegate, HomeBrandOutfitsListCellDataSource {
    func numberOfItemsInHomeBrandOutfitsListCell(homeBrandOutfitsListCell: HomeBrandOutfitsListCell) -> Int {
        return self.brandClothesList.count
    }
    
    func homeBrandOutfitsListCell(homeBrandOutfitsListCell: HomeBrandOutfitsListCell, clotheForItem item: Int) -> ClotheModel {
        return self.brandClothesList[item]
    }
    
    func homeBrandOutfitsListCell(homeBrandOutfitsListCell: HomeBrandOutfitsListCell, didSelectItem item: Int) {
        //self.performSegueWithIdentifier("showShoppingList", sender: self)
        self.tabBarController!.selectedIndex = 2
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
        if (self.isEnoughClothes){
            return 4
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        NSLog("Load home tableview \(indexPath.row)")
        if (indexPath.row == 0) {
            if (!self.isEnoughClothes){
                let cell = self.tableView.dequeueReusableCellWithIdentifier("emptyStepCell") as? HomeEmptyStepCell
                cell?.delegate = self
                return cell!
            } else {
                self.homeHeaderCell = self.tableView.dequeueReusableCellWithIdentifier("headerCell") as? HomeHeaderCell
                self.homeHeaderCell!.delegate = self
                return self.homeHeaderCell!
            }
        } else if (indexPath.row == 1){
            if (!self.isEnoughClothes){
                self.emptyAnimationCell = self.tableView.dequeueReusableCellWithIdentifier("emptyAnimationCell") as? HomeEmptyAnimationCell
                self.emptyAnimationCell!.controller = self
                return self.emptyAnimationCell!

            } else {
                self.outfitsCell = self.tableView.dequeueReusableCellWithIdentifier("myOutfitsCell") as? HomeOutfitsListCell
                self.outfitsCell!.delegate = self
                return self.outfitsCell!
            }
        }  else if (indexPath.row == 2){
            self.brandOutfitsCell = self.tableView.dequeueReusableCellWithIdentifier("brandOutfitsCell") as? HomeBrandOutfitsListCell
            self.brandOutfitsCell!.delegate = self
            self.brandOutfitsCell!.dataSource = self
            return self.brandOutfitsCell!

        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0){
            if (!self.isEnoughClothes){
                return 186.0
            } else {
                return 100.0
            }
        } else if (indexPath.row == 1){
            return 370.0
        } else if (indexPath.row == 2){
            return 300.0
        } else {
            return 0.0
        }
    }

}