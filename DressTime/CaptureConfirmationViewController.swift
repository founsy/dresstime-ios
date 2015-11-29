//
//  CaptureConfirmationViewController.swift
//  DressTime
//
//  Created by Fab on 10/08/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import DominantColor

class CaptureConfirmationViewController: UIViewController {

    @IBOutlet weak var captureResult: UIImageView!
    @IBOutlet weak var nameClothe: UITextField!
    @IBOutlet weak var color1: UIView!
    @IBOutlet weak var color2: UIView!
    @IBOutlet weak var color3: UIView!
    @IBOutlet weak var patternContainerView: UIView!
    @IBOutlet weak var brandButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private let patternData = ["plain", "Hstripe", "Vstripe", "check", "gingham", "jacquard", "printed", "unisTouchImprime"]
    private var pickerView: AKPickerView!
    private var selectedPattern: Int = 0
    private var isModify = false
    
    var previousController: UIViewController!
    var clotheObject:[String: AnyObject]? {
        didSet {
            isModify = false
        }
    }
    
    var currentClothe: Clothe? {
        didSet {
            isModify = true
        }
    }
    
    //TODO - Cut subtype-cut 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        nameClothe.delegate = self
        
        whiteNavBar()
        self.navigationItem.backBarButtonItem   = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        createPickerView()
        brandButton.layer.cornerRadius = 30.0
        setColorStyle(color1)
        setColorStyle(color2)
        setColorStyle(color3)
        applyStyleTextView(nameClothe)
        
        if let clothe = self.clotheObject {
            let type = clothe["clothe_type"] as! String
            let subtype = clothe["clothe_subtype"] as! String
            nameClothe.text = "\(type) - \(subtype)"
            captureResult.image = UIImage(data: clothe["clothe_image"] as! NSData)
            let colors = self.splitHexColor(clothe["clothe_colors"] as! String)
            color1.backgroundColor = UIColor.colorWithHexString(colors[0] as String)
            color2.backgroundColor = UIColor.colorWithHexString(colors[1] as String)
            color3.backgroundColor = UIColor.colorWithHexString(colors[2] as String)
        }
        
        if let clothe = self.currentClothe {
            let type = clothe.clothe_type
            let subtype = clothe.clothe_subtype
            let split = subtype.characters.split{$0 == "-"}.map(String.init)
            if (split.count > 1){
                clothe.clothe_subtype = split[0]
                clothe.clothe_cut = split[1]
            }
            nameClothe.text = "\(type) - \(subtype)"
            let clotheImage =  UIImage(data: clothe.clothe_image)
            captureResult.image = clotheImage
            
            //Fall back if image don't have 3 main colors
            var colors = self.splitHexColor(clothe.clothe_colors)
            if (colors.count < 2){
                var tempColor = ""
                let arrayColors = clotheImage!.dominantColors()
                for var i = 0; i < arrayColors.count && i < 3; i++ {
                    if (tempColor != ""){
                        tempColor += ","
                    }
                    tempColor += arrayColors[i].hexStringFromColor()
                }
                clothe.clothe_colors = tempColor
                colors = self.splitHexColor(tempColor)
            }
            
            if (colors.count > 0) {
                color1.backgroundColor = UIColor.colorWithHexString(colors[0] as String)
                let hexTranslator = HexColorToName()
                let colorName = UIColor.colorWithHexString(colors[0])
                clothe.clothe_litteralColor = hexTranslator.name(colorName)[1] as! String
                
            }
            if (colors.count > 1) {
                color2.backgroundColor = UIColor.colorWithHexString(colors[1] as String)
            }
            if (colors.count > 2) {
                color3.backgroundColor = UIColor.colorWithHexString(colors[2] as String)
            }
            if let index = self.patternData.indexOf(clothe.clothe_pattern) {
                self.pickerView.selectItem(index)
                self.selectedPattern = index
            }
        }
        
