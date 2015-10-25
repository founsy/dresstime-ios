//
//  NewHomeViewController.swift
//  DressTime
//
//  Created by Fab on 15/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit



class HomeViewController: UIViewController{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIImageView!
    
    var outfitsCell: HomeOutfitsListCell?
    var homeHeaderCell: HomeHeaderCell?
    var brandOutfitsCell: HomeBrandOutfitsListCell?
    
    private var currentStyleSelected: String?
    private var outfitSelected: JSON?
    private var numberOfOutfits: Int = 0
    
    private var currentWeather: Weather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configNavBar()
    }
    
    private func addProfilButtonToNavBar(){
        
        let regularButton = UIButton(frame: CGRectMake(0, 0, 40.0, 40.0))
        let historyButtonImage = UIImage(named: "ProfilImage")
        regularButton.setBackgroundImage(historyButtonImage, forState: UIControlState.Normal)
        
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
    
    func addButtonPressed(){
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
    
    func profilButtonPressed(){
        self.performSegueWithIdentifier("showProfil", sender: self)
    }
    
    private func configNavBar(){
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.20)
        bar.tintColor = UIColor.whiteColor()
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        addProfilButtonToNavBar()
        addAddButtonToNavBar()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showOutfit"){
            let targetVC = segue.destinationViewController as! OutfitViewController
            targetVC.currentOutfits = self.outfitSelected!["outfit"].arrayObject
        }

    }
    
    private func setTitleNavBar(city: String){
        let myView = NSBundle.mainBundle().loadNibNamed("TitleNavBar", owner: self, options: nil)[0] as! TitleNavBar
        myView.frame = CGRectMake(0, 0, 300, 30)
        myView.cityLabel.text = city
        self.navigationItem.titleView = myView;
    }

}

extension HomeViewController: HomeHeaderCellDelegate {
    func weatherFinishing(weather: Weather) {
        //Call HomeOutfitsListCell
        self.currentWeather = weather
        let condition = weatherConditionByCode(Int(weather.code!))
        var image: UIImage?
        
        if (condition == "sunny"){
            image = UIImage(named: "HomeBgSun")
        
        } else if (condition == "cloudy"){
            image = UIImage(named: "HomeBgSun")
            
        } else if (condition == "rainy"){
            image = UIImage(named: "HomeBgRain")
            
        } else if (condition == "windy"){
            image = UIImage(named: "HomeBgSun")
            
        } else if (condition == "snowy"){
            image = UIImage(named: "HomeBgSnow")
            
        } else {
            image = UIImage(named: "HomeBgSun")
        }
        print("-------------------\(condition)-------------------------")
        dispatch_async(dispatch_get_main_queue(), {
            self.setTitleNavBar(SharedData.sharedInstance.city!)
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.bgView.image = image
            })
        })
        print("-------------------\(condition)-------------------------")
        
        if let outfitsCell = self.outfitsCell {
            outfitsCell.loadTodayOutfits(self.currentWeather!)
        }
        if let outfitsBrandCell = self.brandOutfitsCell {
            outfitsBrandCell.loadTodayBrandOutfits()
        }
    }
    
    func weatherConditionByCode(code: Int) -> String{
        //2xx Thunderstorm
        //3xx Drizzle
        //5xx Rain
        //6xx Snow
        //7xx Atmosphere
        //800 sunny
        //80x Clouds
        //9xx Extreme
        
        
        if (code >= 200 && code < 300){
            return "windy"
        } else if (code >= 300 && code < 400){
            return "rainy"
        } else if (code >= 500 && code < 600){
            return "rainy"
        } else if (code >= 600 && code < 700){
            return "snowy"
        } else if (code >= 700 && code < 800){
            return ""
        } else if (code == 800 ){
            return "sunny"
        } else if (code >= 800 && code < 900){
            return "cloudy"
        } else if (code >= 900){
            return ""
        } else {
            return ""
        }

    }
}

extension HomeViewController: HomeOutfitsListCellDelegate {
    func showOutfits(outfit: JSON) {
        self.outfitSelected = outfit
        self.performSegueWithIdentifier("showOutfit", sender: self)
    }
    
    func loadedOutfits(outfitsCount: Int) {
        self.numberOfOutfits = outfitsCount
        self.tableView.reloadData()
    }
}

extension HomeViewController: HomeBrandOutfitsListCelllDelegate {
    func showBrandOutfits(currentStyle: String) {
        self.currentStyleSelected = currentStyle
        self.performSegueWithIdentifier("showOutfits", sender: self)
    }
    
    func loadedBrandOutfits(outfitsCount: Int) {
        self.numberOfOutfits = outfitsCount
        self.tableView.reloadData()
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        NSLog("\(indexPath.row)")
        if (indexPath.row == 1){
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
            return self.brandOutfitsCell!

        }
        return UITableViewCell()
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 1){
            return 92.0
        } else if (indexPath.row == 2){
            if (self.numberOfOutfits > 0){
                return 300.0
            } else {
                return 170.0
            }
           
        } else if (indexPath.row == 3){
            return 300.0
        } else {
            return 0.0
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