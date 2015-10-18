//
//  DetailClotheViewController.swift
//  DressTime
//
//  Created by Fab on 27/09/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class DetailClotheViewController: UIViewController {
    
    var currentClothe: Clothe!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var color1View: UIView!
    @IBOutlet weak var color2View: UIView!
    @IBOutlet weak var color3View: UIView!
    @IBOutlet weak var clotheName: UILabel!
    
    @IBOutlet weak var onTap: UIButton!
    
    @IBAction func onTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCreateOutfitTapped(sender: AnyObject) {
    }
    
    @IBAction func onFavoriteTapped(sender: AnyObject) {
    }
    
    @IBAction func onEditTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showEditView", sender: self)
    }
    
    
    @IBAction func onClickDelete(sender: AnyObject) {
        DressTimeService().DeleteClothe(currentClothe.clothe_id) { (isSuccess, object) -> Void in
            print("Clothe deleted")
            let dal = ClothesDAL()
            dal.delete(self.currentClothe)
            dispatch_sync(dispatch_get_main_queue(), {
                //self.delegate?.onDeleteCloth!()
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        imageView.image = UIImage(data: currentClothe.clothe_image)
        imageView.clipsToBounds = true
        self.viewContainer.layer.cornerRadius = 10.0
        self.viewContainer.layer.masksToBounds = true
        
        self.color1View.layer.cornerRadius = 5.0
        self.color1View.layer.borderWidth = 1.0
        self.color1View.layer.borderColor = UIColor.whiteColor().CGColor
        self.color2View.layer.cornerRadius = 5.0
        self.color2View.layer.borderWidth = 1.0
        self.color2View.layer.borderColor = UIColor.whiteColor().CGColor
        self.color3View.layer.cornerRadius = 5.0
        self.color3View.layer.borderWidth = 1.0
        self.color3View.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.clotheName.text = self.currentClothe.clothe_name
        self.updateColors(currentClothe.clothe_colors)
        
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    func updateColors(colors: String){
        let colors = self.splitHexColor(colors)
        color1View.backgroundColor = UIColor.colorWithHexString(colors[0] as String)
        if (colors.count > 1){
            color2View.backgroundColor = UIColor.colorWithHexString(colors[1] as String)
        }
        if (colors.count > 2){
            color3View.backgroundColor = UIColor.colorWithHexString(colors[2] as String)
        }
    }
    
    private func splitHexColor(colors: String) -> [String]{
        let arrayColors = colors.componentsSeparatedByString(",")
        return arrayColors
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showEditView"){
            let controller = segue.destinationViewController as! CaptureConfirmationViewController
            controller.currentClothe = self.currentClothe
            controller.previousController = self
        }
    }
    
}