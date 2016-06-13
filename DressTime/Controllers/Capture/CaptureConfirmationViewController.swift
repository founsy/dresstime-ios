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

class CaptureConfirmationViewController: DTViewController {

    @IBOutlet weak var captureResult: UIImageView!
    @IBOutlet weak var nameClothe: UITextField!
    @IBOutlet var colorBtnCollection: [UIButton]!
    @IBOutlet weak var headerMsgLabel: UILabel!
    @IBOutlet weak var patternTitleLabel: UILabel!
    
    @IBOutlet weak var patternContainerView: UIView!
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

    @IBAction func onTouchUpColor(sender: UIButton) {
        for i in 0 ..< colorBtnCollection.count{
            if (colorBtnCollection[i] == sender){
                colorBtnCollection[i].selected = true
                colorBtnCollection[i].layer.borderWidth = 2.0
                colorBtnCollection[i].layer.borderColor = UIColor.dressTimeOrange().CGColor
            } else {
                colorBtnCollection[i].selected = false
                colorBtnCollection[i].layer.borderWidth = 1.0
                colorBtnCollection[i].layer.borderColor = UIColor.whiteColor().CGColor
            }
        }

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "Capture_Confirmation"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CaptureConfirmationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        nameClothe.delegate = self
        
        whiteNavBar()
        self.navigationItem.backBarButtonItem   = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        createPickerView()
        applyStyleTextView(nameClothe)
        
        if let clothe = self.clotheObject {
            self.setNewClotheData(clothe)
            self.saveButton.title = NSLocalizedString("captureStep3AddBtn", comment: "").uppercaseString
        }
        
        if let clothe = self.currentClothe {
            self.setModifyClotheData(clothe)
            self.saveButton.title = NSLocalizedString("captureStep3ModifyBtn", comment: "").uppercaseString
        }
        
        //Set Translation
        headerMsgLabel.text = NSLocalizedString("captureStep3HeaderMsg", comment: "")
        patternTitleLabel.text = NSLocalizedString("captureStep3PatternTitle", comment: "").uppercaseString
    }
    
    private func setColors(colors: String){
        let colors = self.splitHexColor(colors)
        for i in 0 ..< min(colorBtnCollection.count, colors.count){
            setColorStyle(colorBtnCollection[i])
            colorBtnCollection[i].backgroundColor = UIColor.colorWithHexString(colors[i] as String)
            if (i == 0){
                colorBtnCollection[i].selected = true
                colorBtnCollection[i].layer.borderWidth = 2.0
                colorBtnCollection[i].layer.borderColor = UIColor.dressTimeOrange().CGColor
            }
        }
    }
    
    private func setNewClotheData(clothe : [String: AnyObject]){
        let type = clothe["clothe_type"] as! String
        let subtype = clothe["clothe_subtype"] as! String
        nameClothe.text = "\(type) - \(subtype)"
        captureResult.image = UIImage(data: clothe["clothe_image"] as! NSData)
        self.setColors(clothe["clothe_colors"] as! String)
    }
    
