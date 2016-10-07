//
//  TypeViewController.swift
//  DressTime
//
//  Created by Fab on 05/08/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class TypeViewController: DTViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let types = SharedData.sharedInstance.getType(SharedData.sharedInstance.sexe!)
    fileprivate var subTypes = Array<Array<String>>()
    
    var sectionContentDict : NSMutableDictionary = NSMutableDictionary()
    var arrayForBool = [Bool]()

    let bgType = ["TypeMaille", "TypeTop", "TypePants", "TypeDress"]
    
    fileprivate let kCellReuse : String = "SubTypeCell"
    fileprivate let cellTypeIdentifier : String = "TypeTableCell"
    
    fileprivate var currentSection = 0
    fileprivate var subTypeSelected = 0
    fileprivate let collectionCellWidth = 114
    fileprivate var isLoaded = false
    fileprivate var isOpenSectionRequired = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "Capture_Type"

        
        tableView.register(UINib(nibName: "TypeTableCell", bundle:nil), forCellReuseIdentifier: self.cellTypeIdentifier)
        if (arrayForBool.count == 0){
            initSubType()
        }
        
        if (isOpenSectionRequired){
            for i in 0...arrayForBool.count-1 {
                let collapsed = (arrayForBool[i] as AnyObject).boolValue!
                if (collapsed){
                    let path:IndexPath = IndexPath(item: i, section: 0)
                    self.tableView.reloadRows(at: [path], with: UITableViewRowAnimation.fade)
                    self.tableView.scrollToRow(at: path, at: UITableViewScrollPosition.top, animated: true)
                    isOpenSectionRequired = false
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        UIApplication.shared.isStatusBarHidden=true // for status bar hide
        self.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.backgroundColor = UIColor.white
        
    }
    
    fileprivate func initSubType(){
        self.subTypes = Array<Array<String>>()
        for i in 0...self.types.count-1 {
            self.subTypes.append(SharedData.sharedInstance.getSubType(self.types[i]))
            self.arrayForBool.append(false)
        }
        
        
    }

    @IBAction func onClose(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openItem(_ typeIndex: Int){
        if (arrayForBool.count == 0){
            initSubType()
        }
        let collapsed = arrayForBool[typeIndex]
        arrayForBool.remove(at: typeIndex)
        arrayForBool.insert(!collapsed, at: typeIndex)
        self.currentSection = typeIndex
        isOpenSectionRequired = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showCapture"){
            let dimensions = [
                "page" : "Capture_Show",    // What type of news is this?
                "data" : "Type \(self.types[self.currentSection].lowercased()) - Subtype \(self.subTypes[self.currentSection][self.subTypeSelected])"
            ]

            OneSignal.defaultClient().sendTags(dimensions)
            let captureController = segue.destination as! CameraViewController
            captureController.typeClothe = self.types[self.currentSection].lowercased()
            captureController.subTypeClothe = self.subTypes[self.currentSection][self.subTypeSelected]
        }
    }
}

extension TypeViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldRow = self.currentSection
        self.currentSection = (indexPath as NSIndexPath).row
        
        //Collapse row already opened
        for i in 0...arrayForBool.count-1 {
            let collapsed = arrayForBool[i]
            if (collapsed && i != (indexPath as NSIndexPath).row) {
                arrayForBool.remove(at: i)
                arrayForBool.insert(!collapsed, at: i)
                let path:IndexPath = IndexPath(item: oldRow, section: 0)
                self.tableView.reloadRows(at: [path], with:UITableViewRowAnimation.fade)
                break
            }
        }
        
        //Open new one
        let collapsed = arrayForBool[indexPath.row]
        arrayForBool.remove(at: indexPath.row)
        arrayForBool.insert(!collapsed, at: indexPath.row)
        
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
    }
}

