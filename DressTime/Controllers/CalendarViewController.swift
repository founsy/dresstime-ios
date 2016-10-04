//
//  CalendarViewController.swift
//  DressTime
//  
//  Created by Fab on 13/02/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit

class CalendarViewController: DTViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageBackground: UIImageView!
    
    var cellIdentifier = "ClotheCalendarCell"
    var cellNoClotheIdentifier = "NoClotheCalendarCell"
    var numberCellIdentifier = "NumberCalendarCell"
    var tableData = [Outfit]()
    var gradient : CAGradientLayer?
    var imageBg : UIImage?
    
    var currentIndex: NSIndexPath?
    
    private var creationDate:NSDate?
    private var arrayOfDate = [[NSDate]]()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.classNameAnalytics = "Calendar"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "ClotheCalendarCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        tableView.registerNib(UINib(nibName: "NoClotheCalendarCell", bundle:nil), forCellReuseIdentifier: self.cellNoClotheIdentifier)
        
        
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerNib(UINib(nibName: "NumberCalendarCell", bundle:nil), forCellWithReuseIdentifier: self.numberCellIdentifier)
        collectionView.remembersLastFocusedIndexPath = true

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let weather = SharedData.sharedInstance.currentWeater {
            self.imageBackground.image = UIImage(named: WeatherHelper.changeBackgroundDependingWeatherCondition(weather.code == nil ? 800 : weather.code!))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        DressTimeService().GetOutfitsPutOn { (isSuccess, object) -> Void in
            if (isSuccess){
                for item in object.arrayValue {
                self.tableData.append(Outfit(json: item))
                }
                self.getIndex()
                self.tableView.reloadData()
                self.collectionView.reloadData()
                self.collectionView(self.collectionView, didSelectItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
                self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: true)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Error.SaveOutfit, object: nil)
            }
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showOutfitMaker"){
            let vc = segue.destinationViewController as! OutfitViewController
            vc.creationDate = self.creationDate
            if (self.currentIndex != nil) {
                if let outfit = self.getOutfit(arrayOfDate[currentIndex!.section][currentIndex!.row].toS("MM-dd-YY")!) {
                    vc.currentOutfits = outfit.clothes
                }
            }
        }
    }
    
    private func getIndex(){
        var lastMonth = NSDate() - 15.day
        var previousDate: NSDate?
        
        self.arrayOfDate = [[NSDate]]()
        var index = -1
        while (NSDate() > lastMonth){
            if (previousDate == nil || previousDate!.toS("MMM")! != lastMonth.toS("MMM")!) {
                arrayOfDate.append([NSDate]())
                index = index + 1
            }
            arrayOfDate[index].append(lastMonth)
            previousDate = lastMonth
            lastMonth = lastMonth + 1.day
        }
        for i in 0..<arrayOfDate.count {
            arrayOfDate[i] = arrayOfDate[i].reverse()
        }
        arrayOfDate = arrayOfDate.reverse()
    }
    
    private func createOutfitView(outfit: Outfit, cell: ClotheCalendarCell){
        var j = 1
        if (outfit.clothes.count > 0){
            //Be sure the order of clothes are ok
            outfit.orderOutfit()
            let dal = ClothesDAL()
     
            for i in (outfit.clothes.count-1).stride(through: 0, by: -1) {
                let clothe_id = outfit.clothes[i].clothe_id
                if let clothe = dal.fetch(clothe_id) {
                    let width:CGFloat = cell.containerView.frame.width
                    var height:CGFloat = CGFloat(cell.containerView.frame.height/CGFloat(outfit.clothes.count))
                    let x:CGFloat = 0
                    var y:CGFloat = 0
                    
                    if (outfit.clothes.count == 1){
                        height = cell.containerView.frame.height
                    } else if (outfit.clothes.count == 2){
                        height = 186.6
                    } else {
                        height = 143.3
                    }
                    
                    if (i == 0){
                        y = 0
                    } else if (outfit.clothes.count-1 == i) {
                        y = cell.containerView.frame.height - height
                    } else {
                        y = cell.containerView.frame.height - (height * CGFloat(j)) + (height/2.0)
                    }
                    
                    let rect = CGRectMake(x, y, width, height)
                    j += 1
                    
                    cell.createClotheView(clothe, rect: rect)
                }
            }
        }
    }
    
    private func getOutfit(date: String) -> Outfit? {
        for item in self.tableData {
            let outfitdate = item.updatedDate!.toS("MM-dd-YY")
            if (outfitdate == date){
                return item
            }
        }
        return nil
    }
    
    private func didEndScrolling(scrollView: UIScrollView){
        var center = scrollView.frame.origin;
        center.x += scrollView.frame.size.width / 2;
        center.y += scrollView.frame.size.height / 2;
        center = scrollView.convertPoint(center, fromView: scrollView.superview)
        
        if (scrollView == tableView){
            let rect = CGRect(x: center.x - 50, y: center.y - 50, width: 100, height: 100)
            if let array = self.tableView.indexPathsForRowsInRect(rect) {
                let indexPath = array[0]
                print(indexPath.section)
                self.collectionView.selectItemAtIndexPath(NSIndexPath(forItem: indexPath.row, inSection: indexPath.section), animated: true, scrollPosition: UICollectionViewScrollPosition.CenteredVertically)
                self.collectionView.deselectItemAtIndexPath(NSIndexPath(forItem: currentIndex!.row, inSection: indexPath.section), animated: true)
                self.collectionView(self.collectionView, didDeselectItemAtIndexPath: NSIndexPath(forItem: currentIndex!.row, inSection: indexPath.section))
                self.collectionView(self.collectionView, didSelectItemAtIndexPath: NSIndexPath(forItem: indexPath.row, inSection: indexPath.section))
            }
        }
    }
}

