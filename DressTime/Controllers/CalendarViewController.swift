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
    
    var currentIndex: IndexPath?
    
    fileprivate var creationDate:Date?
    fileprivate var arrayOfDate = [[Date]]()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.classNameAnalytics = "Calendar"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ClotheCalendarCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        tableView.register(UINib(nibName: "NoClotheCalendarCell", bundle:nil), forCellReuseIdentifier: self.cellNoClotheIdentifier)
        
        
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "NumberCalendarCell", bundle:nil), forCellWithReuseIdentifier: self.numberCellIdentifier)
        collectionView.remembersLastFocusedIndexPath = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let weather = SharedData.sharedInstance.currentWeater {
            self.imageBackground.image = UIImage(named: WeatherHelper.changeBackgroundDependingWeatherCondition(weather.code == nil ? 800 : weather.code!))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DressTimeService().GetOutfitsPutOn { (isSuccess, object) -> Void in
            if (isSuccess){
                for item in object.arrayValue {
                    self.tableData.append(Outfit(json: item))
                }
                self.calculateLast30Days()
                self.tableView.reloadData()
                self.collectionView.reloadData()
                self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: true)
            } else {
                NotificationCenter.default.post(name: Notifications.Error.SaveOutfit, object: nil)
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showOutfitMaker"){
            let vc = segue.destination as! OutfitViewController
            vc.creationDate = self.creationDate
            if (self.currentIndex != nil) {
                if let outfit = self.getOutfit(arrayOfDate[(currentIndex! as NSIndexPath).section][(currentIndex! as NSIndexPath).row].toS("MM-dd-YY")!) {
                    vc.currentOutfits = outfit.clothes
                }
            }
        }
    }
    
    fileprivate func calculateLast30Days(){
        var lastMonth = Date() - 15.day
        var previousDate: Date?
        
        self.arrayOfDate = [[Date]]()
        var index = -1
        while (lowerDate(left: Date(), right: lastMonth)){
            if (previousDate == nil || previousDate!.toS("MMM")! != lastMonth.toS("MMM")!) {
                arrayOfDate.append([Date]())
                index = index + 1
            }
            arrayOfDate[index].append(lastMonth)
            previousDate = lastMonth
            lastMonth = lastMonth + 1.day
        }
        for i in 0..<arrayOfDate.count {
            arrayOfDate[i] = arrayOfDate[i].reversed()
        }
        arrayOfDate = arrayOfDate.reversed()
    }
    
    fileprivate func createOutfitView(_ outfit: Outfit, cell: ClotheCalendarCell){
        var j = 1
        if (outfit.clothes.count > 0){
            //Be sure the order of clothes are ok
            outfit.orderOutfit()
            let dal = ClothesDAL()
     
            for i in stride(from: (outfit.clothes.count-1), through: 0, by: -1) {
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
                    
                    let rect = CGRect(x: x, y: y, width: width, height: height)
                    j += 1
                    
                    cell.createClotheView(clothe, rect: rect)
                }
            }
        }
    }
    
    fileprivate func getOutfit(_ date: String) -> Outfit? {
        for item in self.tableData {
            let outfitdate = item.updatedDate!.toS("MM-dd-YY")
            if (outfitdate == date){
                return item
            }
        }
        return nil
    }
    
    fileprivate func didEndScrolling(_ scrollView: UIScrollView){
        var center = scrollView.frame.origin;
        center.x += scrollView.frame.size.width / 2;
        center.y += scrollView.frame.size.height / 2;
        center = scrollView.convert(center, from: scrollView.superview)
        
        if (scrollView == tableView){
            let rect = CGRect(x: center.x - 50, y: center.y - 50, width: 100, height: 100)
            if let array = self.tableView.indexPathsForRows(in: rect) {
                let indexPath = array[0]
                self.collectionView.selectItem(at: IndexPath(item: indexPath.row, section: indexPath.section), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
                self.collectionView.deselectItem(at: IndexPath(item: currentIndex!.row, section: indexPath.section), animated: true)
                self.collectionView(self.collectionView, didDeselectItemAt: IndexPath(item: currentIndex!.row, section: indexPath.section))
                self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: indexPath.row, section: indexPath.section))
            }
        }
    }
}

extension CalendarViewController : UITableViewDataSource , UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrayOfDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfDate[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentIndex = indexPath
        self.performSegue(withIdentifier: "showOutfitMaker", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let outfit = getOutfit(self.arrayOfDate[indexPath.section][indexPath.row].toS("MM-dd-YY")!) {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! ClotheCalendarCell
            cell.removeOldImages()
            createOutfitView(outfit, cell: cell)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellNoClotheIdentifier, for: indexPath) as! NoClotheCalendarCell
            cell.indexPath = indexPath
            cell.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         if let _ = getOutfit(arrayOfDate[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].toS("MM-dd-YY")!) {
            return 305.0
         } else {
            return 277.0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.didEndScrolling(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.didEndScrolling(scrollView)
        }
    }

}

extension CalendarViewController: NoClotheCalendarCellDelegate {
    func noClotheCalendarCell(_ noClotheCalendarCell: NoClotheCalendarCell, didCreateOutfit item: IndexPath) {
        //Save the date when the user want to create the outfit
        self.creationDate = self.arrayOfDate[(item as NSIndexPath).section][(item as NSIndexPath).row]
        //Outfit Maker ViewController
        self.performSegue(withIdentifier: "showOutfitMaker", sender: self)
    }
}

extension CalendarViewController : UICollectionViewDataSource {    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //Return number of section corresponding of number of month
        return self.arrayOfDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfDate[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.numberCellIdentifier, for: indexPath) as! NumberCalendarCell
        cell.label.text = self.arrayOfDate[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].toS("dd")//toS("MMM dd")
        if ((currentIndex as NSIndexPath?)?.section == (indexPath as NSIndexPath).section && (currentIndex as NSIndexPath?)?.row == (indexPath as NSIndexPath).row){
            cell.selectedStyle()
        } else {
            cell.unselectedStyle()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
            if let textField = cell.subviews[0] as? UILabel {
                let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
                                          NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17)] as [String : Any]
                textField.attributedText = NSAttributedString(string: self.arrayOfDate[(indexPath as NSIndexPath).section][0].toS("MMM")!, attributes: underlineAttribute)
            }
            return cell
        } else {
            return UICollectionReusableView()
        }
    }
    
}

extension CalendarViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let index = self.currentIndex {
            self.collectionView.deselectItem(at: IndexPath(item: (index as NSIndexPath).row, section: (index as NSIndexPath).section), animated: true)
            self.collectionView(self.collectionView, didDeselectItemAt: IndexPath(item: (index as NSIndexPath).row, section: (index as NSIndexPath).section))
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as? NumberCalendarCell
        cell?.selectedStyle()
        currentIndex = indexPath
        self.tableView.scrollToRow(at: IndexPath(item: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section), at: UITableViewScrollPosition.middle, animated: true)

    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? NumberCalendarCell
        cell?.unselectedStyle()
        currentIndex = nil
        
    }
}

