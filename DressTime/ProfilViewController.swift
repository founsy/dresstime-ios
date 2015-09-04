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

    @IBAction func addNewClothe(sender: AnyObject) {
        self.performSegueWithIdentifier("AddClothe", sender: self)
    }
    
    @IBAction func onMailleTap(sender: AnyObject) {
        self.typeColtheSelected = "maille"
        self.performSegueWithIdentifier("DetailsClothes", sender: self)
    }
    @IBAction func onTopTap(sender: AnyObject) {
        self.typeColtheSelected = "top"
        self.performSegueWithIdentifier("DetailsClothes", sender: self)

    }
    @IBAction func onBottomTap(sender: AnyObject) {
        self.typeColtheSelected = "pants"
        self.performSegueWithIdentifier("DetailsClothes", sender: self)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clothesDAL = ClothesDAL()
        let countMaille = self.clothesDAL?.fetch(type: "maille").count
        let countTop = self.clothesDAL?.fetch(type: "top").count
        let countBottom = self.clothesDAL?.fetch(type: "pants").count
        
        numberMailleText.text = "\(countMaille!)"
        numberTopText.text = "\(countTop!)"
        numberBottomText.text = "\(countBottom!)"
        
        workButton.layer.cornerRadius = 17.5
        workButton.layer.borderColor = UIColor.whiteColor().CGColor
        workButton.layer.borderWidth = 1.0
        
        partyButton.layer.cornerRadius = 17.5
        partyButton.layer.borderColor = UIColor.whiteColor().CGColor
        partyButton.layer.borderWidth = 1.0
        
        relaxButton.layer.cornerRadius = 17.5
        relaxButton.layer.borderColor = UIColor.whiteColor().CGColor
        relaxButton.layer.borderWidth = 1.0
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "DetailsClothes"){
            let targetVC = segue.destinationViewController as! DetailTypeViewController
            targetVC.typeClothe = self.typeColtheSelected
        }
    }
}