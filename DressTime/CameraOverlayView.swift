//
//  CameraOverlayView.swift
//  CustomCamera
//
//  Created by Fab on 11/07/2015.
//
//

import Foundation
import UIKit
import QuartzCore
import CoreMedia
import DominantColor
import AVFoundation


@objc protocol CameraOverlayViewDelegate {
    optional func CameraOverlayViewResult(resultCapture: [String: AnyObject])
}

class CameraOverlayView: UIViewController, CameraSessionControllerDelegate {
    
    var captureManager: CameraSessionManager!
    var scanningLabel: UILabel!
    var collectionView: UICollectionView!
    var arrayUIView: [UIView] = []
    var arrayColors:[UIColor] = []
    var timeToScan: Bool = false
    var currentImage: UIImage!
    var currentPattern: Int!
    var image: UIImageView!
    var skipImage: Int!
    var pageSelected: Int!
    var typeCloth: String!
    var pickerView: AKPickerView!
    
    var delegate: CameraOverlayViewDelegate?
    
    let patternData = ["plain", "Hstripe", "Vstripe", "check", "gingham", "jacquard", "printed", "unisTouchImprime", "floral"]
    let labelsSubTop = ["tshirt", "shirt", "shirt-sleeve", "polo","polo-sleeve"]
    let labelsSubPants = ["jeans", "jeans-slim", "trousers-pleated", "trousers-suit", "chinos", "trousers-regular", "trousers", "trousers-slim", "bermuda", "short"]
    let labelsSubMaille = ["jumper-fin","jumper-epais ","cardigan","sweater"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.captureManager = CameraSessionManager()
        self.captureManager.addVideoPreviewLayer()
        var layerRect = self.view.layer.bounds
        var rect = self.createScanArea()
        
 
        self.captureManager.previewLayer.bounds = layerRect
        self.captureManager.previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))
        self.captureManager.sessionDelegate = self
        self.view.layer.addSublayer(self.captureManager.previewLayer)
        
        var overlay = OverlayView(frame: layerRect)
        overlay.rectForClearing = rect
        overlay.overallColor = UIColor.grayColor()
        self.view.addSubview(overlay)
        
        var overlayImageView = UIImageView(image: UIImage(named: "ScanArea"))
        overlayImageView.frame = rect
        self.view.addSubview(overlayImageView)
        
        var text: String = "HELP US! SWIPE FOR FIND THE RIGHT PATTERN"
        var attributedText: NSMutableAttributedString = NSMutableAttributedString(string: text as String)
        
        attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(15)], range: NSRange(location: 9, length: 5))
        
        var textView = UITextView()
        //textView.text = "HELP US! SWIPE FOR FIND THE RIGHT PATTERN";
        textView.attributedText = attributedText
       // textView.font = UIFont(name: "HelveticaNeue", size: 15.0)
        textView.textColor = UIColor.whiteColor()
        textView.textAlignment = NSTextAlignment.Center
        textView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(textView)
        applyTopCenterXBelow(textView, belowTo: nil, width: 200, height: 50)
        
        var view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(view)
        applyTopCenterXBelow(view, belowTo: textView, width: 200, height: 2)
        
        createPickerView()
        applyTopCenterXBelow(self.pickerView, belowTo: view, width: 300, height: 50)
        
        var circleSize = 50.0
        var buttonSize = 70.0
        var screenRect = UIScreen.mainScreen().bounds
        
        if  (screenRect.size.height == 480.0){
            circleSize = 35.0
            buttonSize = 65.0
        }
 
        var overlayButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        overlayButton.layer.cornerRadius = 70/2
        overlayButton.backgroundColor = UIColor.whiteColor()
        overlayButton.setImage(UIImage(named: "ScanCapture"), forState: .Normal)
        overlayButton.addTarget(self, action: "validateButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(overlayButton)
        applyBottomCenterButtonConstraints(overlayButton, width: CGFloat(buttonSize))
        
        var closeButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        closeButton.setImage(UIImage(named: "ScanClose"), forState: .Normal)
        closeButton.addTarget(self, action: "closeButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(closeButton)
        applyTopRightButtonConstraints(closeButton)
        
        var flashButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        flashButton.setImage(UIImage(named: "ScanTorch"), forState: .Normal)
        flashButton.addTarget(self, action: "flashButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(flashButton)
        applyBottomRightButtonConstraints(flashButton)
        

        
        
        var x = rect.origin.x
        for var i = 0; i < 3; i++ {
            var circleView = UIView()
            var saveCenter = circleView.center
            circleView.layer.cornerRadius = CGFloat(circleSize/2.0)
            circleView.center = saveCenter;
            circleView.layer.borderColor = UIColor.whiteColor().CGColor
            circleView.layer.borderWidth = 2
            circleView.backgroundColor = UIColor.redColor()
            self.arrayUIView.append(circleView)
            self.view.addSubview(circleView)
            if (i > 0) {
                self.applyBelowScanZone(circleView, x: 10, nextTo: self.arrayUIView[0], belowTo: overlayImageView, width: CGFloat(circleSize), i: i)
            } else {
                self.applyBelowScanZone(circleView, x: x, nextTo: nil, belowTo: overlayImageView, width: CGFloat(circleSize), i: i)
            }
        }
        
        self.currentPattern = 0
        
        self.skipImage = 0
        
    }
    
    func createPickerView(){
        self.pickerView = AKPickerView(frame: CGRectMake(0, 0, 100, 50))
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        self.view.addSubview(self.pickerView)
       
        self.pickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20.0)! //[UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        self.pickerView.highlightedFont =  UIFont(name: "HelveticaNeue", size:20)!
        self.pickerView.interitemSpacing = 20.0
        self.pickerView.textColor = UIColor.whiteColor()
        self.pickerView.highlightedTextColor = UIColor.whiteColor()
        //self.pickerView.fisheyeFactor = 0.001
        self.pickerView.pickerViewStyle = AKPickerViewStyle.Wheel
        self.pickerView.maskDisabled = false
    
    }
    
    func getListOfSubType(type:String) -> [String]{
        if (type == "top"){
            return self.labelsSubTop
        } else if (type == "maille") {
            return self.labelsSubMaille
        } else if (type == "pants") {
            return self.labelsSubPants
        } else {
            return []
        }
    }
    
    deinit {
        captureManager = nil;
        scanningLabel = nil;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cameraSessionReady() {
        captureManager.startCamera()
        
    }
    
    func createScanArea() -> CGRect{
        
        var screenRect = UIScreen.mainScreen().bounds
        var screenWidth = screenRect.size.width;
        var screenHeight = screenRect.size.height;
        
        var x = screenWidth * 0.08
        var y = screenHeight * 0.2
        var width = screenWidth * 0.85
        var height = screenHeight * 0.54
        println("\(screenWidth)  \(screenHeight)") //Height: 667 - Width= 375
        
       // x: 30, y: 80, width : 320, height : 360
        return CGRectMake(x, y, width, height)
    }
    
    func applyBottomCenterButtonConstraints(view: UIView, width: CGFloat){
        let heightContraints = NSLayoutConstraint(item: view, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: width)
        
        let widthContraints = NSLayoutConstraint(item: view, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: width)
        
        let pinBottom = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal,
            toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -10)
        
        let horizonalContraints = NSLayoutConstraint(item: view, attribute:
            .CenterX, relatedBy: .Equal, toItem: self.view,
            attribute: .CenterX, multiplier: 1.0,
            constant: 0)
        
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        NSLayoutConstraint.activateConstraints([horizonalContraints , pinBottom, heightContraints, widthContraints])
        
    }
    
    func applyTopLeftButtonConstraints(view: UIView){
        
        //pin the slider 20 points from the left edge of the the superview
        //from the left edge of the slider to the left edge of the superview
        //superview X coord is at 0 therefore 0 + 20 = 20 position
        let horizonalContraints = NSLayoutConstraint(item: view, attribute:
            .LeadingMargin, relatedBy: .Equal, toItem: self.view,
            attribute: .LeadingMargin, multiplier: 1.0,
            constant: 20)
        
        //pin the slider 20 points from the right edge of the super view
        //negative because we want to pin -20 points from the end of the superview.
        //ex. if with of super view is 300, 300-20 = 280 position
       /* let horizonal2Contraints = NSLayoutConstraint(item: view, attribute:
            .TrailingMargin, relatedBy: .Equal, toItem: self.view,
            attribute: .TrailingMargin, multiplier: 1.0, constant: -20)*/
        
        //pin 100 points from the top of the super
        let pinTop = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal,
            toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 20)
        
        let heightContraints = NSLayoutConstraint(item: view, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: 40)
        
        let widthContraints = NSLayoutConstraint(item: view, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: 40)
        
        //when using autolayout we an a view, MUST ALWAYS SET setTranslatesAutoresizingMaskIntoConstraints
        //to false.
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //IOS 8
        //activate the constrains.
        //we pass an array of all the contraints
        NSLayoutConstraint.activateConstraints([horizonalContraints , pinTop, heightContraints, widthContraints])
    }
    
    func applyTopRightButtonConstraints(view: UIView){
        
        //pin the slider 20 points from the left edge of the the superview
        //from the left edge of the slider to the left edge of the superview
        //superview X coord is at 0 therefore 0 + 20 = 20 position
        let horizonalContraints = NSLayoutConstraint(item: view, attribute:
            .TrailingMargin, relatedBy: .Equal, toItem: self.view,
            attribute: .TrailingMargin, multiplier: 1.0,
            constant: 0)
        
        //pin the slider 20 points from the right edge of the super view
        //negative because we want to pin -20 points from the end of the superview.
        //ex. if with of super view is 300, 300-20 = 280 position
        /* let horizonal2Contraints = NSLayoutConstraint(item: view, attribute:
        .TrailingMargin, relatedBy: .Equal, toItem: self.view,
        attribute: .TrailingMargin, multiplier: 1.0, constant: -20)*/
        
        //pin 100 points from the top of the super
        let pinTop = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal,
            toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 15)
        
        let heightContraints = NSLayoutConstraint(item: view, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: 40)
        
        let widthContraints = NSLayoutConstraint(item: view, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: 40)
        
        //when using autolayout we an a view, MUST ALWAYS SET setTranslatesAutoresizingMaskIntoConstraints
        //to false.
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //IOS 8
        //activate the constrains.
        //we pass an array of all the contraints
        NSLayoutConstraint.activateConstraints([horizonalContraints , pinTop, heightContraints, widthContraints])
    }
    
    func applyBelowScanZone(view: UIView, x: CGFloat, nextTo: UIView?, belowTo: UIView, width: CGFloat, i: Int){
        let heightContraints = NSLayoutConstraint(item: view, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: width)
        
        let widthContraints = NSLayoutConstraint(item: view, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: width)
        
        let verticalContraints = NSLayoutConstraint(item: view, attribute:
            .Top, relatedBy: .Equal, toItem: belowTo,
            attribute: .Bottom, multiplier: 1.0,
            constant: 10)
        
        let horizonalContraints2 = NSLayoutConstraint(item: view, attribute:
            .CenterX, relatedBy: .Equal, toItem: self.view,
            attribute: .CenterX, multiplier: 1.0,
            constant: 0)
        
        if let nextView = nextTo {
            var horizontalContrains :NSLayoutConstraint!
            if (i == 1){ //Left
                horizontalContrains = NSLayoutConstraint(item: view, attribute:
                    .Leading, relatedBy: .Equal, toItem: nextView,
                    attribute: .Trailing, multiplier: 1.0,
                    constant: 40)
            } else { //Right
                horizontalContrains = NSLayoutConstraint(item: view, attribute:
                    .Trailing, relatedBy: .Equal, toItem: nextView,
                    attribute: .Leading, multiplier: 1.0,
                    constant: -40)
            }
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            NSLayoutConstraint.activateConstraints([verticalContraints, horizontalContrains, heightContraints, widthContraints])
        
        } else {
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            NSLayoutConstraint.activateConstraints([verticalContraints, horizonalContraints2, heightContraints, widthContraints])
        }
    }
    
    func applyBelowScanZoneRight(view: UIView, belowTo: UIView){
        let heightContraints = NSLayoutConstraint(item: view, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: 50)
        
        let widthContraints = NSLayoutConstraint(item: view, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: 120)
        
        let verticalContraints = NSLayoutConstraint(item: view, attribute:
            .Top, relatedBy: .Equal, toItem: belowTo,
            attribute: .Bottom, multiplier: 1.0,
            constant: 10)
        
        let horizonalContraints = NSLayoutConstraint(item: view, attribute:
            .TrailingMargin, relatedBy: .Equal, toItem: self.view,
            attribute: .TrailingMargin, multiplier: 1.0,
            constant: 10)

        
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        NSLayoutConstraint.activateConstraints([verticalContraints, horizonalContraints, heightContraints, widthContraints])

    }
    
    func applyTopCenterXBelow(view: UIView, belowTo: UIView?, width: CGFloat, height: CGFloat){
        let heightContraints = NSLayoutConstraint(item: view, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: height)
        
        let widthContraints = NSLayoutConstraint(item: view, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: width)
        
        var verticalContraints = NSLayoutConstraint(item: view, attribute:
            .Top, relatedBy: .Equal, toItem: self.view,
            attribute: .Top, multiplier: 1.0,
            constant: 15)
        
        if let below = belowTo {
            verticalContraints = NSLayoutConstraint(item: view, attribute:
                .Top, relatedBy: .Equal, toItem: below,
                attribute: .Bottom, multiplier: 1.0,
                constant: 0)
        }
        
        let horizonalContraints = NSLayoutConstraint(item: view, attribute:
            .CenterX, relatedBy: .Equal, toItem: self.view,
            attribute: .CenterX, multiplier: 1.0,
            constant: 0)
        
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        NSLayoutConstraint.activateConstraints([verticalContraints, horizonalContraints, heightContraints, widthContraints])
    }
    
    func applyTopCenterFull(view: UIView){
        let heightContraints = NSLayoutConstraint(item: view, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: 50)
        
        let widthContraints = NSLayoutConstraint(item: view, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: 300)
        
        var verticalContraints = NSLayoutConstraint(item: view, attribute:
            .Top, relatedBy: .Equal, toItem: self.view,
            attribute: .Top, multiplier: 1.0,
            constant: 10)
        
        let horizonalContraints = NSLayoutConstraint(item: view, attribute:
            .CenterX, relatedBy: .Equal, toItem: self.view,
            attribute: .CenterX, multiplier: 1.0,
            constant: 0)
        
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        NSLayoutConstraint.activateConstraints([verticalContraints, horizonalContraints, heightContraints, widthContraints])
    }
    
    func applyBottomRightButtonConstraints(view: UIView){
        let horizonalContraints = NSLayoutConstraint(item: view, attribute:
            .TrailingMargin, relatedBy: .Equal, toItem: self.view,
            attribute: .TrailingMargin, multiplier: 1.0,
            constant: 0)

        let pinBottom = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal,
            toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -10)
        
        
        let heightContraints = NSLayoutConstraint(item: view, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: 40)
        
        let widthContraints = NSLayoutConstraint(item: view, attribute:
            .Width, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: 40)
        
        //when using autolayout we an a view, MUST ALWAYS SET setTranslatesAutoresizingMaskIntoConstraints
        //to false.
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //IOS 8
        //activate the constrains.
        //we pass an array of all the contraints
        NSLayoutConstraint.activateConstraints([horizonalContraints , pinBottom, heightContraints, widthContraints])
    }
    
    /***************************/
    /* AVCameraSessionDelegate */
    func cameraSessionDidOutputSampleBuffer(sampleBuffer: CMSampleBuffer!) {
        if (self.skipImage == 20) {
            if let image = imageFromSampleBuffer(sampleBuffer) {
                self.currentImage = image
                NSLog("Get sample")
                self.arrayColors = cropImage(image).dominantColors()
                self.timeToScan = false
                //self.updateColorUIView(self.arrayColors)
                dispatch_sync(dispatch_get_main_queue(), {
                    for i in 0..<min(self.arrayColors.count, self.arrayUIView.count) {
                        self.arrayUIView[i].backgroundColor = self.arrayColors[i]
                    }
                   //self.image.image = self.currentImage
                })
            }
            self.skipImage = 0
        } else {
            self.skipImage = self.skipImage + 1
        }
        
    }
    
    func cropImage(image: UIImage) -> UIImage {
        let reduceX = round(image.size.width * 0.2)
        let reduceY = round(image.size.height * 0.2)
        let cropRect = CGRectMake(reduceX, reduceY, image.size.width - reduceX, image.size.height - reduceY)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
        // or use the UIImage wherever you like
        return UIImage(CGImage: imageRef)!
    }
    /***************************/
    /* Button Actions          */
    func scanButtonPressed(sender: UIButton!) {
        //self.scanningLabel.hidden = false
        let delay = 1.0 * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        self.timeToScan = true
        for var i = 0; i < arrayUIView.count; i++ {
            arrayUIView[i].backgroundColor = UIColor.clearColor()
        }
    }
    
    func validateButtonPressed(sender: UIButton!){
        if let image = self.currentImage {
            let result = wrapResultObject(UIImageJPEGRepresentation(image, 1.0), labels: getListOfSubType(self.typeCloth))
            delegate?.CameraOverlayViewResult!(result)
            
        }
        self.captureManager.session.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func updateColorUIView(arrayColors: [UIColor]){
        NSLog("Update")
        dispatch_async(dispatch_get_global_queue(0, 0), {
            for i in 0..<min(self.arrayColors.count, self.arrayUIView.count) {
                self.arrayUIView[i].backgroundColor = self.arrayColors[i]
            }
            self.image.image = self.currentImage
        })
    }
    
    func closeButtonPressed(sender: UIButton!) {
        self.captureManager.session.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func flashButtonPressed(sender: UIButton!){
        self.captureManager.toggleFlash()
    }
    
    func hideLabel(label: UILabel) {
        label.hidden = true
    }
    
    /*
    func changePage(pageControl: UIPageControl){
        self.pageSelected = pageControl.currentPage;
        NSLog("\( self.pageSelected )")
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth = self.scrollView.frame.size.width;
        var fractionalPage = self.scrollView.contentOffset.x / pageWidth;
        var page = lround(Double(fractionalPage));
        self.pageControl.currentPage = page;
        self.pageSelected = page
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return patternData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return patternData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?{
        let titleData = patternData[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        self.currentPattern = row;
        return myTitle
    }
    */
    
    func imageFromSampleBuffer(sampleBuffer :CMSampleBufferRef) -> UIImage? {
        let imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        let baseAddress: UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, Int(0))
        
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width: Int = CVPixelBufferGetWidth(imageBuffer)
        let height: Int = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
        
        let bitsPerCompornent:Int = 8
        var bitmapInfo = CGBitmapInfo((CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue) as UInt32)
        let newContext: CGContextRef = CGBitmapContextCreate(baseAddress, width, height, bitsPerCompornent, bytesPerRow, colorSpace, bitmapInfo) as CGContextRef
        
        let imageRef: CGImageRef = CGBitmapContextCreateImage(newContext)
        let resultImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Up)!
        UIGraphicsEndImageContext()
        
        return resultImage
    }
    
    func hexStringFromColor(color: UIColor) -> String{
        let components = CGColorGetComponents(color.CGColor);
    
        let r = components[0];
        let g = components[1];
        let b = components[2];
    
        return String(format:"%02lX%02lX%02lX", Int(r * 255), Int(g * 255), Int(b * 255))

    }
    
    func wrapResultObject(image: NSData, labels: [String]) -> [String: AnyObject]{
        var isUnis = 1;
        if (self.patternData[self.currentPattern] != "plain"){
            isUnis = 0
        }
   
        let jsonObject: [String: AnyObject] = [
            "clothe_id": NSUUID().UUIDString,
            "clothe_partnerid": -1,
            "clothe_partnerName": "",
            "clothe_type": self.typeCloth,
            "clothe_subtype": labels[self.pageSelected],
            "clothe_name": "",
            "clothe_isUnis": isUnis,
            "clothe_pattern": self.patternData[self.currentPattern],
            "clothe_cut":"",
            "clothe_image": image,
            "clothe_colors": hexStringFromColor(self.arrayColors[0])
        ]
        
        return jsonObject
    }

}

extension CameraOverlayView : AKPickerViewDataSource {
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return self.patternData.count
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.patternData[item]
    }
    
}


extension CameraOverlayView : AKPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NSLog(self.patternData[row]);
        self.pageSelected = row

    }
}