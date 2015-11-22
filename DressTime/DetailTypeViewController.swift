//
//  DetailTypeViewController.swift
//  DressTime
//
//  Created by Fab on 04/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class DetailTypeViewController: UIViewController {
    private let cellIdentifier : String = "ClotheTableCell"
    private var clothesList: [Clothe]?
    private var currentSection = -1
    private let height:CGFloat = 190.0
    
    var typeClothe: String?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleNav: UINavigationItem!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var emptyViewButton: UIButton!
    @IBOutlet weak var emptyViewImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "ClotheTableCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        
        tableView!.delegate = self
        tableView!.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        //TODO Manage Localization
        titleNav.title = "My \(typeClothe!.uppercaseString)!"
        
        emptyViewButton.layer.cornerRadius = 10.0
        emptyViewButton.layer.borderColor = UIColor.whiteColor().CGColor
        emptyViewButton.layer.borderWidth = 1.0
        emptyViewImage.image = UIImage(named: "underwearIcon\(SharedData.sharedInstance.sexe!.uppercaseString)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initData()
        tableView.reloadData()
        if (clothesList?.count > 0){
            self.emptyView.hidden = true
            self.tableView.hidden = false
        } else {
            self.emptyView.hidden = false
            self.tableView.hidden = true
        }

        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Profile", comment: ""), style: .Plain, target: nil, action: nil)
    }
    
    func initData(){
        let dal = ClothesDAL()
        if let type = self.typeClothe {
            self.clothesList = dal.fetch(type: type)
        }
    }
    
    private func openEditClotheView(indexPath: NSIndexPath){
        self.currentSection = indexPath.row
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.performSegueWithIdentifier("detailClothe", sender: self)
        })
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    private func deleteClothe(indexPath: NSIndexPath){
        if let currentClothe = self.clothesList?[indexPath.row] {
            DressingService().DeleteClothe(currentClothe.clothe_id, completion: { (isSuccess, object) -> Void in
                print("Clothe deleted")
                ClothesDAL().delete(currentClothe)
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
        }    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailClothe") {
            let navigationController = segue.destinationViewController as! UINavigationController
            if let detailController = navigationController.viewControllers[0] as? DetailClotheViewController {
                detailController.currentClothe =  self.clothesList![self.currentSection]
            }

        }
    }
}

extension DetailTypeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: NSLocalizedString("Edit", comment: "")) { (action, indexPath) -> Void in
                self.openEditClotheView(indexPath)
        }
        editAction.backgroundColor = UIColor.blueColor()
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: NSLocalizedString("Delete", comment: "")) { (action, indexPath) -> Void in
            self.deleteClothe(indexPath)
        }
        return [deleteAction, editAction]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.openEditClotheView(indexPath)
    }
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ClotheTableViewCell
    
        let clothe = self.clothesList![indexPath.row]
        if let image = UIImage(data: clothe.clothe_image) {
            cell.clotheImageView.image = image.imageWithImage(480.0)
        }
        cell.initFavoriteButton(clothe.clothe_favorite)
        cell.clothe = clothe
        cell.layer.shadowOffset = CGSizeMake(3, 6);
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowRadius = 8;
        cell.layer.shadowOpacity = 0.75;
        cell.clotheImageView.clipsToBounds = true
        
        //Remove edge insets to have full width separtor line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell;
    }
}

