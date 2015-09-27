//
//  DetailTypeViewController.swift
//  DressTime
//
//  Created by Fab on 04/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class DetailTypeViewController: UIViewController {
    private let cellIdentifier : String = "ClotheTableCell"
    private let cellDetailIdentifier : String = "ClotheDetailTableCell"
    private var clothesList: [Clothe]?
    private var arrayForBool = [Bool]()
    private var currentSection = -1
    
    var typeClothe: String?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleNav: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        tableView.registerNib(UINib(nibName: "ClotheTableCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        tableView.registerNib(UINib(nibName: "ClotheDetailTableCell", bundle:nil), forCellReuseIdentifier: self.cellDetailIdentifier)
        
        tableView!.delegate = self
        tableView!.dataSource = self
        titleNav.title = "Your \(typeClothe!.uppercaseString)!"
        blackNavBar()
    }
    
    func initData(){
        let dal = ClothesDAL()
        if let type = self.typeClothe {
            self.clothesList = dal.fetch(type: type)
        }
        for (var i=0; i < self.clothesList!.count; i++){
            arrayForBool.append(false)
        }
    }
    
    private func blackNavBar(){
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        bar.tintColor = UIColor.whiteColor()
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
}

extension DetailTypeViewController: ClotheDetailTableViewCellDelegate {
    func onEditClothe(indexPath: NSIndexPath) {
       if let currentClothe = self.clothesList?[indexPath.row] {
            DressTimeService.deleteClothe(SharedData.sharedInstance.currentUserId!, clotheId: currentClothe.clothe_id, clotheDelCompleted: { (succeeded, msg) -> () in
                print("Clothe deleted")
                let dal = ClothesDAL()
                dal.delete(currentClothe)
               /* dispatch_sync(dispatch_get_main_queue(), {
                    self.initData()
                    self.tableView.reloadData()
                }) */
            })
        }
        self.clothesList!.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}

extension DetailTypeViewController: UITableViewDataSource, UITableViewDelegate {

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
        
      /*  var detail = self.storyboard!.instantiateViewControllerWithIdentifier("ClotheDetail") as! ClotheDetailController
        detail.currentClothe = self.clothesList![indexPath.row]
        self.presentViewController(detail, animated: true, completion: nil) */
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height:CGFloat = 150.0
        if (arrayForBool[indexPath.row].boolValue as Bool){
            return height*2.8
        } else {
            return height
        }

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let list = self.clothesList {
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
            let clothe = self.clothesList![indexPath.row]
            cell.clotheImageView.image = UIImage(data: clothe.clothe_image)
            cell.updateColors(clothe.clothe_colors as String)
            cell.roundTopCorner()
            cell.clotheImageView.clipsToBounds = true
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        } else {
        
            let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ClotheTableViewCell
        
            let clothe = self.clothesList![indexPath.row]
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
           /* if (self.currentSection > -1){
                 cell.blackEffect.alpha = 0.5;
            } else {
                cell.blackEffect.alpha = 0;
            }*/
            return cell;
        }
        
        
    }
}

extension UIImage {
    func imageResize (sizeChange:CGSize)-> UIImage{
        var ratio = 1;
        if (self.size.width > sizeChange.width){
            ratio = Int(self.size.width/sizeChange.width);
        }
        let newWidth = self.size.width/CGFloat(ratio);
        let newHeight = self.size.height/CGFloat(ratio);
        
        let newSize = CGSizeMake(newWidth, newHeight)
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: newSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

}