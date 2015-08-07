//
//  TypeViewController.swift
//  DressTime
//
//  Created by Fab on 05/08/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class TypeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var sectionTitleArray : NSMutableArray = NSMutableArray()
    var sectionContentDict : NSMutableDictionary = NSMutableDictionary()
    var arrayForBool : NSMutableArray = NSMutableArray()
    
    let labelsSubTop = ["tshirt", "shirt", "shirt-sleeve", "polo","polo-sleeve"]
    let labelsSubPants = ["jeans", "jeans-slim", "trousers-pleated", "trousers-suit", "chinos", "trousers-regular", "trousers", "trousers-slim", "bermuda", "short"]
    let labelsSubMaille = ["jumper-fin","jumper-epais ","cardigan","sweater"]
    
    let bgType = ["TypeMaille", "TypeTop", "TypePants"]
    
    private let barSize : CGFloat = 44.0
    private let kCellReuse : String = "SubTypeCell"
    private let kCellType : String = "TypeCell"
    private var collectionView : UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())   // Initialization
    
    private var currentSection = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayForBool = ["0","0", "0"]
        sectionTitleArray = ["Maille","Top", "Pants"]
        
        var tmp1 : NSArray = ["jumper-fin","jumper-epais ","cardigan","sweater"]
        var string1 = sectionTitleArray .objectAtIndex(0) as? String
        [sectionContentDict .setValue(tmp1, forKey:string1! )]
        
        var tmp2 : NSArray = ["tshirt", "shirt", "shirt-sleeve", "polo","polo-sleeve"]
        string1 = sectionTitleArray .objectAtIndex(1) as? String
        [sectionContentDict .setValue(tmp2, forKey:string1! )]
        
        var tmp3 : NSArray = ["jeans", "jeans-slim", "trousers-pleated", "trousers-suit", "chinos", "trousers-regular", "trousers", "trousers-slim", "bermuda", "short"]
        string1 = sectionTitleArray .objectAtIndex(2) as? String
        [sectionContentDict .setValue(tmp3, forKey:string1! )]
        
    }
}

extension TypeViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        let oldRow = self.currentSection
        self.currentSection = indexPath.row
        
        //Collapse row already opened
        for (var i = 0; i < arrayForBool.count; i++) {
            var collapsed = arrayForBool.objectAtIndex(i).boolValue as Bool
            if (collapsed && i != indexPath.row) {
                arrayForBool.replaceObjectAtIndex(i, withObject: !collapsed)
                var path:NSIndexPath = NSIndexPath(forItem: oldRow, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([path], withRowAnimation:UITableViewRowAnimation.Fade)
                break
            }
        }
        
        //Open new one
        var collapsed = arrayForBool.objectAtIndex(indexPath.row).boolValue
        collapsed = !collapsed;
            
        arrayForBool.replaceObjectAtIndex(indexPath.row, withObject: collapsed)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        self.collectionView.reloadData()
    }
}

extension TypeViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitleArray.count
    }
    
    func calculateCollectionViewHeight() -> CGFloat {
        let cellHeight = 110.0
        
        var height = 0.0
        switch(self.currentSection) {
        case 0:
            height = round(Double(labelsSubMaille.count)/2.0) * cellHeight
        case 1:
           height = round(Double(labelsSubTop.count)/2.0) * cellHeight
        case 2:
           height =  round(Double(labelsSubPants.count)/2.0) * cellHeight
        default:
            height = 0
            break
        }
        return CGFloat(height)
    }
   
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = self.tableView.bounds.height;
        if (arrayForBool.objectAtIndex(indexPath.row).boolValue as Bool){
            return calculateCollectionViewHeight()
        } else {
            return round(height*0.33333)
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = self.tableView.dequeueReusableCellWithIdentifier(kCellType) as! TypeTableViewCell
        
        var height = self.tableView.bounds.height;
        //Resize cell
        cell.contentView.frame = CGRectMake(0, 0, tableView.frame.size.width, round(height*0.33333))
        
        if (arrayForBool.objectAtIndex(indexPath.row).boolValue as Bool){
            cell.bgImage.image = UIImage(named: "\(bgType[indexPath.row])Full")
            var layout = UICollectionViewFlowLayout()
            // Collection
            self.collectionView.delegate = self     // delegate  :  UICollectionViewDelegate
            self.collectionView.dataSource = self   // datasource  : UICollectionViewDataSource
            self.collectionView.backgroundColor = UIColor.clearColor()
            
            self.collectionView.frame = CGRectMake(0, 0, tableView.frame.size.width, calculateCollectionViewHeight())
            
            // Register parts(header and cell
            var customCell = UINib(nibName: "SubTypeCell", bundle: nil)
            self.collectionView.registerNib(customCell, forCellWithReuseIdentifier: kCellReuse)
            cell.contentView.addSubview(self.collectionView)
            
        } else {
            cell.bgImage.image = UIImage(named: bgType[indexPath.row])
        }
        
        return cell
    }
}

