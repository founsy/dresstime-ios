//
//  DetailTypeViewController.swift
//  DressTime
//
//  Created by Fab on 04/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol DetailTypeViewControllerDelegate {
    func detailTypeViewController(selectedItem : Clothe)
}

class DetailTypeViewController: DTViewController {
    private var clothesList: [Clothe]?
    private var currentSection = -1
    private let height:CGFloat = 220.0
    
    var isNeedAnimatedFirstElem = false
    var typeClothe: [String]?
    var clotheToChange: Clothe?
    var viewMode: ViewMode?
    var delegate : DetailTypeViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleNav: UINavigationItem!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var emptyViewButton: UIButton!
    @IBOutlet weak var emptyViewImage: UIImageView!
    @IBOutlet weak var buttonCapture: UIButton!
    
    @IBAction func onCaptureTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showCapture", sender: self)
    }
    
    override func viewDidLoad() {
        self.hideTabBar = true
        
        super.viewDidLoad()
        self.classNameAnalytics = "DetailType"
        tableView.registerNib(UINib(nibName: "ClotheTableCell", bundle:nil), forCellReuseIdentifier: ClotheTableViewCell.cellIdentifier)
        
        tableView!.delegate = self
        tableView!.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        //TODO Manage Localization
        var title = ""
        for type in self.typeClothe! {
            title = "\(title) \(NSLocalizedString(type, comment:"").uppercaseString)"
        }
        titleNav.title = "\(NSLocalizedString("detailTypeMyMsg", comment: "")) \(title)!"
        emptyViewLabel.text = NSLocalizedString("detailTypeEmptyMsg", comment: "")
        
        
        emptyViewButton.layer.cornerRadius = 10.0
        emptyViewButton.layer.borderColor = UIColor.whiteColor().CGColor
        emptyViewButton.layer.borderWidth = 1.0
        emptyViewImage.image = UIImage(named: "underwearIcon\(SharedData.sharedInstance.sexe!.uppercaseString)")
        
        self.buttonCapture.layer.cornerRadius = 20.0
        self.buttonCapture.layer.shadowOffset = CGSizeMake(0, 1);
        self.buttonCapture.layer.shadowColor = UIColor.blackColor().CGColor
        self.buttonCapture.layer.shadowRadius = 5;
        self.buttonCapture.layer.shadowOpacity = 0.5;
    }
    
    override func viewWillAppear(animated: Bool) {
      /*  if !((self.tabBarController?.tabBar.hidden)!) {
            self.tabBarController?.tabBar.hidden = true
            UIApplication.sharedApplication().statusBarHidden = false
        } */
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.alpha = 1.0
        
        initData()
        tableView.reloadData()
        if (clothesList?.count > 0){
            self.emptyView.hidden = true
            self.tableView.hidden = false
            self.buttonCapture.hidden = false
        } else {
            self.emptyView.hidden = false
            self.tableView.hidden = true
            self.buttonCapture.hidden = true

        }

        if (viewMode == ViewMode.SelectClothe){
            self.buttonCapture.hidden = true
            titleNav.title = "Select your \(self.typeClothe![0])..."
            
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Outfit"/*NSLocalizedString("detailTypeBackBtn", comment: "") */, style: .Plain, target: nil, action: nil)
        } else {
            self.buttonCapture.hidden = false
            //Remove Title of Back button
            navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("detailTypeBackBtn", comment: ""), style: .Plain, target: nil, action: nil)
        }
    }
    
    func initData(){
        let dal = ClothesDAL()
        if let types = self.typeClothe {
            self.clothesList = [Clothe]()
            for type in types {
                self.clothesList?.appendContentsOf(dal.fetch(type: type))
                if let clothe = clotheToChange {
                    self.clothesList?.sortInPlace { (element1, element2) -> Bool in
                        return element1.clothe_id == clothe.clothe_id
                    }
                }
            }
            
        }
    }
    
    private func openEditClotheView(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.performSegueWithIdentifier("detailClothe", sender: self)
        })
        //self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    private func deleteClothe(indexPath: NSIndexPath){
        if let currentClothe = self.clothesList?[indexPath.row] {
            DressingService().DeleteClothe(currentClothe.clothe_id, completion: { (isSuccess, object) -> Void in
                print("Clothe deleted")
                ClothesDAL().delete(currentClothe)
                NSNotificationCenter.defaultCenter().postNotificationName("ClotheDeletedNotification", object: self, userInfo: ["type": currentClothe.clothe_type])
            })
        }
        self.clothesList!.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        if (clothesList?.count > 0){
            self.emptyView.hidden = true
            self.tableView.hidden = false
        } else {
            self.emptyView.hidden = false
            self.tableView.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailClothe") {
            let navigationController = segue.destinationViewController as! UINavigationController
            if let detailController = navigationController.viewControllers[0] as? DetailClotheViewController {
                detailController.currentClothe =  self.clotheToChange
                detailController.delegate = self
            }
        } else if (segue.identifier == "showCapture"){
            let navController = segue.destinationViewController as! UINavigationController
            let targetVC = navController.topViewController as! TypeViewController
            targetVC.openItem(getTypeClothe(typeClothe![0]))
        }
    }
    
    private func getTypeClothe(typeClothe: String) -> Int {
        switch(typeClothe.lowercaseString){
            case "maille":
                return 0
            case "top":
                return 1
            case "pants":
                return 2
            case "dress":
                return 3
            default:
                return -1
        }
    }
}

extension DetailTypeViewController: ClotheTableViewCellDelegate {
    func selectItem(item: Clothe) -> Void {
        if let mode = self.viewMode where mode != ViewMode.Dressing {
            //Selection
            self.delegate?.detailTypeViewController(item)
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.clotheToChange = item
            self.openEditClotheView()
        }
    }
}

extension DetailTypeViewController: DetailClotheViewControllerDelegate {
    func detailClotheView(detailClotheview : DetailClotheViewController, itemDeleted item: String) {
        self.deleteClothe(NSIndexPath(forRow: self.currentSection, inSection: 0))
    }
}

extension DetailTypeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.height
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let list = self.clothesList {
            return list.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ClotheTableViewCell.cellIdentifier, forIndexPath: indexPath) as! ClotheTableViewCell
    
        let clothe = self.clothesList![indexPath.row]
        cell.clotheImageView.image = clothe.getImage().imageWithImage(480.0)
        cell.initFavoriteButton(clothe.clothe_favorite)
        cell.clothe = clothe
        cell.clotheImageView.clipsToBounds = true
        cell.viewMode = self.viewMode
        cell.delegate = self
        
        //Remove edge insets to have full width separtor line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
       /* if (indexPath.row == 0 && isNeedAnimatedFirstElem) {
            let centerPoint = CGPointMake(-(cell.mouvingCard.frame.width/4), cell.mouvingCard.center.y)
            cell.mouvingCard.center = centerPoint
            UIView.animateWithDuration(0.4, animations: {
                cell.mouvingCard.center = cell.contentView.center
                }, completion: {
                    (value: Bool) in
                    self.isNeedAnimatedFirstElem = false
            })
        } */
        
        return cell;
    }
}

