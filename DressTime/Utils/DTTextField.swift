//
//  DTTextField.swift
//  login
//
//  Created by Fabian Langlet on 7/19/16.
//  Copyright © 2016 Fabian Langlet. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class DTTextField: UITextField, UITextFieldDelegate {
    
    // MARK: - Inspectable properties
    @IBInspectable
    var leftImage: UIImage? {
        didSet{
            let imageView = UIImageView()
            imageView.frame = CGRect(x: 18, y: 22, width: 50, height: 30)
            imageView.contentMode = UIViewContentMode.center
            imageView.image = leftImage
            self.leftView = imageView
            self.leftViewMode = UITextFieldViewMode.always
        }
    }
    
    @IBInspectable
    var AllRadius: CGFloat = 0 {
        didSet{
           setNeedsLayout()
        }
    }
    
    @IBInspectable
    var TopRadius: CGFloat = 0 {
        didSet{
           setNeedsLayout()
        }
    }
    
    @IBInspectable
    var BottomRadius: CGFloat = 0 {
        didSet{
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var LeftRadius: CGFloat = 0 {
        didSet{
           setNeedsLayout()
        }
    }
    
    @IBInspectable
    var RightRadius: CGFloat = 0 {
        didSet{
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var isSeparator: Bool = false {
        didSet{
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var VertiSeparator: Bool = false {
        didSet{
           setNeedsLayout()
        }
    }
    
    @IBInspectable var isPassword: Bool = false {
        didSet{
            if (isPassword) {
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: 18, y: 22, width: 50, height: 30)
                button.setImage(UIImage(named: "eyesopen"), for: UIControlState())
                button.setImage(UIImage(named: "eyesclosdIcon"), for: .selected)
                button.tintColor = UIColor.dressTimeRed()
                button.addTarget(self, action: #selector(DTTextField.buttonAction(_:)), for: UIControlEvents.touchUpInside)
                self.rightView = button
                self.rightViewMode = UITextFieldViewMode.always
                self.isSecureTextEntry = true
                
            }
        }
    }
    
    func buttonAction(_ sender: UIButton!) {
        sender.isSelected = !sender.isSelected
        self.isSecureTextEntry = !sender.isSelected
    }
    
    func setupView(){
        self.layer.cornerRadius = 0.0;
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 0.0
        self.backgroundColor = UIColor(red: 226/255, green: 226/255, blue: 226/255, alpha: 1.0)
        self.textColor = UIColor(red: 240/255, green: 81/255, blue: 85/255, alpha: 1.0)
        self.tintColor = UIColor(red: 240/255, green: 81/255, blue: 85/255, alpha: 1.0)
        if let placeholder = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string:placeholder,
                                                            attributes:[NSForegroundColorAttributeName: UIColor(red: 240/255, green: 81/255, blue: 85/255, alpha: 0.42)])
        }
        self.returnKeyType = UIReturnKeyType.next
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (self.AllRadius > 0) {
            let rectShapeBottom = CAShapeLayer()
            rectShapeBottom.bounds = self.frame
            rectShapeBottom.position = self.center
            rectShapeBottom.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: self.AllRadius, height: self.AllRadius)).cgPath
            self.layer.mask = rectShapeBottom
        }
        
        
        if (self.BottomRadius > 0) {
            let rectShapeBottom = CAShapeLayer()
            rectShapeBottom.bounds = self.frame
            rectShapeBottom.position = self.center
            rectShapeBottom.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: self.BottomRadius, height: self.BottomRadius)).cgPath
            self.layer.mask = rectShapeBottom
        }
        
        if (self.TopRadius > 0){
            let rectShapeTop = CAShapeLayer()
            rectShapeTop.bounds = self.frame
            rectShapeTop.position = self.center
            rectShapeTop.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: self.TopRadius, height: self.TopRadius)).cgPath
            self.layer.mask = rectShapeTop
        }
        
        if (self.LeftRadius > 0){
            let rectShapeTop = CAShapeLayer()
            rectShapeTop.bounds = self.frame
            rectShapeTop.position = self.center
            rectShapeTop.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: self.LeftRadius, height: self.LeftRadius)).cgPath
            self.layer.mask = rectShapeTop
        }
        
        if (self.RightRadius > 0){
            let rectShapeTop = CAShapeLayer()
            rectShapeTop.bounds = self.frame
            rectShapeTop.position = self.center
            rectShapeTop.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: self.RightRadius, height: self.RightRadius)).cgPath
            self.layer.mask = rectShapeTop
        }
        
        if (self.isSeparator){
            let border = CALayer()
            let width = CGFloat(0.5)
            border.borderColor = UIColor(red: 150/250, green: 150/250, blue: 150/250, alpha: 0.5).cgColor
            border.frame = CGRect(x: 18, y: self.frame.size.height - width, width:  self.frame.size.width - 36, height: self.frame.size.height)
            
            border.borderWidth = width
            self.layer.addSublayer(border)
            self.layer.masksToBounds = true
        }
        
        if (self.VertiSeparator){
            let border = CALayer()
            let width = CGFloat(0.5)
            border.borderColor = UIColor(red: 150/250, green: 150/250, blue: 150/250, alpha: 0.5).cgColor
            border.frame = CGRect(x: self.frame.size.width - width, y: 18, width:  width, height: self.frame.size.height - 36
            )
            
            border.borderWidth = width
            self.layer.addSublayer(border)
            self.layer.masksToBounds = true
        }
    }
    
    
    /// MARK : 
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
