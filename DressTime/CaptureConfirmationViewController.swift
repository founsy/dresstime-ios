//
//  CaptureConfirmationViewController.swift
//  DressTime
//
//  Created by Fab on 10/08/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class CaptureConfirmationViewController: UIViewController {

    @IBOutlet weak var captureResult: UIImageView!
    @IBOutlet weak var nameClothe: UITextField!
    @IBOutlet weak var color1: UIView!
    @IBOutlet weak var color2: UIView!
    @IBOutlet weak var color3: UIView!
    @IBOutlet weak var patternContainerView: UIView!
    @IBOutlet weak var brandButton: UIButton!
    
    private let patternData = ["plain", "Hstripe", "Vstripe", "check", "gingham", "jacquard", "printed", "unisTouchImprime", "floral"]
    private var pickerView: AKPickerView!
    private var selectedPattern: Int = 0
    
    var previousController: UIViewController!
    var clotheObject:[String: AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem   = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        createPickerView()
        if let clothe = clotheObject {
            let type = clothe["clothe_type"] as! String
            let subtype = clothe["clothe_subtype"] as! String
            nameClothe.text = "\(type) - \(subtype)"
            captureResult.image = UIImage(data: clothe["clothe_image"] as! NSData)
            let colors = self.splitHexColor(clothe["clothe_colors"] as! String)
            color1.backgroundColor = UIColor.colorWithHexString(colors[0] as String)
            color2.backgroundColor = UIColor.colorWithHexString(colors[1] as String)
            color3.backgroundColor = UIColor.colorWithHexString(colors[2] as String)
        }
    }
    
    private func createPickerView(){
        self.pickerView = AKPickerView(frame: patternContainerView.bounds)
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        self.patternContainerView.addSubview(self.pickerView)
        
        self.pickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20.0)! //[UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        self.pickerView.highlightedFont =  UIFont(name: "HelveticaNeue", size:20)!
        self.pickerView.interitemSpacing = 20.0
        self.pickerView.textColor = UIColor.whiteColor()
        self.pickerView.highlightedTextColor = UIColor.whiteColor()
        //self.pickerView.fisheyeFactor = 0.001
        self.pickerView.pickerViewStyle = AKPickerViewStyle.Wheel
        self.pickerView.maskDisabled = false
        
    }
    
    private func splitHexColor(colors: String) -> [String]{
        var arrayColors = split(colors) {$0 == ","}
        return arrayColors
    }
    
    @IBAction func onBack(sender: AnyObject) {
         self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onAddTouch(sender: AnyObject) {
        let resultCapture = NSMutableDictionary(dictionary: self.clotheObject!)
        var isUnis = 1;
        if (self.patternData[self.selectedPattern] != "plain"){
            isUnis = 0
        }
        
        resultCapture["clothe_isUnis"] = isUnis
        resultCapture["clothe_pattern"] = self.patternData[self.selectedPattern]
        resultCapture["colors"] = UIColor.hexStringFromColor(color1.backgroundColor!)
        var dal = ClothesDAL()
        let clotheId = NSUUID().UUIDString
        dal.save(clotheId, partnerId: resultCapture["clothe_partnerid"] as! NSNumber, partnerName: resultCapture["clothe_partnerName"] as! String, type: resultCapture["clothe_type"] as! String, subType: resultCapture["clothe_subtype"] as! String, name: resultCapture["clothe_name"] as! String, isUnis: resultCapture["clothe_isUnis"] as! Bool, pattern: resultCapture["clothe_pattern"] as! String, cut: resultCapture["clothe_cut"] as! String, image: resultCapture["clothe_image"] as! NSData, colors: resultCapture["clothe_colors"] as! String)
        
        DressTimeService.saveClothe(SharedData.sharedInstance.currentUserId!, clotheId: clotheId, dressingCompleted: { (succeeded: Bool, msg: [[String: AnyObject]]) -> () in
            //println(msg)
        })
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onBackTouch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let controller = self.previousController {
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    

    @IBAction func onBrandTouch(sender: AnyObject) {
    }

}

extension CaptureConfirmationViewController : AKPickerViewDataSource {
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return self.patternData.count
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.patternData[item]
    }
    
}

extension CaptureConfirmationViewController : AKPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NSLog(self.patternData[row]);
        self.selectedPattern = row
        
    }
}