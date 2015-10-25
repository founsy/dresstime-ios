//
//  OutfitsViewController.swift
//  DressTime
//
//  Created by Fab on 09/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class OutfitViewController: UIViewController {
    private let cellIdentifier : String = "ClotheTableCell"
    private let dal = ClothesDAL()
    private var currentSection: Int = -1
    
    var itemIndex: Int = 0
    var currentOutfits: NSArray!
    
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var labelButton: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroudView: UIView!
    @IBOutlet weak var dressupButton: UIButton!
    @IBAction func onDressUpTapped(sender: AnyObject) {
        let originFrame = self.dressupButton.layer.frame
        let originImgFrame =  self.checkImage.frame
        let originLabelFrame =  self.labelButton.frame
        
        UIView.animateAndChainWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1.0, options: [ .CurveEaseOut], animations: {
            
            self.dressupButton.layer.cornerRadius = 62.5
            self.dressupButton.layer.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0 - 62.5, UIScreen.mainScreen().bounds.size.height/2.0 - 62.5, 125, 125)
            
            
            
            self.labelButton.alpha = 0
            self.labelButton.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0 - 32.5, UIScreen.mainScreen().bounds.size.height/2.0 - 32.5, 75, 75)
            
            self.checkImage.alpha = 1
            self.checkImage.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0 - 32.5, UIScreen.mainScreen().bounds.size.height/2.0 - 32.5, 75, 75)
            
            self.backgroudView.alpha = 0.4
            }){ (finish) -> Void in
                //self.labelButton.text = "OUTFIT OF THE DAY"
            }.animateWithDuration(0.5, delay: 0.5, options: .CurveEaseOut, animations: { () -> Void in
                
                self.dressupButton.layer.cornerRadius = 0.0
                self.dressupButton.layer.frame = originFrame
                self.dressupButton.backgroundColor = UIColor(red: 4/255, green: 128/255, blue: 64/255, alpha: 1)
               
                self.checkImage.layer.frame = originImgFrame
                self.checkImage.alpha = 0
                
                               self.labelButton.frame = originLabelFrame
                
                self.backgroudView.alpha = 0.0
                }){ (finish) -> Void in
                    self.labelButton.alpha = 1
                    self.labelButton.text = "OUTFIT OF THE DAY"
                }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ClotheScrollTableCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        
        tableView!.delegate = self
        tableView!.dataSource = self
           }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "HOME", style: .Plain, target: nil, action: nil)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailClothe") {
                let navigationController = segue.destinationViewController as! UINavigationController
                if let detailController = navigationController.viewControllers[0] as? DetailClotheViewController {
                    if let outfit = self.currentOutfits[self.currentSection] as? NSDictionary {
                        let clothe_id = outfit["clothe_id"] as! String
                        if let clothe = dal.fetch(clothe_id) {
                            detailController.currentClothe =  clothe
                        }
                    }
                }
        }
    }
}


extension OutfitViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.currentSection = indexPath.row
    
        print("didSelectRowAtIndexPath")
        self.currentSection = indexPath.row
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.performSegueWithIdentifier("detailClothe", sender: self)
        })
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height:CGFloat = (tableView.frame.height-20.0) / CGFloat(self.currentOutfits.count)
        
        if let list = self.currentOutfits {
            if (indexPath.row == list.count - 1){
                return height + 45.0
            }
        }
        return height - 25.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let list = self.currentOutfits {
            return list.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ClotheScrollTableCell
        if let outfit = self.currentOutfits[indexPath.row] as? NSDictionary {
            let type = outfit["clothe_type"] as! String
            let clothe_id = outfit["clothe_id"] as! String
            
            let collection = dal.fetch(type: type)
            cell.clotheCollection = collection
            cell.currentOutfit =  dal.fetch(clothe_id)
            cell.setupScrollView(cell.contentView.bounds.size.width, height: cell.contentView.bounds.size.height)
            cell.layer.shadowOffset = CGSizeMake(3, 6);
            cell.layer.shadowColor = UIColor.blackColor().CGColor
            cell.layer.shadowRadius = 8;
            cell.layer.shadowOpacity = 0.75;
            
            //Remove edge insets to have full width separtor line
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
        }

        return cell
    }
}