        if (self.isModify){
            self.saveButton.title = "MODIFY"
        } else {
            self.saveButton.title = "ADD"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func setColorStyle(color: UIView){
        color.layer.cornerRadius = 5.0
        color.layer.borderWidth = 1.0
        color.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    private func applyStyleTextView(textField: UITextField){
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, textField.frame.height - 1, textField.frame.width, 1.0)
        bottomLine.backgroundColor = UIColor.whiteColor().CGColor
        textField.borderStyle = UITextBorderStyle.None
        textField.layer.addSublayer(bottomLine)
        textField.layer.masksToBounds = true
    }
    
    private func whiteNavBar(){
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        self.navigationController?.navigationBarHidden = false
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        bar.tintColor = UIColor.blackColor()
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
        self.navigationItem.backBarButtonItem   = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    private func createPickerView(){
        self.pickerView = AKPickerView(frame: patternContainerView.bounds)
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight];
        
        self.patternContainerView.addSubview(self.pickerView)
        
        self.pickerView.font =  UIFont.italicSystemFontOfSize(13.0)
        self.pickerView.highlightedFont =  UIFont.systemFontOfSize(19.0, weight: UIFontWeightMedium)
        self.pickerView.interitemSpacing = 20.0
        self.pickerView.textColor = UIColor.whiteColor()
        self.pickerView.highlightedTextColor = UIColor.whiteColor()
        self.pickerView.pickerViewStyle = AKPickerViewStyle.Wheel
        self.pickerView.maskDisabled = false
        
    }
    
    private func splitHexColor(colors: String) -> [String]{
        return colors.characters.split() { $0 == "," } .map { String($0) }
    }
    
    private func isUnis() -> NSNumber{
        var isUnis = 1;
        if (self.patternData[self.selectedPattern] != "plain"){
            isUnis = 0
        }
        return isUnis
    }
    
    private func addClothe(){
        ActivityLoader.shared.showProgressView(view)
        let resultCapture = NSMutableDictionary(dictionary: self.clotheObject!)
        
        resultCapture["clothe_isUnis"] = self.isUnis()
        resultCapture["clothe_pattern"] = self.patternData[self.selectedPattern]
        resultCapture["colors"] = color1.backgroundColor!.hexStringFromColor()
        resultCapture["clothe_name"] = self.nameClothe.text
        let subtype = resultCapture["clothe_subtype"] as! String
        
        let split = subtype.characters.split{$0 == "-"}.map(String.init)
        resultCapture["clothe_cut"] = ""
        if (split.count > 1){
            resultCapture["clothe_subtype"] = split[0]
            resultCapture["clothe_cut"] = split[1]
            print(resultCapture)
        }
        
        let dal = ClothesDAL()
        let clotheId = NSUUID().UUIDString
        dal.save(clotheId, partnerId: resultCapture["clothe_partnerid"] as! NSNumber, partnerName: resultCapture["clothe_partnerName"] as! String, type: resultCapture["clothe_type"] as! String, subType: resultCapture["clothe_subtype"] as! String, name: resultCapture["clothe_name"] as! String, isUnis: resultCapture["clothe_isUnis"] as! Bool, pattern: resultCapture["clothe_pattern"] as! String, cut: resultCapture["clothe_cut"] as! String, image: resultCapture["clothe_image"] as! NSData, colors: resultCapture["clothe_colors"] as! String)
        
        DressingService().SaveClothe(clotheId) { (isSuccess, object) -> Void in
            print("Save Clothe")
            ActivityLoader.shared.hideProgressView()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func updateClothe(){
        ActivityLoader.shared.showProgressView(view)
        let dal = ClothesDAL()
        self.currentClothe?.clothe_isUnis = self.isUnis()
        self.currentClothe?.clothe_pattern = self.patternData[self.selectedPattern]
        self.currentClothe?.clothe_name = self.nameClothe.text!
        
        dal.update(self.currentClothe!)
        DressingService().UpdateClothe(self.currentClothe!.clothe_id) { (isSuccess, object) -> Void in
            ActivityLoader.shared.hideProgressView()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    @IBAction func onBack(sender: AnyObject) {
         self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onAddTouch(sender: AnyObject) {
        if (!self.isModify){
            self.addClothe()
        } else {
            self.updateClothe()
        }
    }
    
    @IBAction func onBackTouch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let controller = self.previousController {
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    

    @IBAction func onBrandTouch(sender: AnyObject) {
    }
    
    private func applySelect(item: Int){
        for (var j=0; j < self.patternData.count; j++){
            if let cell = pickerView.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: j, inSection: 0)) as? AKCollectionViewCell{
                for (var i = 0; i < cell.view.subviews.count; i++){
                    if let view = cell.view.subviews[i] as? PatternView{
                        let image = j == item ? UIImage(named: "\(self.patternData[j])IconSelect") : UIImage(named: "\(self.patternData[j])Icon");
                        
                        UIView.transitionWithView(view.patternImage, duration: 0.32, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                            view.patternImage.image = image
                            }, completion: nil)
                        let font = j == item ? UIFont.boldSystemFontOfSize(17) : UIFont.italicSystemFontOfSize(13)
                        let color = j == item ? UIColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 1.0) : UIColor.whiteColor()
                        view.patternLabel.animateToFont(font, color: color, withDuration: 0.32)
                    }
                }
            }
        }
    }
}

extension UILabel {
    func animateToFont(font: UIFont, color: UIColor,  withDuration duration: NSTimeInterval) {
        let oldFont = self.font
        self.font = font
        //let oldOrigin = frame.origin
        let labelScale = oldFont.pointSize / font.pointSize
        let oldTransform = transform
        transform = CGAffineTransformScale(transform, labelScale, labelScale)
        //frame.origin = oldOrigin
        //setNeedsUpdateConstraints()
        UIView.animateWithDuration(duration) {
            self.transform = oldTransform
            //self.layoutIfNeeded()
            self.textColor = color
        }
    }
}

extension CaptureConfirmationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension CaptureConfirmationViewController : AKPickerViewDataSource {
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return self.patternData.count
    }
    
    func pickerView(pickerView: AKPickerView, viewForItem item: Int) -> UIView {
        let view = NSBundle.mainBundle().loadNibNamed("PatternView", owner: self, options: nil)[0] as! PatternView
        view.frame = CGRectMake(0, 0, 100, 60)
        view.patternLabel.text = NSLocalizedString(self.patternData[item], comment: "") 
        view.patternLabel.textColor = UIColor.whiteColor()
        if let img = UIImage(named: "\(self.patternData[item])Icon") {
            view.patternImage.image = img
        } else {
            view.patternImage.image =  UIImage(named: "plainIcon")!
        }
        if (self.selectedPattern == item){
            applySelect(self.selectedPattern)
        }
        return view
    }
        
}

extension CaptureConfirmationViewController : AKPickerViewDelegate {
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int){
        NSLog(self.patternData[item]);
        self.selectedPattern = item
        applySelect(item)
    }
}