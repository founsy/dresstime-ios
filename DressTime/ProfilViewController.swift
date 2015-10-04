//
//  NewProfilViewController.swift
//  DressTime
//
//  Created by Fab on 30/09/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ProfilViewController: UIViewController {
    let cellIdentifier = "profilTypeCell"
    var type = ["Maille", "Top", "Pants"]
    var countType:Array<String>?
    
    private var typeColtheSelected: String?
    private var currentClotheOpenSelected: Int?

    
    @IBOutlet weak var numberClothes: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonAddClothe: UIButton!
    
    @IBAction func onProfilPictureTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showSettings", sender: self)
    }
    @IBAction func onAddClotheTapped(sender: AnyObject) {
        self.currentClotheOpenSelected = nil
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: "longPressedHandle:")
        longPressedGesture.minimumPressDuration = 1.0
        //longPressedGesture.delegate = self
        tableView.addGestureRecognizer(longPressedGesture)
        tableView.registerNib(UINib(nibName: "TypeCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        
        tableView!.delegate = self
        tableView!.dataSource = self
        buttonAddClothe.layer.cornerRadius = 17.5
        
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        initData()
        //resetLongPressed()
        clearNavBar()
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
        for (var i = 0; i < type.count; i++){
            let typeCell = type[i].lowercaseString
            let count = dal.fetch(type: typeCell).count
            totalClothe = totalClothe + count
            countType?.append("\(count)")
        }
        self.numberClothes.text = "\(totalClothe) Clothes"
    }
    
    private func setValueProfil(){
        let profilDal = ProfilsDAL()
    
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            self.nameLabel.text = user.name
        }
    }
    
    private func clearNavBar(){
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        bar.tintColor = UIColor.whiteColor()
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.clearColor()]
    }
}

extension ProfilViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.typeColtheSelected = self.type[indexPath.row].lowercaseString
        self.performSegueWithIdentifier("DetailsClothes", sender: self)
    }
}

extension ProfilViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.type.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! TypeCell
        let typeCell = self.type[indexPath.row]
        cell.backgroundImage.image = UIImage(named: "Background\(typeCell)")
        cell.longPressLabel.text = "Add \(typeCell)"
        cell.viewLongPress.hidden = true
        cell.delegate = self
        cell.indexPath = indexPath
        if (indexPath.row % 2 == 0){
            cell.leftLabel.hidden = true
            cell.leftLabelName.hidden = true
            cell.rightLabel.hidden = false
            cell.rightLabelName.hidden = false
            cell.rightLabel.text = self.countType![indexPath.row]
            cell.rightLabelName.text = typeCell
        } else {
            cell.leftLabel.hidden = false
            cell.leftLabelName.hidden = false
            cell.rightLabel.hidden = true
            cell.rightLabelName.hidden = true
            cell.leftLabel.text = self.countType![indexPath.row]
            cell.leftLabelName.text = typeCell
        }
        return cell
    }
}

extension ProfilViewController: TypeCellDelegate {
    func onAddTypedTapped(indexPath: NSIndexPath) {
        self.currentClotheOpenSelected = indexPath.row
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
}