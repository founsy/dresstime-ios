//
//  ProfilViewController.swift
//  DressTime
//
//  Created by Fab on 04/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ProfilViewController: UIViewController {
    private var clothesDAL:ClothesDAL?
    private var typeColtheSelected: String?
    private var currentClotheOpenSelected: Int?
    
    @IBOutlet weak var mailleView: UIView!
    @IBOutlet weak var mailleImageView: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var numberMailleText: UILabel!
    @IBOutlet weak var numberTopText: UILabel!
    @IBOutlet weak var numberBottomText: UILabel!
    @IBOutlet weak var profilImageView: UIImageView!
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var partyButton: UIButton!
    @IBOutlet weak var relaxButton: UIButton!

    @IBOutlet weak var normalMailleView: UIView!
    @IBOutlet weak var tapLongMailleView: UIView!
    
    @IBOutlet weak var normalTopView: UIView!
    @IBOutlet weak var tapLongTopView: UIView!
    
    @IBOutlet weak var normalBottomView: UIView!
    @IBOutlet weak var tapLongBottomView: UIView!
    
    @IBAction func addNewClothe(sender: AnyObject) {
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
    
    func tapType(normalView: UIView, tapLongView: UIView, type: String){
        if (!normalView.hidden){
            self.typeColtheSelected = type
            self.performSegueWithIdentifier("DetailsClothes", sender: self)
        } else {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                normalView.hidden = false
                tapLongView.hidden = true
            })
        }
    }
    
    func longPress(normalView: UIView, tapLongView: UIView){
        if (tapLongView.hidden){
            UIView.animateWithDuration(0.2, animations: { () -> Void in
               tapLongView.hidden = false
                normalView.hidden = true
            })
        }
    }
    
    func resetLongPressed(){
        normalMailleView.hidden = false
        normalTopView.hidden = false
        normalBottomView.hidden = false
        
        tapLongMailleView.hidden = true
        tapLongTopView.hidden = true
        tapLongBottomView.hidden = true
    }
    
    @IBAction func onMailleTap(sender: AnyObject) {
        tapType(normalMailleView, tapLongView: tapLongMailleView, type: "maille")
    }
    
    @IBAction func MaillelongPressed(sender: UILongPressGestureRecognizer){
        longPress(normalMailleView, tapLongView: tapLongMailleView)
    }
    
    @IBAction func onTopTap(sender: AnyObject) {
        tapType(normalTopView, tapLongView: tapLongTopView, type: "top")
    }
    
    @IBAction func ToplongPressed(sender: UILongPressGestureRecognizer){
        longPress(normalTopView, tapLongView: tapLongTopView)
    }
    
    @IBAction func onBottomTap(sender: AnyObject) {
        tapType(normalBottomView, tapLongView: tapLongBottomView, type: "pants")
    }
    
    @IBAction func BottomlongPressed(sender: UILongPressGestureRecognizer){
        longPress(normalBottomView, tapLongView: tapLongBottomView)
    }
    
    @IBAction func addClothe(sender: UIButton) {
        self.currentClotheOpenSelected = sender.tag
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clothesDAL = ClothesDAL()
        initData()
        workButton.layer.cornerRadius = 17.5
        workButton.layer.borderColor = UIColor.whiteColor().CGColor
        workButton.layer.borderWidth = 1.0
        
        partyButton.layer.cornerRadius = 17.5
        partyButton.layer.borderColor = UIColor.whiteColor().CGColor
        partyButton.layer.borderWidth = 1.0
        
        relaxButton.layer.cornerRadius = 17.5
        relaxButton.layer.borderColor = UIColor.whiteColor().CGColor
        relaxButton.layer.borderWidth = 1.0
        
        addProfilPicture()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initData()
        resetLongPressed()
    }
    
    private func addProfilPicture(){
        var buttonContainer = UIView(frame: CGRectMake(0, 5, 60, 60))
        buttonContainer.backgroundColor = UIColor.clearColor()
        var button =  UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.frame = CGRectMake(0,0,60,60)
        button.setBackgroundImage(UIImage(named: "profile_img"), forState: UIControlState.Normal)
        button.addTarget(self, action: "settingProfilTap", forControlEvents: UIControlEvents.TouchUpInside)
        buttonContainer.addSubview(button)
        self.navigationItem.titleView = button
        
        
    }
    
    func settingProfilTap(){
        self.performSegueWithIdentifier("showSettings", sender: self)
    }
    
    func initData() {
        let countMaille = self.clothesDAL?.fetch(type: "maille").count
        let countTop = self.clothesDAL?.fetch(type: "top").count
        let countBottom = self.clothesDAL?.fetch(type: "pants").count
        numberMailleText.text = "\(countMaille!)"
        numberTopText.text = "\(countTop!)"
        numberBottomText.text = "\(countBottom!)"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "DetailsClothes"){
            let targetVC = segue.destinationViewController as! DetailTypeViewController
            targetVC.typeClothe = self.typeColtheSelected
        } else if (segue.identifier == "AddClothe"){
            let navController = segue.destinationViewController as! UINavigationController
            let targetVC = navController.topViewController as! TypeViewController
            if let typeClothe = self.currentClotheOpenSelected {
            targetVC.openItem(typeClothe - 1)
            }
        }
    }
}