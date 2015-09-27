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
    private let cellDetailIdentifier : String = "ClotheDetailTableCell"
    private var arrayForBool = [Bool]()
    private let dal = ClothesDAL()
    private var currentSection: Int = -1
    
    var itemIndex: Int = 0
    var currentOutfits: NSArray!
    var frame: CGRect?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame = frame!

        tableView.registerNib(UINib(nibName: "ClotheTableCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        tableView.registerNib(UINib(nibName: "ClotheDetailTableCell", bundle:nil), forCellReuseIdentifier: self.cellDetailIdentifier)
        
        tableView!.delegate = self
        tableView!.dataSource = self

        initData()
    }
    
    private func initData(){
        if let outfits = self.currentOutfits {
            for (var i=0; i < outfits.count; i++){
                arrayForBool.append(false)
            }
        }
    }
}

extension OutfitViewController: ClotheDetailTableViewCellDelegate {
    func onEditClothe(indexPath: NSIndexPath) {
        /*if let currentClothe = self.clothesList?[indexPath.row] {
            DressTimeService.deleteClothe(SharedData.sharedInstance.currentUserId!, clotheId: currentClothe.clothe_id, clotheDelCompleted: { (succeeded, msg) -> () in
                println("Clothe deleted")
                let dal = ClothesDAL()
                dal.delete(currentClothe)
                /* dispatch_sync(dispatch_get_main_queue(), {
                self.initData()
                self.tableView.reloadData()
                }) */
            })
        }
        self.clothesList!.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic) */
    }
}


extension OutfitViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let oldRow = self.currentSection
        self.currentSection = self.currentSection == indexPath.row ? -1 : indexPath.row
        
        //Collapse row already opened
        for (var i = 0; i < arrayForBool.count; i++) {
            let collapsed = arrayForBool[i] as Bool
            if (collapsed && i != indexPath.row) {
                arrayForBool[i] = !collapsed
                let path:NSIndexPath = NSIndexPath(forItem: oldRow, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([path], withRowAnimation:UITableViewRowAnimation.Fade)
                break
            }
        }
        
        //Open new one
        var collapsed = arrayForBool[indexPath.row]
        collapsed = !collapsed;
        arrayForBool[indexPath.row] = collapsed
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height:CGFloat = (self.tableView.bounds.height) / CGFloat(self.currentOutfits.count)
        if (arrayForBool[indexPath.row].boolValue as Bool){
            return height*1.4
        } else {
            return height
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let list = self.currentOutfits {
            return list.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (arrayForBool[indexPath.row].boolValue as Bool){
            let cell = tableView.dequeueReusableCellWithIdentifier(self.cellDetailIdentifier, forIndexPath: indexPath) as! ClotheDetailTableViewCell
            
            let clothe_id = self.currentOutfits[indexPath.row]["clothe_id"] as! String
            if let clothe = dal.fetch(clothe_id) {
                cell.clotheImageView.image = UIImage(data: clothe.clothe_image)
                cell.updateColors(clothe.clothe_colors)
                cell.roundTopCorner()
                cell.clotheImageView.clipsToBounds = true
                cell.indexPath = indexPath
                cell.delegate = self
            }
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ClotheTableViewCell
            
            let clothe_id = self.currentOutfits[indexPath.row]["clothe_id"] as! String
            if let clothe = dal.fetch(clothe_id) {
                if let image = UIImage(data: clothe.clothe_image) {
                    NSLog("\(image.size.width) - \(image.size.height)")
                
                    cell.clotheImageView.image = image.imageResize(CGSizeMake(380.0, 480.0))
                }
                cell.layer.shadowOffset = CGSizeMake(3, 6);
                cell.layer.shadowColor = UIColor.blackColor().CGColor
                cell.layer.shadowRadius = 8;
                cell.layer.shadowOpacity = 0.75;
                cell.clotheImageView.clipsToBounds = true
                cell.favorisIcon.clipsToBounds = true
            }
            return cell
        }
        
        
    }
}