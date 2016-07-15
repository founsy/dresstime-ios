//
//  OutfitsViewController.swift
//  DressTime
//
//  Created by Fab on 09/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol OutfitViewControllerDelegate {

    func outfitViewControllerDelegate(outfitViewController: OutfitViewController, didModifyOutfit outfit: Outfit)
}


class OutfitViewController: DTViewController {
    private let cellIdentifier : String = "ClotheTableCell"
    private let dal = ClothesDAL()
    private var currentClothe: Clothe?
    private var typeToOpen: [String]?
    private var indexPathToAnimate : Int?
    private var isEditingMode = false
    
    private var confirmationView: ConfirmSave?
    
    var outfitObject: Outfit?
    var currentOutfits = [ClotheModel]()
    var delegate: OutfitViewControllerDelegate?
    var creationDate : NSDate?
    var imageName : UIImage?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dressupButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var onEditTapped: UIBarButtonItem!
    @IBAction func onEditTapped(sender: AnyObject) {
        isEditingMode = !isEditingMode
        if (isEditingMode){
            onEditTapped.title = "Cancel" //TODO Translate
        } else {
             onEditTapped.title = "Edit" //TODO Translate
        }
        tableView.reloadData()
    }
    
    @IBAction func onDressUpTapped(sender: AnyObject) {
        self.outfitObject?.isPutOn = true
        
        if (outfitObject == nil) {
            outfitObject = Outfit(clothes: self.currentOutfits, updatedDate: self.creationDate!, isSuggestion: false, isPutOn: true)
        }
        
        
        var isModify = false
        if (currentOutfits.count == outfitObject!.clothes.count) {
            for i in 0..<currentOutfits.count {
                isModify = isModify || (currentOutfits[i].clothe_id != outfitObject?.clothes[i].clothe_id)
            }
        } else {
            isModify = true
        }
        
        if (isModify){
            self.outfitObject?.clothes = currentOutfits
            self.outfitObject?.orderOutfit()
            self.outfitObject?.isSuggestion = !isModify
        }
        
        if let date = self.creationDate {
            self.outfitObject?.updatedDate = date
        }
        
        let dressSvc = DressTimeService()
        dressSvc.SaveOutfit(self.outfitObject!) { (isSuccess) -> Void in
            print(isSuccess)
            if (isSuccess){
                self.delegate?.outfitViewControllerDelegate(self, didModifyOutfit: self.outfitObject!)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Error.SaveOutfit, object: nil)
            }
        }
        
        self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
            self.confirmationView?.alpha = 1
            self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            }, completion: { (isFinish) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.confirmationView?.alpha = 0
                    self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                    }, completion: { (finish) -> Void in
                         self.navigationController?.popViewControllerAnimated(true)
                })
        })
    }

    override func viewDidLoad() {
        self.hideTabBar = true
        super.viewDidLoad()
        self.classNameAnalytics = "Outfit View"
        self.navigationItem.title = "Outfit" //TODO Translate
        
        tableView.registerNib(UINib(nibName: "ClotheTableCell", bundle:nil), forCellReuseIdentifier: ClotheTableViewCell.cellIdentifier)
        ActivityLoader.shared.showProgressView(view)
        
        dressupButton.layer.cornerRadius = 20.0
        dressupButton.layer.shadowOffset = CGSizeMake(0, 1);
        dressupButton.layer.shadowColor = UIColor.blackColor().CGColor
        dressupButton.layer.shadowRadius = 5;
        dressupButton.layer.shadowOpacity = 0.5;
    }
    
    override func viewWillAppear(animated: Bool) {
        if !((self.tabBarController?.tabBar.hidden)!) {
            self.tabBarController?.tabBar.hidden = true
            UIApplication.sharedApplication().statusBarHidden = false
        }
        super.viewWillAppear(animated)
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Outfit", comment: ""), style: .Plain, target: nil, action: nil)
        self.backgroundImageView.image = self.imageName
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.delegate = self
        tableView.dataSource = self
        
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
        } else if (segue.identifier == "dressingList") {
            if let detailController = segue.destinationViewController as? DetailTypeViewController {
                detailController.typeClothe =  self.typeToOpen
                detailController.clotheToChange = self.currentClothe
                detailController.isNeedAnimatedFirstElem = true
                detailController.viewMode = ViewMode.SelectClothe
                detailController.delegate = self
            }
        }
    }
}

extension OutfitViewController: ClotheTableViewCellDelegate {
    func removeItem(item: Clothe) -> Void {
        //Remove clohes
        var index = 0
        for i in 0..<self.currentOutfits.count {
            if currentOutfits[i].clothe_id == item.clothe_id {  // note: === not ==
                index = i
                break
            }
        }
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        currentOutfits.removeAtIndex(index)
        
        // use the UITableView to animate the removal of this row
        tableView.beginUpdates()
        let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Fade)
        tableView.endUpdates()
        tableView.reloadData()
        if (self.currentOutfits.count == 0) {
            onEditTapped.title = "Edit"
            isEditingMode = false
        }
    }
    
    func changeItem(item: Clothe) -> Void {
        //Open dressing details
        self.currentClothe = item
        self.typeToOpen = [item.clothe_type]
        self.performSegueWithIdentifier("dressingList", sender: self)
    }
    
    func detailItem(item: Clothe) {
        self.currentClothe = item
        self.performSegueWithIdentifier("detailClothe", sender: self)

    }
    
    func selectItem(item: Clothe) -> Void {
    
    }
}

