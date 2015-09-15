//
//  NewHomeViewController.swift
//  DressTime
//
//  Created by Fab on 15/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class NewHomeViewController: UIViewController{
    @IBOutlet weak var tableView: UITableView!
    
    var outfitsCell: HomeOutfitsListCell?
    var homeHeaderCell: HomeHeaderCell?
    
    private var currentStyleSelected: String?
    
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
        
        var regularButton = UIButton(frame: CGRectMake(0, 0, 40.0, 40.0))
        var historyButtonImage = UIImage(named: "profile_img")
        regularButton.setBackgroundImage(historyButtonImage, forState: UIControlState.Normal)
        
        regularButton.setTitle("", forState: UIControlState.Normal)
        regularButton.addTarget(self, action: "profilButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        var navBarButtonItem = UIBarButtonItem(customView: regularButton)
        self.navigationItem.leftBarButtonItem = navBarButtonItem
    }
    
    func profilButtonPressed(){
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

extension NewHomeViewController: HomeHeaderCellDelegate {
    func weatherFinishing() {
        //Call HomeOutfitsListCell
        if let outfitsCell = self.outfitsCell {
            outfitsCell.loadTodayOutfits()
        }
    }
}

extension NewHomeViewController: HomeOutfitsListCellDelegate {
    func showOutfits(currentStyle: String) {
        self.currentStyleSelected = currentStyle
        self.performSegueWithIdentifier("showOutfits", sender: self)
    }
}

extension NewHomeViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if (indexPath.row == 1){
            self.homeHeaderCell = self.tableView.dequeueReusableCellWithIdentifier("headerCell") as? HomeHeaderCell
            self.homeHeaderCell!.delegate = self
            return self.homeHeaderCell!
        } else if (indexPath.row == 2){
            return self.tableView.dequeueReusableCellWithIdentifier("ootdCell") as! UITableViewCell
        } else if (indexPath.row == 3){
            self.outfitsCell = self.tableView.dequeueReusableCellWithIdentifier("myOutfitsCell") as? HomeOutfitsListCell
            self.outfitsCell!.delegate = self
            return self.outfitsCell!
        } else if (indexPath.row == 4){
            return self.tableView.dequeueReusableCellWithIdentifier("brandOotdCell") as! UITableViewCell
        } else if (indexPath.row == 5){
            return self.tableView.dequeueReusableCellWithIdentifier("brandOutfitsCell") as! HomeBrandOutfitsListCell
        }
        return UITableViewCell()
    }
}

extension NewHomeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 1){
            return 70.0
        } else if (indexPath.row == 2){
            return 40.0
        } else if (indexPath.row == 3){
           return 310.0
        } else if (indexPath.row == 4){
            return 40.0
        } else if (indexPath.row == 5){
            return 310.0
        } else {
            return 0.0
        }
    }

}