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
    
    private var currentStyleSelected: String?
    private var numberOfOutfits: Int = 0
    
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
        let historyButtonImage = UIImage(named: "profile_img")
        regularButton.setBackgroundImage(historyButtonImage, forState: UIControlState.Normal)
        
        regularButton.setTitle("", forState: UIControlState.Normal)
        regularButton.addTarget(self, action: "profilButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        let navBarButtonItem = UIBarButtonItem(customView: regularButton)
        self.navigationItem.leftBarButtonItem = navBarButtonItem
    }
    
    func profilButtonPressed(){
        //self.performSegueWithIdentifier("showProfil", sender: self)
        self.performSegueWithIdentifier("showProfil", sender: self)
    }
    
    private func configNavBar(){
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        bar.tintColor = UIColor.whiteColor()
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        addProfilButtonToNavBar()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showOutfits"){
            let targetVC = segue.destinationViewController as! OutfitsViewController
            targetVC.styleOutfits = self.currentStyleSelected
        }
    }

}

extension HomeViewController: HomeHeaderCellDelegate {
    func weatherFinishing(code: String) {
        //Call HomeOutfitsListCell
       let condition = weatherConditionByCode(Int(code)!)
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
                
            }
            print("-------------------\(condition)-------------------------")
            dispatch_sync(dispatch_get_main_queue(), {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.bgView.image = image
                })
            });
            print("-------------------\(condition)-------------------------")

        if let outfitsCell = self.outfitsCell {
            outfitsCell.loadTodayOutfits()
        }
    }
    
    func weatherConditionByCode(code: Int) -> String{
        var sun = [31, 32, 33, 34, 36]
        var cloud = [20, 21, 22, 26, 27, 28, 29, 30, 44]
        var rain = [1, 2, 3, 4, 6, 9, 11, 12, 17, 35, 37, 38, 39, 40, 45, 47]
        var wind = [0, 19, 23, 24]
        var snow = [5, 7, 8, 10, 13, 14, 15, 16, 18, 41, 42, 43, 46]
        
        for (var i = 0; i < sun.count; i++){
            if (code == sun[i]){
                return "sunny"
            }
        }
        for (var i = 0; i < cloud.count; i++){
            if (code == cloud[i]){
                return "cloudy"
            }
        }
        for (var i = 0; i < rain.count; i++){
            if (code == rain[i]){
                return "rainy"
            }
        }
        for (var i = 0; i < wind.count; i++){
            if (code == wind[i]){
                return "windy"
            }
        }
        for (var i = 0; i < snow.count; i++){
            if (code == snow[i]){
                return "snowy"
            }
        }
        return ""
    }
}

extension HomeViewController: HomeOutfitsListCellDelegate {
    func showOutfits(currentStyle: String) {
        self.currentStyleSelected = currentStyle
        self.performSegueWithIdentifier("showOutfits", sender: self)
    }
    
    func loadedOutfits(outfitsCount: Int) {
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
            return self.tableView.dequeueReusableCellWithIdentifier("brandOutfitsCell") as! HomeBrandOutfitsListCell
        }
        return UITableViewCell()
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 1){
            return 70.0
        } else if (indexPath.row == 2){
            if (self.numberOfOutfits > 0){
                return 350.0
            } else {
                return 170.0
            }
           
        } else if (indexPath.row == 3){
            return 350.0
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