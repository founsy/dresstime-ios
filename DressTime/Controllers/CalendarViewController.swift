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
        
        if let weather = SharedData.sharedInstance.currentWeater {
            self.imageBackground.image = UIImage(named: WeatherHelper.changeBackgroundDependingWeatherCondition(weather.code == nil ? 800 : weather.code!))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadOutfitHistory()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showOutfitMaker"){
            let vc = segue.destination as! OutfitViewController
            
            if (self.currentIndex != nil) {
                vc.creationDate = self.arrayOfDate[currentIndex!.section][currentIndex!.row]
                if let outfit = self.getOutfit(vc.creationDate.toS("MM-dd-YY")!) {
                    vc.currentOutfits = outfit.clothes
                }
            }
        }
    }
    
    fileprivate func loadOutfitHistory(){
        let dressTimeClient = DressTimeClient()
        dressTimeClient.fetchOutfitPutOnWithCompletion { (result) in
            switch result {
            case .success(let json):
                for item in json.arrayValue {
                    self.tableData.append(Outfit(json: item))
                }
                self.calculateLast30Days()
                self.tableView.reloadData()
                self.collectionView.reloadData()
                self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
            case .failure(let error):
                print("\(#function) Error : \(error)")
                NotificationCenter.default.post(name: Notifications.Error.GetOutfit, object: error)
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
    
    fileprivate func getOutfit(_ date: String) -> Outfit? {
        for item in self.tableData {
            let outfitdate = item.updatedDate!.toS("MM-dd-YY")
            if (outfitdate == date){
                return item
            }
        }
        return nil
    }
    
    fileprivate func replaceOutfit(_ date: String, outfit: Outfit) {
        for (index, item) in self.tableData.enumerated() {
            let outfitdate = item.updatedDate!.toS("MM-dd-YY")
            if (outfitdate == date){
                self.tableData[index] = outfit
            }
        }
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

// MARK : OutfitViewControllerDelegate
extension CalendarViewController: OutfitViewControllerDelegate {
    func outfitViewControllerDelegate(_ outfitViewController: OutfitViewController, didModifyOutfit outfit: Outfit) {
        replaceOutfit(outfit.updatedDate!.toS("MM-dd-YY")!, outfit: outfit)
        self.tableView.reloadData()
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
            cell.createOutfitView(outfit)
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
         if let _ = getOutfit(arrayOfDate[indexPath.section][indexPath.row].toS("MM-dd-YY")!) {
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
        self.creationDate = self.arrayOfDate[item.section][item.row]
        self.currentIndex = item
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
            self.collectionView.deselectItem(at: IndexPath(item: index.row, section: index.section), animated: true)
            self.collectionView(self.collectionView, didDeselectItemAt: IndexPath(item: index.row, section: index.section))
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as? NumberCalendarCell
        cell?.selectedStyle()
        currentIndex = indexPath
        self.tableView.scrollToRow(at: IndexPath(item: indexPath.row, section: indexPath.section), at: UITableViewScrollPosition.middle, animated: true)

    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? NumberCalendarCell
        cell?.unselectedStyle()
        currentIndex = nil
        
    }
}

