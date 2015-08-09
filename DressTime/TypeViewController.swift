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
    
    private var currentSection = 0
    private let collectionCellWidth = 114
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayForBool = ["0","0", "0"]
        sectionTitleArray = ["Maille","Top", "Pants"]
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
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
}

extension TypeViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitleArray.count
    }
    
    func calculateCollectionViewHeight() -> CGFloat {
        let cellHeight = 100.0
        
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

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("willDisplayCell \(indexPath.row)")
        var currentCell = cell as! TypeTableViewCell
        currentCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: indexPath.row)
    
        if (arrayForBool.objectAtIndex(indexPath.row).boolValue as Bool){
            currentCell.bgImage.image = UIImage(named: "\(bgType[indexPath.row])Full")
            currentCell.collectionWidth = self.tableView.bounds.width
            currentCell.showCollectionView()
        } else {
            var height = self.tableView.bounds.height;
        
            //Resize cell
            currentCell.contentView.frame = CGRectMake(0, 0, tableView.frame.size.width, round(height*0.33333))
            currentCell.bgImage.image = UIImage(named: bgType[indexPath.row])
            currentCell.hideCollectionView()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        NSLog("cellForRowAtIndexPath \(indexPath.row)")
        var cell = self.tableView.dequeueReusableCellWithIdentifier(kCellType, forIndexPath: indexPath) as! TypeTableViewCell
        cell.data = getData(self.currentSection)
    
        return cell
    }
}

extension TypeViewController : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        var collectionCell = cell as! CustomSubTypeViewCell
        
        if ((indexPath.row%2) == 0){
            collectionCell = addRightBorder(collectionCell)
        }
        var count:Int = 0
        if (collectionView.numberOfItemsInSection(0)%2 == 0){
            count = (collectionView.numberOfItemsInSection(0)/2)-1
        } else {
            count = (collectionView.numberOfItemsInSection(0)/2)
            
        }
        let currentNb:Int = indexPath.row/2
        if (currentNb < count){
            collectionCell = addBottomBorder(collectionCell)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellReuse, forIndexPath: indexPath) as! CustomSubTypeViewCell
        cell.label.text = getData(self.currentSection)![indexPath.row]
        cell.contentView.viewWithTag(100)?.removeFromSuperview()
        cell.contentView.viewWithTag(101)?.removeFromSuperview()

        return cell
    }
    
    func addRightBorder(cell: CustomSubTypeViewCell) -> CustomSubTypeViewCell {
        var mainViewSize = cell.bounds.size
        var borderWidth:CGFloat = 1.0
        var borderColor = UIColor.whiteColor()
        var rightView = UIView(frame: CGRectMake(CGFloat(mainViewSize.width - borderWidth), 0, borderWidth, mainViewSize.height))
        rightView.tag = 100
        rightView.backgroundColor = UIColor.whiteColor()
        
        cell.contentView.addSubview(rightView)
        
        return cell
    }
    
    func addBottomBorder(cell: CustomSubTypeViewCell) -> CustomSubTypeViewCell {
        var mainViewSize = cell.bounds.size
        var borderWidth:CGFloat = 1.0
        var borderColor = UIColor.whiteColor()
        var rightView = UIView(frame: CGRectMake(0, CGFloat(mainViewSize.height - borderWidth), mainViewSize.width, borderWidth))
        rightView.tag = 101
        rightView.backgroundColor = UIColor.whiteColor()
        
        cell.contentView.addSubview(rightView)
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1  // Number of section
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let datas = getData(self.currentSection) {
            return datas.count
        } else {
            return 0
        }
    }
    
    func getData(section: Int) -> [String]?{
        switch(section){
        case 0:
            return self.labelsSubMaille
        case 1:
            return self.labelsSubTop
        case 2:
            return self.labelsSubPants
        default:
            return nil
        }
    }
}

extension TypeViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        var cell = collectionView.cellForItemAtIndexPath(indexPath)
        NSLog("Nbr subviews:  \(cell?.contentView.subviews.count)")
        NSLog("\(indexPath.row)")
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
        return getData(type)![subType]
        
    }
}

extension TypeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.collectionCellWidth, height: 90) // The size of one cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
}

extension TypeViewController : CameraOverlayViewDelegate {
    
    func CameraOverlayViewResult(resultCapture: [String: AnyObject]) {
        var dal = ClothesDAL()
        let clotheId = NSUUID().UUIDString
        dal.save(clotheId, partnerId: resultCapture["clothe_partnerid"] as! NSNumber, partnerName: resultCapture["clothe_partnerName"] as! String, type: resultCapture["clothe_type"] as! String, subType: resultCapture["clothe_subtype"] as! String, name: resultCapture["clothe_name"] as! String, isUnis: resultCapture["clothe_isUnis"] as! Bool, pattern: resultCapture["clothe_pattern"] as! String, cut: resultCapture["clothe_cut"] as! String, image: resultCapture["clothe_image"] as! NSData, colors: resultCapture["clothe_colors"] as! String)

        DressTimeService.saveClothe(SharedData.sharedInstance.currentUserId!, clotheId: clotheId, dressingCompleted: { (succeeded: Bool, msg: [[String: AnyObject]]) -> () in
            //println(msg)
        })
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