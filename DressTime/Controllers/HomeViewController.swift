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


class HomeViewController: UIDTViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var emptyView: UIVisualEffectView!
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var shoppingBarButton: UIBarButtonItem!
    
    var outfitsCell: HomeOutfitsListCell?
    var homeHeaderCell: HomeHeaderCell?
    var brandOutfitsCell: HomeBrandOutfitsListCell?
    
    private var currentStyleSelected: String?
    private var outfitSelected: Outfit?
    private var numberOfOutfits: Int = 0
    private var numberOfClothes: Int = 0
    private var arrowImageView: UIImageView?
    
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
        if (self.numberOfClothes > 0){
            self.emptyView.hidden = true
            shoppingBarButton.enabled = true
            shoppingBarButton.tintColor = nil
            self.tableView.reloadData()
        } else {
            self.tableView.reloadData()
            self.emptyView.hidden = false
            
            self.animationImageView.animationImages = self.loadAnimateImage()
            self.animationImageView.animationDuration = 3.5
            self.animationImageView.startAnimating()
            
            shoppingBarButton.enabled = false
            shoppingBarButton.tintColor = UIColor.clearColor()
            
            ActivityLoader.shared.hideProgressView()
        }
    }   
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.numberOfClothes == 0){
            createArrowImageView()
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
    
    private func createArrowImageView(){
        if let imageView = self.arrowImageView {
            imageView.removeFromSuperview()
        }
        self.arrowImageView = UIImageView(image: UIImage(named: "arrowIcon"))
        let p = self.bubbleImageView.convertPoint(self.bubbleImageView.frame.origin, toView: self.view)
        self.arrowImageView!.frame = CGRectMake(bubbleImageView.frame.width + bubbleImageView.frame.origin.x, 64, 64.0, p.y - 64.0)
        self.arrowImageView!.hidden = (self.numberOfClothes > 0)
        self.view.addSubview(self.arrowImageView!)
    }
    
    private func addProfilButtonToNavBar(){
        let regularButton = UIButton(frame: CGRectMake(0, 0, 40.0, 40.0))
        if (SharedData.sharedInstance.currentUserId!.lowercaseString == "alexandre"){
            regularButton.setBackgroundImage(UIImage(named: "profileAlexandre"), forState: UIControlState.Normal)
        } else if (SharedData.sharedInstance.currentUserId!.lowercaseString == "juliette"){
            regularButton.setBackgroundImage(UIImage(named: "profileJuliette"), forState: UIControlState.Normal)
        } else {
            regularButton.setBackgroundImage(UIImage(named: "profile\(SharedData.sharedInstance.sexe!.uppercaseString)"), forState: UIControlState.Normal)
        }
        
        regularButton.setTitle("", forState: UIControlState.Normal)
        regularButton.addTarget(self, action: "profilButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        let navBarButtonItem = UIBarButtonItem(customView: regularButton)
        self.navigationItem.leftBarButtonItem = navBarButtonItem
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
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        
        bar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        bar.shadowImage = UIImage()
        bar.tintColor = UIColor.whiteColor()
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        addProfilButtonToNavBar()
        addAddButtonToNavBar()
       
    }
    
    private func setTitleNavBar(city: String){
        let myView = NSBundle.mainBundle().loadNibNamed("TitleNavBar", owner: self, options: nil)[0] as! TitleNavBar
        myView.frame = CGRectMake(0, 0, 300, 30)
        myView.cityLabel.text = city
        self.navigationItem.titleView = myView;
    }
    
    private func loadAnimateImage() -> [UIImage] {
        let imagesListArray :NSMutableArray = []
        for position in 0...296{
            var i = String(position)
            if (i.characters.count == 1){
                i = "00" + i
            } else if (i.characters.count == 2){
                i =  "0" + i
            }
            
            let strImageName : String = "men_00\(i).png"
            let image  = UIImage(named:strImageName)
            imagesListArray.addObject(image!)
        }
        return imagesListArray as AnyObject as! [UIImage]
    }
}


extension HomeViewController: CLLocationManagerDelegate {
    /***/
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false){
            locationFixAchieved = true
            
            self.currentLocation = locations[locations.count-1]
            locationManager.stopUpdatingLocation()
            ActivityLoader.shared.showProgressView(self.view)
            DressTimeService().GetOutfitsToday(self.currentLocation) { (isSuccess, object) -> Void in
                if (isSuccess){
                    self.weatherList = WeatherWrapper().arrayOfWeather(object["weather"])
                    if (self.weatherList.count > 0){
                        self.currentWeather = self.weatherList[0]
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.homeHeaderCell!.collectionView.reloadData()
                            self.setTitleNavBar(self.currentWeather!.city!)
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                self.bgView.image = UIImage(named: WeatherHelper.changeBackgroundDependingWeatherCondition(self.currentWeather!.code!))
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
            shoppingBarButton.enabled = true
            shoppingBarButton.tintColor = nil
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
        self.performSegueWithIdentifier("showShoppingList", sender: self)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.numberOfClothes > 0){
            return 4
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        NSLog("Load home tableview \(indexPath.row)")
        if (indexPath.row == 1) {
            self.homeHeaderCell = self.tableView.dequeueReusableCellWithIdentifier("headerCell") as? HomeHeaderCell
            self.homeHeaderCell!.delegate = self
            return self.homeHeaderCell!
        } else if (indexPath.row == 2){
            self.outfitsCell = self.tableView.dequeueReusableCellWithIdentifier("myOutfitsCell") as? HomeOutfitsListCell
            self.outfitsCell!.delegate = self
            return self.outfitsCell!
        }  else if (indexPath.row == 3){
            self.brandOutfitsCell = self.tableView.dequeueReusableCellWithIdentifier("brandOutfitsCell") as? HomeBrandOutfitsListCell
            self.brandOutfitsCell!.delegate = self
            self.brandOutfitsCell!.dataSource = self
            return self.brandOutfitsCell!

        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 1){
            return 100.0
        } else if (indexPath.row == 2){
            return 370.0
        } else if (indexPath.row == 3){
            return 300.0
        } else {
            return 0.0
        }
    }

}