extension OutfitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (SharedData.sharedInstance.sexe == "M" && self.currentOutfits.count != 3)
         || (SharedData.sharedInstance.sexe == "F" && self.currentOutfits.count != 4) {
            return 100.0
        }
        return 0.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let view = UIView.loadFromNibNamed("HeaderOutfitView") as? HeaderOutfitView {
            view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            view.delegate = self
            view.setNeedsLayout()
            view.layoutIfNeeded()
            return view
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 220.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.currentOutfits.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ClotheTableViewCell.cellIdentifier, forIndexPath: indexPath) as! ClotheTableViewCell
        if let clothe = dal.fetch(self.currentOutfits[indexPath.row].clothe_id) {
            cell.clotheImageView.image = clothe.getImage().imageWithImage(480.0)
            cell.initFavoriteButton(clothe.clothe_favorite)
            cell.clothe = clothe
            cell.clotheImageView.clipsToBounds = true
            cell.delegate = self
            cell.viewMode = ViewMode.OutfitView
            cell.delayTime = 0.3 * Double(indexPath.row)
            cell.isEditingMode = self.isEditingMode
            
            
            //Remove edge insets to have full width separtor line
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            if (indexPathToAnimate == indexPath.row) {
                let centerPoint = CGPointMake((cell.mouvingCard.frame.width + (cell.mouvingCard.frame.width * 3/4)), cell.mouvingCard.center.y)
                cell.mouvingCard.center = centerPoint
                UIView.animateWithDuration(0.4, animations: {
                    cell.mouvingCard.center = cell.contentView.center
                    }, completion: {
                        (value: Bool) in
                        self.indexPathToAnimate = nil
                })
            }
        }
        return cell
    }
}

extension OutfitViewController: HeaderOutfitViewDelegate {
    func headerOutfitView(didSelectedAdd : Bool) {
        //Dress + Bottom -> Maille ou Top
        //Dress -> Maille ou Top
        //Top + Bottom -> Maille
        //Top + Dress -> Maille
        //Maille + Dress -> Top
        //Maille + Bottom -> Top
        
        var isTop = false, isMaille = false, isBottom = false, isDress = false
        for index in 0..<self.currentOutfits.count {
            isTop = isTop || self.currentOutfits[index].clothe_type == ClotheType.top.rawValue
            isMaille = isMaille || self.currentOutfits[index].clothe_type == ClotheType.maille.rawValue
            isBottom = isBottom || self.currentOutfits[index].clothe_type == ClotheType.pants.rawValue
            isDress = isDress || self.currentOutfits[index].clothe_type == ClotheType.dress.rawValue
        }
       
        self.typeToOpen = [String]()
        if (!isMaille) {
            self.typeToOpen?.append(ClotheType.maille.rawValue)
        } else if (!isTop){
            self.typeToOpen?.append(ClotheType.top.rawValue)
        } else if (!isBottom) {
            self.typeToOpen?.append(ClotheType.pants.rawValue)
        } else if (!isDress && SharedData.sharedInstance.sexe! == "F") {
            self.typeToOpen?.append(ClotheType.dress.rawValue)
        }
        if (typeToOpen!.count == 0){
            typeToOpen = nil
        }
        self.performSegueWithIdentifier("dressingList", sender: self)
    }
}

extension OutfitViewController: DetailTypeViewControllerDelegate {
    func detailTypeViewController(selectedItem : Clothe) {
        print("Add Item")
        var isAdded = false
        for index in 0..<self.currentOutfits.count {
            if (self.currentOutfits[index].clothe_type == selectedItem.clothe_type){
                self.currentOutfits[index] = ClotheModel(clothe: selectedItem)
                isAdded = true
                break
            }
        }
        if (!isAdded){
            self.currentOutfits.append(ClotheModel(clothe: selectedItem))
        }
        let outfit = Outfit(clothes: self.currentOutfits, updatedDate: NSDate(), isSuggestion: false, isPutOn: false)
        outfit.orderOutfit()
        self.currentOutfits = outfit.clothes
        for i in 0..<outfit.clothes.count {
            if (outfit.clothes[i].clothe_id == selectedItem.clothe_id){
                indexPathToAnimate = i
            }
        }
        self.tableView.reloadData()
    }
}

class SegueFromLeft: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.sourceViewController
        let dst: UIViewController = self.destinationViewController
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.3
        transition.timingFunction = timeFunc
        transition.type = kCATransitionFromBottom
        //transition.subtype = kCATransitionFromRight
        src.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
    
}