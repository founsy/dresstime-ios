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
    fileprivate var type = [String]()
    var countType:Array<String>?
    
    fileprivate var typeColtheSelected: String?
    fileprivate var currentClotheOpenSelected: Int?
    fileprivate var headerView: UIView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var buttonAddClothe: UIButton!
    @IBOutlet weak var buttonStyle: UIButton!
    @IBOutlet weak var profilButton: UIButton!
    @IBOutlet weak var styleLabel: UILabel!
    
    fileprivate var kTableHeaderHeight:CGFloat = 300.0
    
    @IBAction func onStyleTapped(_ sender: AnyObject) {
        //self.performSegueWithIdentifier("showStyle", sender: self)
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        if let initialViewController = storyboard.instantiateViewController(withIdentifier: "SelectStyleViewController") as? SelectStyleViewController {
            initialViewController.currentUserId = SharedData.sharedInstance.currentUserId
            self.navigationController?.pushViewController(initialViewController, animated: true)
        }
        
    }
    
    @IBAction func onProfilPictureTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    @IBAction func onAddClotheTapped(_ sender: AnyObject) {
        self.currentClotheOpenSelected = nil
        self.performSegue(withIdentifier: "AddClothe", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(ProfilViewController.longPressedHandle(_:)))
        longPressedGesture.minimumPressDuration = 1.0
        
        self.tableView.addGestureRecognizer(longPressedGesture)
        self.tableView.register(UINib(nibName: "TypeCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        
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
        
        profilButton.layer.shadowColor = UIColor.black.cgColor
        profilButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        profilButton.layer.shadowOpacity = 0.50
        profilButton.layer.shadowRadius = 4
        profilButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
        profilButton.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
        profilButton.imageView?.contentMode = .scaleToFill
        profilButton.layer.cornerRadius = 47.5
        profilButton.clipsToBounds = true
        self.view.bringSubview(toFront: self.profilButton)
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        updateHeaderView()
        
        self.type = SharedData.sharedInstance.getType(SharedData.sharedInstance.sexe!)
        initData()
        if let profil_image = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!)?.picture{
            profilButton.setImage(UIImage(data: profil_image), for: UIControlState())
        } else {
            profilButton.setImage(UIImage(named: "profile\(SharedData.sharedInstance.sexe!.uppercased())"), for: UIControlState())
        }
        
        backgroundImage.image = UIImage(named: "BackgroundHeader\(SharedData.sharedInstance.sexe!.uppercased())")
        
        
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Wardrobe", comment: ""), style: .plain, target: nil, action: nil)
        UIApplication.shared.isStatusBarHidden = false // for status bar hide
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        OneSignal.defaultClient().sendTag("page", value: "Profil")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.alpha = 1.0
        
    }
    
    
    
    fileprivate func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if  tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
        if (tableView.contentOffset.y > -260){
            navigationController?.navigationBar.alpha = (CGFloat(abs(tableView.contentOffset.y))/260.0-0.5) > 0.3 ? (CGFloat(abs(tableView.contentOffset.y))/250.0-0.5) : 0
        } else {
            navigationController?.navigationBar.alpha = 1.0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DetailsClothes"){
            let targetVC = segue.destination as! DetailTypeViewController
            targetVC.typeClothe = [self.typeColtheSelected!]
            targetVC.viewMode = ViewMode.dressing
        } else if (segue.identifier == "AddClothe"){
            let navController = segue.destination as! UINavigationController
            let targetVC = navController.topViewController as! TypeViewController
            if let typeClothe = self.currentClotheOpenSelected {
                targetVC.openItem(typeClothe)
            }
        } /*else if (segue.identifier == "showStyle"){
            let targetVC = segue.destinationViewController as! RegisterStyleViewController
            targetVC.currentUserId = SharedData.sharedInstance.currentUserId
        } */
        
    }
    
    func longPressedHandle(_ gestureRecognizer: UILongPressGestureRecognizer){
        let point = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        if (indexPath == nil) {
            NSLog("long press on table view but not on a row");
        } else if (gestureRecognizer.state == UIGestureRecognizerState.began) {
            if let cell = self.tableView.cellForRow(at: indexPath!) as? TypeCell {
                cell.viewLongPress.isHidden = false
            }
        } else {
            print(gestureRecognizer.state)
        }
    }

    
    fileprivate func initData() {
        var totalClothe = 0
        let dal = ClothesDAL()
        countType = Array<String>()
        for i in 0...self.type.count-1 {
            let typeCell = self.type[i].lowercased()
            let count = dal.fetch(type: typeCell).count
            totalClothe = totalClothe + count
            countType?.append("\(count)")
        }
        self.tableView.reloadData()
    }
}


extension ProfilViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.typeColtheSelected = self.type[(indexPath as NSIndexPath).row].lowercased()
        self.performSegue(withIdentifier: "DetailsClothes", sender: self)
    }
}

extension ProfilViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.type.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! TypeCell
        cell.removeAllSubviews()
        let typeCell = self.type[(indexPath as NSIndexPath).row]
        cell.delegate = self
        cell.currentType = typeCell
        cell.number = Int(self.countType![(indexPath as NSIndexPath).row])!
        if ((indexPath as NSIndexPath).row % 2 == 0){
           cell.addViews(false)
        } else {
            cell.addViews(true)
        }
        
        //Remove edge insets to have full width separtor line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
}

extension ProfilViewController: TypeCellDelegate {
    func typeCell(_ typeCell: TypeCell, didSelectType indexPath: IndexPath) {
        self.currentClotheOpenSelected = (indexPath as NSIndexPath).row
        self.performSegue(withIdentifier: "AddClothe", sender: self)
    }
}
