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
    
    var cellIdentifier = "ClotheCalendarCell"
    var cellNoClotheIdentifier = "NoClotheCalendarCell"
    var numberCellIdentifier = "NumberCalendarCell"
    var tableData = [Outfit]()
    var indexOfNumbers = [NSDate]()
    
    var cellSelected = -1
    var currentIndex: NSIndexPath?
    
    private var creationDate:NSDate?
    
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
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.drsPaleBlueColor().CGColor, UIColor.drsBlueColor().CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
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
                self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Error.SaveOutfit, object: nil)
            }
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showOutfitMaker"){
            let vc = segue.destinationViewController as! OutfitViewController
            vc.creationDate = self.creationDate
        }
    }
    
    private func getIndex(){
        var lastMonth = NSDate() - 15.day
        self.indexOfNumbers = [NSDate]()
        while(NSDate() > lastMonth){
            indexOfNumbers.append(lastMonth)
            lastMonth = lastMonth + 1.day
        }
        indexOfNumbers = indexOfNumbers.reverse()
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
                self.collectionView.selectItemAtIndexPath(NSIndexPath(forItem: indexPath.section, inSection: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.CenteredVertically)
                self.collectionView.deselectItemAtIndexPath(NSIndexPath(forItem: self.cellSelected, inSection: 0), animated: true)
                self.collectionView(self.collectionView, didDeselectItemAtIndexPath: NSIndexPath(forItem: self.cellSelected, inSection: 0))
                self.collectionView(self.collectionView, didSelectItemAtIndexPath: NSIndexPath(forItem: indexPath.section, inSection: 0))
            }
        }
    }
}

extension CalendarViewController : UITableViewDataSource , UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return indexOfNumbers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let outfit = getOutfit(indexOfNumbers[indexPath.section].toS("MM-dd-YY")!) {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ClotheCalendarCell
            cell.removeOldImages()
            createOutfitView(outfit, cell: cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.cellNoClotheIdentifier, forIndexPath: indexPath) as! NoClotheCalendarCell
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
         if let _ = getOutfit(indexOfNumbers[indexPath.section].toS("MM-dd-YY")!) {
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
        self.creationDate = self.indexOfNumbers[item.section]
        //Outfit Maker ViewController
        self.performSegueWithIdentifier("showOutfitMaker", sender: self)
    }
}

extension CalendarViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return indexOfNumbers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.numberCellIdentifier, forIndexPath: indexPath) as! NumberCalendarCell
        cell.label.text = self.indexOfNumbers[indexPath.row].toS("MMM dd")
        if (cellSelected == indexPath.row){
            cell.roundView.layer.cornerRadius = 20.0
            cell.roundView.layer.borderWidth = 1.0
            cell.roundView.layer.borderColor = UIColor.whiteColor().CGColor
            cell.roundView.layer.masksToBounds = true

        
        } else {
            cell.roundView.layer.cornerRadius = 0.0
            cell.roundView.layer.borderWidth = 0.0
            cell.roundView.layer.borderColor = UIColor.whiteColor().CGColor
            cell.roundView.layer.masksToBounds = true
        }
        
        return cell
    }
    
}

extension CalendarViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.collectionView.deselectItemAtIndexPath(NSIndexPath(forItem: self.cellSelected, inSection: 0), animated: true)
        self.collectionView(self.collectionView, didDeselectItemAtIndexPath: NSIndexPath(forItem: self.cellSelected, inSection: 0))
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? NumberCalendarCell
        cell?.roundView.layer.cornerRadius = 20.0
        cell?.roundView.layer.borderWidth = 1.0
        cell?.roundView.layer.borderColor = UIColor.whiteColor().CGColor
        cell?.roundView.layer.masksToBounds = true
        cellSelected = indexPath.row
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 0, inSection: indexPath.row), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)

    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? NumberCalendarCell
        cell?.roundView.layer.cornerRadius = 0.0
        cell?.roundView.layer.borderWidth = 0.0
        cell?.roundView.layer.borderColor = UIColor.whiteColor().CGColor
        cell?.roundView.layer.masksToBounds = true
        cellSelected = -1
        
    }
}

struct TimeInterval {
    var interval: Int
    var unit: TimeIntervalUnit
    
    init(interval: Int, unit: TimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

enum TimeIntervalUnit {
    case Seconds, Minutes, Hours, Days, Months, Years
    
    func dateComponents(interval: Int) -> NSDateComponents {
        let components:NSDateComponents = NSDateComponents()
        
        switch (self) {
        case .Seconds:
            components.second = interval
        case .Minutes:
            components.minute = interval
        case .Days:
            components.day = interval
        case .Months:
            components.month = interval
        case .Years:
            components.year = interval
        default:
            components.day = interval
        }
        return components
    }
}

func - (let left:NSDate, let right:TimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = right.unit.dateComponents(-right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: [])!
}

func + (let left:NSDate, let right:TimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = right.unit.dateComponents(+right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: [])!
}

func < (let left:NSDate, let right: NSDate) -> Bool {
    let result:NSComparisonResult = left.compare(right)
    var isEarlier = false
    if (result == NSComparisonResult.OrderedAscending) {
        isEarlier = true
    }
    return isEarlier
}

func > (let left:NSDate, let right: NSDate) -> Bool {
    let result:NSComparisonResult = left.compare(right)
    var isEarlier = false
    if (result == NSComparisonResult.OrderedDescending) {
        isEarlier = true
    }
    return isEarlier
}

extension Int {
    var months: TimeInterval {
        return TimeInterval(interval: self, unit: TimeIntervalUnit.Months);
    }
    
    var day: TimeInterval {
        return TimeInterval(interval: self, unit: TimeIntervalUnit.Days);
    }
    
    var days: NSTimeInterval {
        let DAY_IN_SECONDS = 60 * 60 * 24
        let days:Double = Double(DAY_IN_SECONDS) * Double(self)
        return days
    }
}

extension NSDate {
    func toS(let format:String) -> String? {
        let formatter:NSDateFormatter = NSDateFormatter()
        //formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}