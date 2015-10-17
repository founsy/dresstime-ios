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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)

        //tableView.registerNib(UINib(nibName: "ClotheTableCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        tableView.registerNib(UINib(nibName: "ClotheScrollTableCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        
        tableView!.delegate = self
        tableView!.dataSource = self
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
        return height
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
        
        
       /* if let outfit = self.currentOutfits[indexPath.row] as? NSDictionary {
            let clothe_id = outfit["clothe_id"] as! String
            if let clothe = dal.fetch(clothe_id) {
                if let image = UIImage(data: clothe.clothe_image) {
                    NSLog("\(image.size.width) - \(image.size.height)")
                    cell.clotheImageView.image = image.imageWithImage(480.0)
                }
                cell.layer.shadowOffset = CGSizeMake(3, 6);
                cell.layer.shadowColor = UIColor.blackColor().CGColor
                cell.layer.shadowRadius = 8;
                cell.layer.shadowOpacity = 0.75;
                cell.clotheImageView.clipsToBounds = true
                cell.favorisIcon.clipsToBounds = true
                
                //Remove edge insets to have full width separtor line
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsetsZero
                cell.layoutMargins = UIEdgeInsetsZero
            }
        } */
        return cell
    }
}