//
//  NewProfilViewController.swift
//  DressTime
//
//  Created by Fab on 30/09/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ProfilViewController: DTTableViewController {
    let cellIdentifier = "profilTypeCell"
    private var type = [String]()
    var countType:Array<String>?
    
    private var typeColtheSelected: String?
    private var currentClotheOpenSelected: Int?
    private var headerView: UIView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var buttonAddClothe: UIButton!
    @IBOutlet weak var buttonStyle: UIButton!
    @IBOutlet weak var profilButton: UIButton!
    @IBOutlet weak var styleLabel: UILabel!
    
    private var kTableHeaderHeight:CGFloat = 300.0
    
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
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(ProfilViewController.longPressedHandle(_:)))
        longPressedGesture.minimumPressDuration = 1.0
        
        self.tableView.addGestureRecognizer(longPressedGesture)
        self.tableView.registerNib(UINib(nibName: "TypeCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        headerView = self.tableView.tableHeaderView
        self.tableView.tableHeaderView = nil
        self.tableView.addSubview(headerView)
        self.tableView.contentInset = UIEdgeInsets(top: (kTableHeaderHeight - 46), left: 0, bottom: 0, right: 0)
        self.tableView.contentOffset = CGPoint(x: 0, y: (-kTableHeaderHeight + 46))
        
        
        buttonAddClothe.layer.cornerRadius = 20.0
        buttonStyle.layer.cornerRadius = 20.0
        if (SharedData.sharedInstance.sexe! == "M") {
            buttonStyle.backgroundColor = UIColor.dressTimeGreen()
            styleLabel.textColor = UIColor.dressTimeGreen()
        } else {
            buttonStyle.backgroundColor = UIColor.dressTimePink()
            styleLabel.textColor = UIColor.dressTimePink()

        }
        
        profilButton.layer.shadowColor = UIColor.blackColor().CGColor
        profilButton.layer.shadowOffset = CGSizeMake(0, 1)
        profilButton.layer.shadowOpacity = 0.50
        profilButton.layer.shadowRadius = 4
        profilButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        profilButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        profilButton.imageView?.contentMode = .ScaleToFill
        profilButton.layer.cornerRadius = 47.5
        profilButton.clipsToBounds = true
        self.view.bringSubviewToFront(self.profilButton)
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        
        updateHeaderView()
        
        self.type = SharedData.sharedInstance.getType(SharedData.sharedInstance.sexe!)
        initData()
        if (SharedData.sharedInstance.currentUserId!.lowercaseString == "alexandre"){
            profilButton.setImage(UIImage(named: "profileAlexandre"), forState: .Normal)
        } else if (SharedData.sharedInstance.currentUserId!.lowercaseString == "juliette"){
            profilButton.setImage(UIImage(named: "profileJuliette"), forState: .Normal)
        } else {
            if let profil_image = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!)?.picture{
                profilButton.setImage(UIImage(data: profil_image), forState: .Normal)
            } else {
                profilButton.setImage(UIImage(named: "profile\(SharedData.sharedInstance.sexe!.uppercaseString)"), forState: .Normal)
            }
        }
        
        backgroundImage.image = UIImage(named: "BackgroundHeader\(SharedData.sharedInstance.sexe!.uppercaseString)")
        
        
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("PROFILE", comment: ""), style: .Plain, target: nil, action: nil)
        UIApplication.sharedApplication().statusBarHidden = false // for status bar hide
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
        OneSignal.defaultClient().sendTag("page", value: "Profil")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.alpha = 1.0
        
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
        if (tableView.contentOffset.y > -260){
            navigationController?.navigationBar.alpha = (CGFloat(abs(tableView.contentOffset.y))/260.0-0.5) > 0.3 ? (CGFloat(abs(tableView.contentOffset.y))/250.0-0.5) : 0
        } else {
            navigationController?.navigationBar.alpha = 1.0
        }
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
        for i in 0...self.type.count-1 {
            let typeCell = self.type[i].lowercaseString
            let count = dal.fetch(type: typeCell).count
            totalClothe = totalClothe + count
            countType?.append("\(count)")
        }
        self.tableView.reloadData()
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
        cell.removeAllSubviews()
        let typeCell = self.type[indexPath.row]
        cell.delegate = self
        cell.currentType = typeCell
        cell.number = Int(self.countType![indexPath.row])!
        if (indexPath.row % 2 == 0){
           cell.addViews(false)
        } else {
            cell.addViews(true)
        }
        
        //Remove edge insets to have full width separtor line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell
    }
}

extension ProfilViewController: TypeCellDelegate {
    func typeCell(typeCell: TypeCell, didSelectType indexPath: NSIndexPath) {
        self.currentClotheOpenSelected = indexPath.row
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
}