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
    fileprivate var headerView: UIView!
    fileprivate var kTableHeaderHeight:CGFloat = 184.0
    
    fileprivate var currentStyleSelected: String?
    fileprivate var outfitSelected: Outfit?
    fileprivate var numberOfOutfits: Int = 0
    fileprivate var numberOfClothes: Int = 0
    fileprivate var arrowImageView: UIImageView?
    fileprivate var isEnoughClothes = true
    
    fileprivate var typeClothe:Int = -1
    fileprivate var currentWeather: Weather?
    fileprivate var needToReload = false
    
    fileprivate var locationManager: CLLocationManager!
    fileprivate var currentLocation: CLLocation!
    fileprivate var locationFixAchieved : Bool = false
    fileprivate var outfitList = [Outfit]()
    fileprivate var brandClothesList = [ClotheModel]()
    
    fileprivate var loadingView: LaunchingView?
    
    fileprivate var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "Home"
        
        addLoadingView()
        configNavBar()
        weatherContainer.layer.cornerRadius = 22.5
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
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
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(HomeViewController.needToReloadOutfit), name: NSNotification.Name(rawValue: "ClotheDeletedNotification"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false // for status bar hide
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
                if (self.tabBarController!.viewControllers?.count == 2  ) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let vcCalendar = storyboard.instantiateViewController(withIdentifier: "CalendarNavigationViewController") as! DTNavigationController
                    self.tabBarController!.viewControllers?.insert(vcCalendar, at: 1)
                  /*
                    let vcShopping = storyboard.instantiateViewControllerWithIdentifier("ShoppingNavigationViewController") as! DTNavigationController
                    self.tabBarController!.viewControllers?.insert(vcShopping, atIndex: 3) */
                    
                }
                //Remove Arrow image view
                for item in self.view.subviews {
                    if let imageview = item as? UIImageView {
                        if (imageview != self.bgView){
                            imageview.removeFromSuperview()
                        }
                    }
                }
                self.headerView.isHidden = false
                self.tableView.addSubview(headerView)
                self.tableView.contentInset = UIEdgeInsets(top: (kTableHeaderHeight), left: 0, bottom: 0, right: 0)
                self.tableView.contentOffset = CGPoint(x: 0, y: (-kTableHeaderHeight))
                
                //Reload TableView with good cell
                self.tableView.reloadData()
                
                //updateHeaderView()
            }
            if (!isLoaded && self.currentLocation != nil){
                //Call web service to get Outfits of the Day
                self.loadOutfits()
                
                //Reload TableView with good cell
                self.tableView.reloadData()
                
            }
            updateHeaderView()
            
        } else {
            self.tableView.reloadData()
            if (self.tabBarController!.viewControllers?.count == 3) {
                self.tabBarController!.viewControllers?.remove(at: 1)
            }
            self.bgView.image = UIImage(named: "backgroundEmpty")
            self.headerView.isHidden = true
            self.tableView.contentInset = UIEdgeInsets(top: (64), left: 0, bottom: 0, right: 0)
            self.tableView.contentOffset = CGPoint(x: 0, y: (-64))
            ActivityLoader.shared.hideProgressView()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.locationManager = nil
    }
    
    
    fileprivate func addLoadingView(){
       let currentWindow = UIApplication.shared.keyWindow!
       
        loadingView = Bundle.main.loadNibNamed("LaunchingView", owner: self, options: nil)?[0] as? LaunchingView
        loadingView!.frame = self.view.frame
        loadingView!.tag = 1000
        currentWindow.addSubview(loadingView!)
    }
    
    fileprivate func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if  tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    func needToReloadOutfit(){
        self.isLoaded = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showOutfit"){
            let targetVC = segue.destination as! OutfitViewController
            targetVC.outfitObject = self.outfitSelected
            targetVC.currentOutfits = self.outfitSelected!.clothes
            targetVC.delegate = self
        } else if (segue.identifier == "AddClothe"){
            if (typeClothe >= 0) {
                let navController = segue.destination as! UINavigationController
                let targetVC = navController.topViewController as! TypeViewController
                targetVC.openItem(typeClothe)
            }
        }
    }
    
    func addButtonPressed(){
        self.performSegue(withIdentifier: "AddClothe", sender: self)
    }
    
    func profilButtonPressed(){
        self.performSegue(withIdentifier: "showProfil", sender: self)
    }
    
    fileprivate func addAddButtonToNavBar(){
        let regularButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35.0, height: 35.0))
        let historyButtonImage = UIImage(named: "AddIcon")
        regularButton.setBackgroundImage(historyButtonImage, for: UIControlState())
        
        regularButton.setTitle("", for: UIControlState())
        regularButton.addTarget(self, action: #selector(HomeViewController.addButtonPressed), for: UIControlEvents.touchUpInside)
        let navBarButtonItem = UIBarButtonItem(customView: regularButton)
        self.navigationItem.rightBarButtonItem = navBarButtonItem
    }
    
    fileprivate func configNavBar(){
        addAddButtonToNavBar()
    }
    
    fileprivate func setTitleNavBar(_ city: String?){
        let myView = Bundle.main.loadNibNamed("TitleNavBar", owner: self, options: nil)?[0] as! TitleNavBar
        myView.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        myView.cityLabel.text = city
        self.navigationItem.titleView = myView;
    }
    
    fileprivate func isEnoughClothe() -> Bool {
        let type = SharedData.sharedInstance.getType(SharedData.sharedInstance.sexe!)
        let clotheDAL = ClothesDAL()
        if (ClothesDAL().numberOfClothes() > 10){
            return true;
        }
        
        var result = true
        for i in 0 ..< type.count {
            result = result && (clotheDAL.fetch(type: type[i].lowercased()).count >= 3)
        }
        return result
    }
    
    fileprivate func loadOutfits(){
        DressTimeService().GetOutfitsToday(self.currentLocation) { (isSuccess, object) -> Void in
            if (isSuccess){
                self.isLoaded = true
                
                self.currentWeather = Weather(json: object["weather"]["current"])
                SharedData.sharedInstance.currentWeater = self.currentWeather
                let sentence = object["weather"]["comment"].stringValue
                
                DispatchQueue.main.async(execute: { () -> Void in
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
                        self.outfitList = self.outfitList.sorted(by: { (outfit1, outfit2) -> Bool in
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
                NotificationCenter.default.post(name: Notifications.Error.GetOutfit, object: nil)
                DispatchQueue.main.async(execute: {
                    self.loadingView!.animateMask()
                })
            }
        }
    }
}

extension HomeViewController: OutfitViewControllerDelegate {
    func outfitViewControllerDelegate(_ outfitViewController: OutfitViewController, didModifyOutfit outfit: Outfit) {
        self.needToReload = true
        if let cell = self.outfitsCell {
            cell.outfitCollectionView.reloadData()
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    /***/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false){
            locationFixAchieved = true
            
            self.currentLocation = locations[locations.count-1]
            locationManager.stopUpdatingLocation()
            loadOutfits()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        switch(CLLocationManager.authorizationStatus()) {
        case .notDetermined, .restricted, .denied:
            
            let alert = UIAlertController(title: NSLocalizedString("homeLocErrTitle", comment: ""), message: NSLocalizedString("homeLocErrMessage", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("homeLocErrButton", comment: ""), style: .default) { _ in })
            DispatchQueue.main.async(execute: {
                self.loadingView!.animateMask()
                self.present(alert, animated: true, completion: nil)
            })
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access")
        }
    }
}

extension HomeViewController: HomeOutfitsListCellDelegate, HomeOutfitsListCellDataSource {
    
    /* Data Source */
    func numberOfItemsInHomeOutfitsListCell(_ homeOutfitsListCell: HomeOutfitsListCell) -> Int {
        return self.outfitList.count
    }
    
    func homeOutfitsListCell(_ homeOutfitsListCell: HomeOutfitsListCell, outfitForItem item: Int) -> Outfit {
        return self.outfitList[item]
    }
    
    /* Delegate */
    func homeOutfitsListCell(_ homeOutfitsListCell: HomeOutfitsListCell, loadedOutfits outfitsCount: Int){
        self.numberOfOutfits = outfitsCount
        if (self.numberOfOutfits > 0){
            
        }
    }
    
    
    func homeOutfitsListCell(_ homeOutfitsListCell: HomeOutfitsListCell, didSelectItem item: Int) {
        self.outfitSelected = self.outfitList[item]
        self.performSegue(withIdentifier: "showOutfit", sender: self)
    }
    
    
    func homeOutfitsListCell(_ homeOutfitsListCell: HomeOutfitsListCell, openCaptureType type: String) {
        if let intType = Int(type) {
            self.typeClothe = intType
        }
        self.performSegue(withIdentifier: "AddClothe", sender: self)
    }
}

extension HomeViewController: HomeEmptyStepCellDelegate {
    func homeEmptyStepCell(_ homeEmptyStepCell: HomeEmptyStepCell, didSelectItem item: String) {
        switch(item.lowercased()){
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
        self.performSegue(withIdentifier: "AddClothe", sender: self)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!self.isEnoughClothes){
            return 2
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if ((indexPath as NSIndexPath).row == 0) {
            if (!self.isEnoughClothes){
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "emptyStepCell") as? HomeEmptyStepCell
                cell?.delegate = self
                return cell!
            } else {
                self.outfitsCell = self.tableView.dequeueReusableCell(withIdentifier: "myOutfitsCell") as? HomeOutfitsListCell
                self.outfitsCell!.delegate = self
                return self.outfitsCell!
            }
        } else if ((indexPath as NSIndexPath).row == 1){
            if (!self.isEnoughClothes){
                self.emptyAnimationCell = self.tableView.dequeueReusableCell(withIdentifier: "emptyAnimationCell") as? HomeEmptyAnimationCell
                self.emptyAnimationCell!.controller = self
                return self.emptyAnimationCell!
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath as NSIndexPath).row == 0){
            if (!self.isEnoughClothes){
                return 186.0
            } else {
                return 400.0
            }
        } else if ((indexPath as NSIndexPath).row == 1){
            return 400.0
        } else if ((indexPath as NSIndexPath).row == 2){
            return 300.0
        } else {
            return 0.0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.isEnoughClothes){
            updateHeaderView()
            if (tableView.contentOffset.y > -140){
                navigationController?.navigationBar.alpha = (CGFloat(abs(tableView.contentOffset.y))/140.0-0.5) > 0.3 ? (CGFloat(abs(tableView.contentOffset.y))/140.0-0.5) : 0
            } else {
                navigationController?.navigationBar.alpha = 1.0
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
}