extension TypeViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell : CustomSubTypeViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellReuse, forIndexPath: indexPath) as! CustomSubTypeViewCell
        println(self.currentSection)
        switch(self.currentSection) {
        case 0:
            cell.label.text = labelsSubMaille[indexPath.row]
        case 1:
            cell.label.text = labelsSubTop[indexPath.row]
        case 2:
            cell.label.text = labelsSubPants[indexPath.row]
        default:
            cell.label.text = ""
            break
        }
        return cell    //Create UICollectionViewCell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1  // Number of section
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var res = 0
        switch(self.currentSection) {
        case 0:
            res = labelsSubMaille.count // Number of cell per section(section 0)
        case 1:
            res = labelsSubTop.count // Number of cell per section(section 0)
        case 2:
            res = labelsSubPants.count // Number of cell per section(section 0)
        default:
            res = 0
            break
        }
        return res
    }
}

extension TypeViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        // Select operation
        println("tapped on collection")
        var captureView = CameraOverlayView()
        captureView.delegate = self
        captureView.typeClothe = getType(self.currentSection)
        captureView.subTypeClothe = getSubType(self.currentSection, subType: indexPath.row)
        self.presentViewController(captureView, animated: true, completion: nil)
    }
    
    func getType(type: Int) -> String{
        switch(type){
        case 0:
            return "maille"
        case 1:
            return "top"
        case 2:
            return "pants"
        default:
            return ""
        }
    }
    
    func getSubType(type: Int, subType: Int) -> String {
        switch(type){
        case 0:
            return labelsSubMaille[subType]
        case 1:
            return labelsSubTop[subType]
        case 2:
            return labelsSubPants[subType]
        default:
            return ""
        }
        
    }
}

extension TypeViewController : CameraOverlayViewDelegate {
    func CameraOverlayViewResult(resultCapture: [String: AnyObject]) {
        var dal = ClothesDAL()
        let clotheId = NSUUID().UUIDString
        dal.save(clotheId, partnerId: resultCapture["clothe_partnerid"] as! NSNumber, partnerName: resultCapture["clothe_partnerName"] as! String, type: resultCapture["clothe_type"] as! String, subType: resultCapture["clothe_subtype"] as! String, name: resultCapture["clothe_name"] as! String, isUnis: resultCapture["clothe_isUnis"] as! Bool, pattern: resultCapture["clothe_pattern"] as! String, cut: resultCapture["clothe_cut"] as! String, image: resultCapture["clothe_image"] as! NSData, colors: resultCapture["clothe_colors"] as! String)
        //self.collection = clothesDAL.fetch(self.type)
        //self.collectionView.reloadData()
        
        DressTimeService.saveClothe(SharedData.sharedInstance.currentUserId!, clotheId: clotheId, dressingCompleted: { (succeeded: Bool, msg: [[String: AnyObject]]) -> () in
            //println(msg)
        })
    }
}

extension TypeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 150, height: 90) // The size of one cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let frame : CGRect = self.view.frame
        let margin  = (frame.width - 90 * 3) / 6.0
        return UIEdgeInsetsMake(10, margin, 10, margin) // margin between cells
    }

}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}