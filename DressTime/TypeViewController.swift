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
    
    private let types = SharedData.sharedInstance.getType(SharedData.sharedInstance.sexe!)
    private var subTypes = Array<Array<String>>()
    
    var sectionContentDict : NSMutableDictionary = NSMutableDictionary()
    var arrayForBool = NSMutableArray()

    let bgType = ["TypeMaille", "TypeTop", "TypePants", "TypeDress"]
    
    private let kCellReuse : String = "SubTypeCell"
    private let cellTypeIdentifier : String = "TypeTableCell"
    
    private var currentSection = 0
    private var subTypeSelected = 0
    private let collectionCellWidth = 114
    private var isLoaded = false
    private var isOpenSectionRequired = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        tableView.registerNib(UINib(nibName: "TypeTableCell", bundle:nil), forCellReuseIdentifier: self.cellTypeIdentifier)
        if (arrayForBool.count == 0){
            initSubType()
        }
        
        if (isOpenSectionRequired){
            for (var i = 0; i < arrayForBool.count; i++) {
                let collapsed = arrayForBool[i].boolValue!
                if (collapsed){
                    let path:NSIndexPath = NSIndexPath(forItem: i, inSection: 0)
                    self.tableView.reloadRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Fade)
                    self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                    isOpenSectionRequired = false
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true);
        UIApplication.sharedApplication().statusBarHidden=true; // for status bar hide
    }
    
    private func initSubType(){
        self.subTypes = Array<Array<String>>()
        for (var i = 0; i < self.types.count; i++){
            self.subTypes.append(SharedData.sharedInstance.getSubType(self.types[i]))
            self.arrayForBool.addObject("0")
        }
        
        
    }

    @IBAction func onClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func openItem(typeIndex: Int){
        if (arrayForBool.count == 0){
            initSubType()
        }
        let collapsed = arrayForBool[typeIndex].boolValue
        arrayForBool.replaceObjectAtIndex(typeIndex, withObject: !collapsed)
        self.currentSection = typeIndex
        isOpenSectionRequired = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showCapture"){
            let captureController = segue.destinationViewController as! CameraViewController
            captureController.typeClothe = self.types[self.currentSection].lowercaseString
            captureController.subTypeClothe = self.subTypes[self.currentSection][self.subTypeSelected]
        }
    }
}

extension TypeViewController: UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let oldRow = self.currentSection
        self.currentSection = indexPath.row
        
        //Collapse row already opened
        for (var i = 0; i < arrayForBool.count; i++) {
            let collapsed = arrayForBool.objectAtIndex(i).boolValue as Bool
            if (collapsed && i != indexPath.row) {
                arrayForBool.replaceObjectAtIndex(i, withObject: !collapsed)
                let path:NSIndexPath = NSIndexPath(forItem: oldRow, inSection: 0)
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
        return self.types.count
    }
    
    func calculateCollectionViewHeight() -> CGFloat {
        return ceil(CGFloat(self.subTypes[self.currentSection].count)/2.0) * 100.0
    }
   
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //let height = self.tableView.bounds.height - self.navigationController!.navigationBar.frame.height
        
        if (arrayForBool.objectAtIndex(indexPath.row).boolValue as Bool){
            let height = calculateCollectionViewHeight()
            return height > 230.0 ? height : 230.0
        } else {
            return 230.0//round(height*0.33333)
        }

    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let currentCell = cell as! TypeTableViewCell
        
        currentCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: indexPath.row)
    
        if (arrayForBool.objectAtIndex(indexPath.row).boolValue as Bool){
            currentCell.collectionWidth = self.tableView.bounds.width
            currentCell.showCollectionView()
        } else {
            let height = self.tableView.bounds.height;
            //Resize cell
            currentCell.contentView.frame = CGRectMake(0, 0, tableView.frame.size.width, round(height*0.33333))
            currentCell.hideCollectionView()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCellWithIdentifier(cellTypeIdentifier, forIndexPath: indexPath) as! TypeTableViewCell
        cell.bgImageView.image = UIImage(named: "\(bgType[indexPath.row])\(SharedData.sharedInstance.sexe!.uppercaseString)")
        cell.labelTypeText.text = NSLocalizedString(self.types[indexPath.row], comment: "").uppercaseString
        cell.iconImageView.image = UIImage(named: "Type\(self.types[indexPath.row])Icon")
        cell.bgImageView.clipsToBounds = true
        cell.data = self.subTypes[self.currentSection]
        
        //Remove edge insets to have full width separtor line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellReuse, forIndexPath: indexPath) as! CustomSubTypeViewCell
        cell.imgaView.image = UIImage(named: SharedData.sharedInstance.subTypeToImage(self.subTypes[self.currentSection][indexPath.row]))
        cell.label.text = NSLocalizedString(self.subTypes[self.currentSection][indexPath.row], comment: "")
        cell.contentView.viewWithTag(100)?.removeFromSuperview()
        cell.contentView.viewWithTag(101)?.removeFromSuperview()

        return cell
    }
    
    func addRightBorder(cell: CustomSubTypeViewCell) -> CustomSubTypeViewCell {
        let mainViewSize = cell.bounds.size
        let borderWidth:CGFloat = 1.0
        let rightView = UIView(frame: CGRectMake(CGFloat(mainViewSize.width - borderWidth), 0, borderWidth, mainViewSize.height))
        rightView.tag = 100
        rightView.backgroundColor = UIColor.whiteColor()
        
        cell.contentView.addSubview(rightView)
        
        return cell
    }
    
    func addBottomBorder(cell: CustomSubTypeViewCell) -> CustomSubTypeViewCell {
        let mainViewSize = cell.bounds.size
        let borderWidth:CGFloat = 1.0
        let rightView = UIView(frame: CGRectMake(0, CGFloat(mainViewSize.height - borderWidth), mainViewSize.width, borderWidth))
        rightView.tag = 101
        rightView.backgroundColor = UIColor.whiteColor()
        
        cell.contentView.addSubview(rightView)
        
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1  // Number of section
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subTypes[self.currentSection].count
    }
}

extension TypeViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        self.subTypeSelected = indexPath.row
        self.performSegueWithIdentifier("showCapture", sender: self)
    }

    func getSubType(type: Int, subType: Int) -> String {
        return self.subTypes[type][subType]
        
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

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}