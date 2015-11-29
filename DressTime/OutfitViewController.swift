//
//  OutfitsViewController.swift
//  DressTime
//
//  Created by Fab on 09/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class OutfitViewController: UIViewController {
    private let cellIdentifier : String = "ClotheTableCell"
    private let dal = ClothesDAL()
    private var currentClothe: Clothe?
    
    private var confirmationView: ConfirmSave?
    
    var currentOutfits: NSArray!
    private var number = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dressupButton: UIButton!
    
    @IBAction func onDressUpTapped(sender: AnyObject) {
        self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
        
        UIView.animateAndChainWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: {
            self.confirmationView?.alpha = 1
            self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            }, completion:  nil).animateWithDuration(0.2, animations: { () -> Void in
                self.confirmationView?.alpha = 0
                self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                }, completion: { (finish) -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                    
            })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ClotheScrollTableCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
       ActivityLoader.shared.showProgressView(view)
        
        dressupButton.layer.cornerRadius = 20.0
        dressupButton.layer.shadowOffset = CGSizeMake(0, 1);
        dressupButton.layer.shadowColor = UIColor.blackColor().CGColor
        dressupButton.layer.shadowRadius = 5;
        dressupButton.layer.shadowOpacity = 0.5;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("HOME", comment: ""), style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView!.delegate = self
        tableView!.dataSource = self

        self.number = self.currentOutfits!.count
        self.tableView.reloadData()
        
        self.confirmationView = NSBundle.mainBundle().loadNibNamed("ConfirmSave", owner: self, options: nil)[0] as? ConfirmSave
        self.confirmationView!.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0 - 50, UIScreen.mainScreen().bounds.size.height/2.0 - 50 - 65, 100, 100)
        self.confirmationView!.alpha = 0
        self.confirmationView!.layer.cornerRadius = 50
        
        self.view.addSubview(self.confirmationView!)
        ActivityLoader.shared.hideProgressView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailClothe") {
            let navigationController = segue.destinationViewController as! UINavigationController
            if let detailController = navigationController.viewControllers[0] as? DetailClotheViewController {
                detailController.currentClothe =  self.currentClothe
            }
        }
    }
}

extension OutfitViewController: ClotheScrollTableCellDelegate {
    func didSelectedClothe(clothe: Clothe){
        self.currentClothe = clothe
        self.performSegueWithIdentifier("detailClothe", sender: self)
    }
}


extension OutfitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height:CGFloat = (tableView.frame.height) / CGFloat(self.currentOutfits.count)
        return height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.number
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ClotheScrollTableCell
        if let outfit = self.currentOutfits[indexPath.row] as? NSDictionary {
            let type = outfit["clothe_type"] as! String
            let clothe_id = outfit["clothe_id"] as! String
            
            let collection = dal.fetch(type: type)
            cell.clotheCollection = collection
            cell.currentOutfit =  dal.fetch(clothe_id)
            cell.numberOfClothesAssos = self.currentOutfits.count
            cell.setupScrollView(cell.contentView.frame.width, height: cell.contentView.frame.height)
            cell.delegate = self
            
            cell.layer.shadowOffset = CGSizeMake(3, 6);
            cell.layer.shadowColor = UIColor.blackColor().CGColor
            cell.layer.shadowRadius = 8;
            cell.layer.shadowOpacity = 0.75;
        }

        return cell
    }
}