extension CalendarViewController : UITableViewDataSource , UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.arrayOfDate.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfDate[section].count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath
        self.performSegueWithIdentifier("showOutfitMaker", sender: self)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let outfit = getOutfit(self.arrayOfDate[indexPath.section][indexPath.row].toS("MM-dd-YY")!) {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ClotheCalendarCell
            cell.removeOldImages()
            createOutfitView(outfit, cell: cell)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.cellNoClotheIdentifier, forIndexPath: indexPath) as! NoClotheCalendarCell
            cell.indexPath = indexPath
            cell.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
         if let _ = getOutfit(arrayOfDate[indexPath.section][indexPath.row].toS("MM-dd-YY")!) {
            return 305.0
         } else {
            return 277.0
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.didEndScrolling(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.didEndScrolling(scrollView)
        }
    }

}

extension CalendarViewController: NoClotheCalendarCellDelegate {
    func noClotheCalendarCell(noClotheCalendarCell: NoClotheCalendarCell, didCreateOutfit item: NSIndexPath) {
        //Save the date when the user want to create the outfit
        self.creationDate = self.arrayOfDate[item.section][item.row]
        //Outfit Maker ViewController
        self.performSegueWithIdentifier("showOutfitMaker", sender: self)
    }
}

extension CalendarViewController : UICollectionViewDataSource {    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //Return number of section corresponding of number of month
        return self.arrayOfDate.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfDate[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.numberCellIdentifier, forIndexPath: indexPath) as! NumberCalendarCell
        cell.label.text = self.arrayOfDate[indexPath.section][indexPath.row].toS("dd")//toS("MMM dd")
        if (currentIndex?.section == indexPath.section && currentIndex?.row == indexPath.row){
            cell.selectedStyle()
        } else {
            cell.unselectedStyle()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath)
            if let textField = cell.subviews[0] as? UILabel {
                let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                                          NSFontAttributeName : UIFont.boldSystemFontOfSize(17)]
                textField.attributedText = NSAttributedString(string: self.arrayOfDate[indexPath.section][0].toS("MMM")!, attributes: underlineAttribute)
            }
            return cell
        } else {
            return UICollectionReusableView()
        }
    }
    
}

extension CalendarViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let index = self.currentIndex {
            self.collectionView.deselectItemAtIndexPath(NSIndexPath(forItem: index.row, inSection: index.section), animated: true)
            self.collectionView(self.collectionView, didDeselectItemAtIndexPath: NSIndexPath(forItem: index.row, inSection: index.section))
        }
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? NumberCalendarCell
        cell?.selectedStyle()
        currentIndex = indexPath
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: indexPath.row, inSection: indexPath.section), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)

    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? NumberCalendarCell
        cell?.unselectedStyle()
        currentIndex = nil
        
    }
}