extension TypeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.types.count
    }
    
    func calculateCollectionViewHeight() -> CGFloat {
        return ceil(CGFloat(self.subTypes[self.currentSection].count)/2.0) * 100.0
    }
   
    @objc(tableView:heightForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.tableView.bounds.height
        
        if arrayForBool[indexPath.row] {
            let height = calculateCollectionViewHeight()
            return height > 230.0 ? height : 230.0
        } else {
            return round(height*0.33333) //230.0
        }

    }

    @objc(tableView:willDisplayCell:forRowAtIndexPath:)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let currentCell = cell as! TypeTableViewCell
        
        currentCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: (indexPath as NSIndexPath).row)
    
        if arrayForBool[indexPath.row]{
            currentCell.collectionWidth = self.tableView.bounds.width
            currentCell.showCollectionView()
        } else {
            let height = self.tableView.bounds.height;
            //Resize cell
            currentCell.contentView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: round(height*0.33333))
            currentCell.hideCollectionView()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellTypeIdentifier, for: indexPath) as! TypeTableViewCell
        cell.bgImageView.image = UIImage(named: "\(bgType[(indexPath as NSIndexPath).row])\(SharedData.sharedInstance.sexe!.uppercased())")
        cell.labelTypeText.text = NSLocalizedString(self.types[(indexPath as NSIndexPath).row], comment: "").uppercased()
        cell.iconImageView.image = UIImage(named: "Type\(self.types[(indexPath as NSIndexPath).row])Icon")
        cell.bgImageView.clipsToBounds = true
        cell.data = self.subTypes[self.currentSection]
        
        //Remove edge insets to have full width separtor line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
}

extension TypeViewController : UICollectionViewDataSource {
    
    @objc(collectionView:willDisplayCell:forItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var collectionCell = cell as! CustomSubTypeViewCell
        
        if (((indexPath as NSIndexPath).row%2) == 0){
            collectionCell = addRightBorder(collectionCell)
        }
        var count:Int = 0
        if (collectionView.numberOfItems(inSection: 0)%2 == 0){
            count = (collectionView.numberOfItems(inSection: 0)/2)-1
        } else {
            count = (collectionView.numberOfItems(inSection: 0)/2)
            
        }
        let currentNb:Int = (indexPath as NSIndexPath).row/2
        if (currentNb < count){
            collectionCell = addBottomBorder(collectionCell)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuse, for: indexPath) as! CustomSubTypeViewCell
        cell.imgaView.image = UIImage(named: SharedData.sharedInstance.subTypeToImage(self.subTypes[self.currentSection][(indexPath as NSIndexPath).row]))
        cell.label.text = NSLocalizedString(self.subTypes[self.currentSection][(indexPath as NSIndexPath).row], comment: "")
        cell.contentView.viewWithTag(100)?.removeFromSuperview()
        cell.contentView.viewWithTag(101)?.removeFromSuperview()

        return cell
    }
    
    func addRightBorder(_ cell: CustomSubTypeViewCell) -> CustomSubTypeViewCell {
        let mainViewSize = cell.bounds.size
        let borderWidth:CGFloat = 1.0
        let rightView = UIView(frame: CGRect(x: CGFloat(mainViewSize.width - borderWidth), y: 0, width: borderWidth, height: mainViewSize.height))
        rightView.tag = 100
        rightView.backgroundColor = UIColor.white
        
        cell.contentView.addSubview(rightView)
        
        return cell
    }
    
    func addBottomBorder(_ cell: CustomSubTypeViewCell) -> CustomSubTypeViewCell {
        let mainViewSize = cell.bounds.size
        let borderWidth:CGFloat = 1.0
        let rightView = UIView(frame: CGRect(x: 0, y: CGFloat(mainViewSize.height - borderWidth), width: mainViewSize.width, height: borderWidth))
        rightView.tag = 101
        rightView.backgroundColor = UIColor.white
        
        cell.contentView.addSubview(rightView)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1  // Number of section
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subTypes[self.currentSection].count
    }
}

extension TypeViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        self.subTypeSelected = (indexPath as NSIndexPath).row
        self.performSegue(withIdentifier: "showCapture", sender: self)
    }

    func getSubType(_ type: Int, subType: Int) -> String {
        return self.subTypes[type][subType]
        
    }
}

extension TypeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionCellWidth, height: 90) // The size of one cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension UIView {
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
