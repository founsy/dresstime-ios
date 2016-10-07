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
    
    fileprivate let patternData = ["plain", "Hstripe", "Vstripe", "check", "gingham", "jacquard", "printed", "unisTouchImprime"]
    fileprivate var pickerView: AKPickerView!
    fileprivate var selectedPattern: Int = 0
    fileprivate var isModify = false
    
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

    @IBAction func onTouchUpColor(_ sender: UIButton) {
        for i in 0 ..< colorBtnCollection.count{
            if (colorBtnCollection[i] == sender){
                colorBtnCollection[i].isSelected = true
                colorBtnCollection[i].layer.borderWidth = 2.0
                colorBtnCollection[i].layer.borderColor = UIColor.dressTimeOrange().cgColor
            } else {
                colorBtnCollection[i].isSelected = false
                colorBtnCollection[i].layer.borderWidth = 1.0
                colorBtnCollection[i].layer.borderColor = UIColor.white.cgColor
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
        self.navigationItem.backBarButtonItem   = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        createPickerView()
        applyStyleTextView(nameClothe)
        
        if let clothe = self.clotheObject {
            self.setNewClotheData(clothe)
            self.saveButton.title = NSLocalizedString("captureStep3AddBtn", comment: "").uppercased()
        }
        
        if let clothe = self.currentClothe {
            self.setModifyClotheData(clothe)
            self.saveButton.title = NSLocalizedString("captureStep3ModifyBtn", comment: "").uppercased()
        }
        
        //Set Translation
        headerMsgLabel.text = NSLocalizedString("captureStep3HeaderMsg", comment: "")
        patternTitleLabel.text = NSLocalizedString("captureStep3PatternTitle", comment: "").uppercased()
    }
    
    fileprivate func setColors(_ colors: String){
        let colors = self.splitHexColor(colors)
        for i in 0 ..< min(colorBtnCollection.count, colors.count){
            setColorStyle(colorBtnCollection[i])
            colorBtnCollection[i].backgroundColor = UIColor.colorWithHexString(colors[i] as String)
            if (i == 0){
                colorBtnCollection[i].isSelected = true
                colorBtnCollection[i].layer.borderWidth = 2.0
                colorBtnCollection[i].layer.borderColor = UIColor.dressTimeOrange().cgColor
            }
        }
    }
    
    fileprivate func setNewClotheData(_ clothe : [String: AnyObject]){
        let type = clothe["clothe_type"] as! String
        let subtype = clothe["clothe_subtype"] as! String
        nameClothe.text = "\(type) - \(subtype)"
        captureResult.image = UIImage(data: clothe["clothe_image"] as! Data)
        self.setColors(clothe["clothe_colors"] as! String)
    }
    
    fileprivate func setModifyClotheData(_ clothe: Clothe){
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
        
        if let index = self.patternData.index(of: clothe.clothe_pattern) {
            self.pickerView.selectItem(index)
            self.selectedPattern = index
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    fileprivate func setColorStyle(_ color: UIView){
        color.layer.cornerRadius = 5.0
        color.layer.borderWidth = 1.0
        color.layer.borderColor = UIColor.white.cgColor
    }
    
    fileprivate func applyStyleTextView(_ textField: UITextField){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 1, width: textField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        textField.borderStyle = UITextBorderStyle.none
        textField.layer.addSublayer(bottomLine)
        textField.layer.masksToBounds = true
    }
    
    fileprivate func whiteNavBar(){
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        self.navigationController?.isNavigationBarHidden = false
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        bar.tintColor = UIColor.black
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]
        self.navigationItem.backBarButtonItem   = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func createPickerView(){
        self.pickerView = AKPickerView(frame: patternContainerView.bounds)
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight];
        
        self.patternContainerView.addSubview(self.pickerView)
        
        self.pickerView.font =  UIFont.italicSystemFont(ofSize: 13.0)
        self.pickerView.highlightedFont =  UIFont.systemFont(ofSize: 19.0, weight: UIFontWeightMedium)
        self.pickerView.interitemSpacing = 20.0
        self.pickerView.textColor = UIColor.white
        self.pickerView.highlightedTextColor = UIColor.white
        self.pickerView.pickerViewStyle = AKPickerViewStyle.wheel
        self.pickerView.maskDisabled = false
        
    }
    
    fileprivate func splitHexColor(_ colors: String) -> [String]{
        return colors.characters.split() { $0 == "," } .map { String($0) }
    }
    
    fileprivate func isUnis() -> NSNumber{
        var isUnis = 1;
        if (self.patternData[self.selectedPattern] != "plain"){
            isUnis = 0
        }
        return isUnis as NSNumber
    }
    
    fileprivate func addClothe(){
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
        DressingService().UploadImage(clothe.clothe_id, data: resultCapture["clothe_image"] as! Data, completion: { (isSuccess, object) in
            if (!isSuccess) {
                NotificationCenter.default.post(name: Notifications.Error.UploadClothe, object: nil)
            }
            print("OK")
        })
        
        DressingService().SaveClothe(clothe) { (isSuccess, object) -> Void in
            if (isSuccess){
                print("Save Clothe")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewClotheAddedNotification"), object: self, userInfo: ["type": resultCapture["clothe_type"] as! String])
           
                ActivityLoader.shared.hideProgressView()
                self.dismiss(animated: true, completion: nil)
            } else {
                NotificationCenter.default.post(name: Notifications.Error.SaveClothe, object: nil)
            }
            
        }
    }
    
    fileprivate func updateClothe(){
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
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    fileprivate func getSelectedColor() -> String {
        let hexTranslator = HexColorToName()
        for item in colorBtnCollection {
            if (item.isSelected){
                let colorName = UIColor.colorWithHexString(item.backgroundColor!.hexStringFromColor())
                let name = hexTranslator.name(colorName)
                return name[1] as! String
            }
        }
        return ""
    }
    
    fileprivate func getMainColor() -> String {
        var mainColor = ""
        for item in colorBtnCollection {
            if (item.isSelected){
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
    
    @IBAction func onBack(_ sender: AnyObject) {
         _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddTouch(_ sender: AnyObject) {
        if (!self.isModify){
            self.addClothe()
        } else {
            self.updateClothe()
        }
    }
    
    @IBAction func onBackTouch(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        if let controller = self.previousController {
            self.present(controller, animated: true, completion: nil)
        }
    }
    

    @IBAction func onBrandTouch(_ sender: AnyObject) {
    }
    
    fileprivate func applySelect(_ item: Int){
        for j in 0 ..< self.patternData.count {
            if let cell = pickerView.collectionView.cellForItem(at: IndexPath(item: j, section: 0)) as? AKCollectionViewCell{
                for subview in cell.view.subviews {
                    if let view = subview as? PatternView{
                        UIView.transition(with: view.patternImage, duration: 0.32, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                            if (j == item){
                                view.patternImage.tintColor = UIColor.dressTimeRedBrand()
                            } else {
                                view.patternImage.tintColor = UIColor.white
                            }
                            //view.patternImage.image = image
                            }, completion: nil)
                        let font = j == item ? UIFont.boldSystemFont(ofSize: 17) : UIFont.italicSystemFont(ofSize: 13)
                        let color = j == item ? UIColor.dressTimeRedBrand() : UIColor.white
                        view.patternLabel.animateToFont(font, color: color, withDuration: 0.32)
                    }
                }
            }
        }
    }
}

extension UILabel {
    func animateToFont(_ font: UIFont, color: UIColor,  withDuration duration: Foundation.TimeInterval) {
        let oldFont = self.font
        self.font = font
        //let oldOrigin = frame.origin
        let labelScale = (oldFont?.pointSize)! / font.pointSize
        let oldTransform = transform
        transform = transform.scaledBy(x: labelScale, y: labelScale)
        //frame.origin = oldOrigin
        //setNeedsUpdateConstraints()
        UIView.animate(withDuration: duration, animations: {
            self.transform = oldTransform
            //self.layoutIfNeeded()
            self.textColor = color
        }) 
    }
}

extension CaptureConfirmationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension CaptureConfirmationViewController : AKPickerViewDataSource {
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return self.patternData.count
    }
    
    func pickerView(_ pickerView: AKPickerView, viewForItem item: Int) -> UIView {
        let view = Bundle.main.loadNibNamed("PatternView", owner: self, options: nil)?[0] as! PatternView
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 60)
        view.patternLabel.text = NSLocalizedString(self.patternData[item], comment: "") 
        view.patternLabel.textColor = UIColor.white
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
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int){
        NSLog(self.patternData[item]);
        self.selectedPattern = item
        applySelect(item)
    }
}