    private func setModifyClotheData(clothe: Clothe){
        let subtype = clothe.clothe_subtype
        let split = subtype.characters.split{$0 == "-"}.map(String.init)
        if (split.count > 1){
            clothe.clothe_subtype = split[0]
            clothe.clothe_cut = split[1]
        }
        nameClothe.text = clothe.clothe_name
        let clotheImage =  clothe.getImage()
        captureResult.image = clotheImage
        
        //Fall back if image don't have 3 main colors
        let colors = self.splitHexColor(clothe.clothe_colors)
        if (colors.count < 2){
            var tempColor = ""
            let arrayColors = clotheImage.dominantColors()
            for i in 0 ..< min(arrayColors.count, 3) {
                if (tempColor != ""){
                    tempColor += ","
                }
                tempColor += arrayColors[i].hexStringFromColor()
            }
            clothe.clothe_colors = tempColor
        }
        
        self.setColors(clothe.clothe_colors)
        
        if let index = self.patternData.indexOf(clothe.clothe_pattern) {
            self.pickerView.selectItem(index)
            self.selectedPattern = index
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
        
        //Set name of selected Color
        resultCapture["colors"] = getMainColor()
        resultCapture["clothe_litteralColor"] = getSelectedColor()
        
        resultCapture["clothe_name"] = self.nameClothe.text
        let subtype = resultCapture["clothe_subtype"] as! String
        
        let split = subtype.characters.split{$0 == "-"}.map(String.init)
        resultCapture["clothe_cut"] = ""
        if (split.count > 1){
            resultCapture["clothe_subtype"] = split[0]
            resultCapture["clothe_cut"] = split[1]
        }
        
        let dal = ClothesDAL()
        let clothe = dal.save(resultCapture)
        DressingService().UploadImage(clothe.clothe_id, data: resultCapture["clothe_image"] as! NSData, completion: { (isSuccess, object) in
            if (!isSuccess) {
                //TODO - Add Error Message
            }
            print("OK")
        })
        
        DressingService().SaveClothe(clothe) { (isSuccess, object) -> Void in
            if (isSuccess){
                print("Save Clothe")
                NSNotificationCenter.defaultCenter().postNotificationName("NewClotheAddedNotification", object: self, userInfo: ["type": resultCapture["clothe_type"] as! String])
           
                ActivityLoader.shared.hideProgressView()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                //TODO - Add Error Message
            }
            
        }
    }
    
    private func updateClothe(){
        ActivityLoader.shared.showProgressView(view)
        let dal = ClothesDAL()
        self.currentClothe?.clothe_isUnis = self.isUnis()
        self.currentClothe?.clothe_pattern = self.patternData[self.selectedPattern]
        self.currentClothe?.clothe_name = self.nameClothe.text!
        self.currentClothe?.clothe_colors = getMainColor()
        self.currentClothe?.clothe_litteralColor = getSelectedColor()
        
        dal.update(self.currentClothe!)
        DressingService().UpdateClothe(self.currentClothe!) { (isSuccess, object) -> Void in
            ActivityLoader.shared.hideProgressView()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    private func getSelectedColor() -> String {
        let hexTranslator = HexColorToName()
        for item in colorBtnCollection {
            if (item.selected){
                let colorName = UIColor.colorWithHexString(item.backgroundColor!.hexStringFromColor())
                let name = hexTranslator.name(colorName)
                return name[1] as! String
            }
        }
        return ""
    }
    
    private func getMainColor() -> String {
        var mainColor = ""
        for item in colorBtnCollection {
            if (item.selected){
                if (mainColor.isEmpty){
                    mainColor = item.backgroundColor!.hexStringFromColor()
                } else {
                    mainColor = item.backgroundColor!.hexStringFromColor() + "," + mainColor
                }
            } else {
                if (!mainColor.isEmpty) {
                    mainColor += ","
                }
                mainColor += item.backgroundColor!.hexStringFromColor()
            }
            
        }
        return mainColor
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
        for j in 0 ..< self.patternData.count {
            if let cell = pickerView.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: j, inSection: 0)) as? AKCollectionViewCell{
                for subview in cell.view.subviews {
                    if let view = subview as? PatternView{
                        UIView.transitionWithView(view.patternImage, duration: 0.32, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                            if (j == item){
                                view.patternImage.tintColor = UIColor.dressTimeRedBrand()
                            } else {
                                view.patternImage.tintColor = UIColor.whiteColor()
                            }
                            //view.patternImage.image = image
                            }, completion: nil)
                        let font = j == item ? UIFont.boldSystemFontOfSize(17) : UIFont.italicSystemFontOfSize(13)
                        let color = j == item ? UIColor.dressTimeRedBrand() : UIColor.whiteColor()
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