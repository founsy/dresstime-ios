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
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension TypeViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        var captureView = CameraOverlayView()
        //captureView.delegate = self
        captureView.typeCloth = "maille"
        
        self.presentViewController(captureView, animated: true, completion: nil)
    }
}

extension TypeViewController: UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
         return sectionTitleArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ABC"
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = self.tableView.bounds.height;
        if (arrayForBool.objectAtIndex(section).boolValue as Bool){
            if let image = UIImage(named: "\(bgType[section])Full") {
                return image.size.height
            } else {
                return height
            }
        } else {
            return height*0.3
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(arrayForBool .objectAtIndex(indexPath.section).boolValue == true){
            return 100
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?  {
        //Header View
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 50))
        var image = UIImage(named: bgType[section])
        if (arrayForBool.objectAtIndex(section).boolValue as Bool){
            image = UIImage(named: "\(bgType[section])Full")
        }
        var imageView = UIImageView(image: image)
        imageView.contentMode = UIViewContentMode.ScaleToFill
        headerView.tag = section
        headerView.addSubview(imageView)
        
        if (arrayForBool.objectAtIndex(section).boolValue as Bool){
            var layout = UICollectionViewFlowLayout()
            // Collection
            self.collectionView.delegate = self     // delegate  :  UICollectionViewDelegate
            self.collectionView.dataSource = self   // datasource  : UICollectionViewDataSource
            self.collectionView.backgroundColor = UIColor.clearColor()
            if let img = image {
                self.collectionView.frame = CGRectMake(0, 0, tableView.frame.size.width, img.size.height)
            } else {
                self.collectionView.frame = CGRectMake(0, 0, tableView.frame.size.width, 0)
            }
            // Register parts(header and cell
            var customCell = UINib(nibName: "SubTypeCell", bundle: nil)
            self.collectionView.registerNib(customCell, forCellWithReuseIdentifier: kCellReuse)
            
            headerView.addSubview(self.collectionView)
            
        } else {
            let headerString = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-10, height: 30)) as UILabel
            headerString.text = sectionTitleArray.objectAtIndex(section) as? String
            headerView .addSubview(headerString)
        }
        let headerTapped = UITapGestureRecognizer (target: self, action:"sectionHeaderTapped:")
        headerView .addGestureRecognizer(headerTapped)
        
        return headerView
    }
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        println("Tapping working")
        println(recognizer.view?.tag)
        
        var indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        currentSection = indexPath.row
        
        if (indexPath.row == 0) {
            
            var collapsed = arrayForBool.objectAtIndex(indexPath.section).boolValue
            collapsed       = !collapsed;
            
            arrayForBool .replaceObjectAtIndex(indexPath.section, withObject: collapsed)
            //reload specific section animated
            var range = NSMakeRange(indexPath.section, 1)
            var sectionToReload = NSIndexSet(indexesInRange: range)
            self.tableView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let CellIdentifier = "Cell"
        var cell :UITableViewCell
        cell = self.tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        
        var manyCells : Bool = arrayForBool .objectAtIndex(indexPath.section).boolValue
        
        if (!manyCells) {
            //  cell.textLabel.text = @"click to enlarge";
        }
        else{
            var content = sectionContentDict .valueForKey(sectionTitleArray.objectAtIndex(indexPath.section) as! String) as! NSArray
            cell.textLabel?.text = content .objectAtIndex(indexPath.row) as? String
            cell.backgroundColor = UIColor .greenColor()
        }
        
        return cell
    }
}

extension TypeViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell : CustomSubTypeViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellReuse, forIndexPath: indexPath) as! CustomSubTypeViewCell
        println(labelsSubMaille[indexPath.row])
        switch(self.currentSection) {
            case 0:
                cell.label.text = labelsSubMaille[indexPath.row]
            default:
                cell.label.text = ""
            break
        }


        return cell    // Create UICollectionViewCell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1  // Number of section
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var res = 0
        switch(self.currentSection) {
            case 0:
                res = labelsSubMaille.count // Number of cell per section(section 0)
                break
        default:
            res = 0
            break
        }
        return res
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        // Select operation
        println("tapped on collection")
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