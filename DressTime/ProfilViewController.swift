//
//  NewProfilViewController.swift
//  DressTime
//
//  Created by Fab on 30/09/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ProfilViewController: UITableViewController {
    let cellIdentifier = "profilTypeCell"
    private var type = [String]()
    var countType:Array<String>?
    
    private var typeColtheSelected: String?
    private var currentClotheOpenSelected: Int?
    private var headerView: UIView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var numberClothes: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buttonAddClothe: UIButton!
    @IBOutlet weak var profilButton: UIButton!
    
    private var kTableHeaderHeight:CGFloat = 390.0
    
    @IBAction func onStyleTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showStyle", sender: self)
    }
    
    @IBAction func onProfilPictureTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showSettings", sender: self)
    }
    
    @IBAction func onAddClotheTapped(sender: AnyObject) {
        self.currentClotheOpenSelected = nil
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: "longPressedHandle:")
        longPressedGesture.minimumPressDuration = 1.0
        
        self.tableView.addGestureRecognizer(longPressedGesture)
        self.tableView.registerNib(UINib(nibName: "TypeCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        headerView = self.tableView.tableHeaderView
        self.tableView.tableHeaderView = nil
        self.tableView.addSubview(headerView)
        self.tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        self.tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        updateHeaderView()
        
        buttonAddClothe.layer.cornerRadius = 20.0
        
        profilButton.layer.shadowColor = UIColor.blackColor().CGColor
        profilButton.layer.shadowOffset = CGSizeMake(0, 1)
        profilButton.layer.shadowOpacity = 0.50
        profilButton.layer.shadowRadius = 4
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        self.type = SharedData.sharedInstance.getType(SharedData.sharedInstance.sexe!)
        initData()
        setValueProfil()
        
        profilButton.setImage(UIImage(named: "profile\(SharedData.sharedInstance.sexe!.uppercaseString)"), forState: .Normal)
        backgroundImage.image = UIImage(named: "BackgroundHeader\(SharedData.sharedInstance.sexe!.uppercaseString)")
        
        
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("PROFILE", comment: ""), style: .Plain, target: nil, action: nil)
        UIApplication.sharedApplication().statusBarHidden = false // for status bar hide
        
    }
    
    private func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if  tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "DetailsClothes"){
            let targetVC = segue.destinationViewController as! DetailTypeViewController
            targetVC.typeClothe = self.typeColtheSelected
        } else if (segue.identifier == "AddClothe"){
            let navController = segue.destinationViewController as! UINavigationController
            let targetVC = navController.topViewController as! TypeViewController
            if let typeClothe = self.currentClotheOpenSelected {
                targetVC.openItem(typeClothe)
            }
        } else if (segue.identifier == "showStyle"){
            let targetVC = segue.destinationViewController as! RegisterStyleViewController
            targetVC.currentUserId = SharedData.sharedInstance.currentUserId
        }
        
    }
    
    func longPressedHandle(gestureRecognizer: UILongPressGestureRecognizer){
        let point = gestureRecognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(point)
        if (indexPath == nil) {
            NSLog("long press on table view but not on a row");
        } else if (gestureRecognizer.state == UIGestureRecognizerState.Began) {
           print(indexPath!.row)
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? TypeCell {
                cell.viewLongPress.hidden = false
            }
        } else {
            print(gestureRecognizer.state)
        }
    }

    
    private func initData() {
        var totalClothe = 0
        let dal = ClothesDAL()
        countType = Array<String>()
        for (var i = 0; i < self.type.count; i++){
            let typeCell = self.type[i].lowercaseString
            let count = dal.fetch(type: typeCell).count
            totalClothe = totalClothe + count
            countType?.append("\(count)")
        }
        self.numberClothes.text = "\(totalClothe)"
        self.tableView.reloadData()
    }
    
    private func setValueProfil(){
        let profilDal = ProfilsDAL()
    
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            self.nameLabel.text = user.name
        }
    }
}


extension ProfilViewController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.typeColtheSelected = self.type[indexPath.row].lowercaseString
        self.performSegueWithIdentifier("DetailsClothes", sender: self)
    }
}

extension ProfilViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.type.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! TypeCell
        let typeCell = self.type[indexPath.row]
        cell.backgroundImage.image = UIImage(named: "Background\(typeCell)\(SharedData.sharedInstance.sexe!.uppercaseString)")
        cell.longPressLabel.text = "Add \(NSLocalizedString(typeCell, comment: ""))"
        cell.viewLongPress.hidden = true
        cell.delegate = self
        cell.indexPath = indexPath
        if (indexPath.row % 2 == 0){
            cell.leftLabel.hidden = true
            cell.leftLabelName.hidden = true
            cell.rightLabel.hidden = false
            cell.rightLabelName.hidden = false
            cell.rightLabel.text = self.countType![indexPath.row]
            cell.rightLabelName.text = NSLocalizedString(typeCell, comment: "").uppercaseString
        } else {
            cell.leftLabel.hidden = false
            cell.leftLabelName.hidden = false
            cell.rightLabel.hidden = true
            cell.rightLabelName.hidden = true
            cell.leftLabel.text = self.countType![indexPath.row]
            cell.leftLabelName.text = NSLocalizedString(typeCell, comment: "").uppercaseString
        }
        
        //Remove edge insets to have full width separtor line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell
    }
}

extension ProfilViewController: TypeCellDelegate {
    func onAddTypedTapped(indexPath: NSIndexPath) {
        self.currentClotheOpenSelected = indexPath.row
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
}