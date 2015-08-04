//
//  ClotheDetailController.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import UIKit


@objc protocol ClotheDetailControllerDelegate {
    optional func onDeleteCloth()
}

class ClotheDetailController: UIViewController {
    
    var delegate: ClotheDetailControllerDelegate?
    var currentClothe: Clothe!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mainColor: UIView!
    @IBOutlet weak var colorText: UITextView!
    
    @IBAction func onClickDelete(sender: AnyObject) {
        
        DressTimeService.deleteClothe(SharedData.sharedInstance.currentUserId!, clotheId: currentClothe.clothe_id, clotheDelCompleted: { (succeeded, msg) -> () in
            println("Clothe deleted")
            let dal = ClothesDAL()
            dal.delete(self.currentClothe)
            dispatch_sync(dispatch_get_main_queue(), {
                self.delegate?.onDeleteCloth!()
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        })
        
    }
    
    @IBAction func onClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(data: currentClothe.clothe_image)
        var color = colorWithHexString(currentClothe.clothe_colors)
        mainColor.backgroundColor = color
        let hexTranslator = HexColorToName()
        var name = hexTranslator.name(color)
        colorText.text = currentClothe.clothe_colors + " " + (name[1] as! String)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (count(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rString = (cString as NSString).substringToIndex(2)
        var gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        var bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}