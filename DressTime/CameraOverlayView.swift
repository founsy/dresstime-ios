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


@objc protocol CameraOverlayViewDelegate {
    optional func CameraOverlayViewResult(resultCapture: [String: AnyObject])
}

class CameraOverlayView: UIViewController, UIScrollViewDelegate, UIPickerViewDataSource,UIPickerViewDelegate, CameraSessionControllerDelegate {
    
    var captureManager: CameraSessionManager!
    var scanningLabel: UILabel!
    var collectionView: UICollectionView!
    var pageControl: UIPageControl!
    var scrollView: UIScrollView!
    var arrayUIView: [UIView] = []
    var arrayColors:[UIColor] = []
    var timeToScan: Bool = false
    var currentImage: UIImage!
    var currentPattern: Int!
    var image: UIImageView!
    var skipImage: Int!
    var pageSelected: Int!
    var patternPicker: UIPickerView!
    var typeCloth: String!
    
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
        var rect = CGRectMake(30, 80, 320, 360)
        
        self.captureManager.previewLayer.bounds = rect
        self.captureManager.previewLayer.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        self.captureManager.sessionDelegate = self
        self.view.layer.addSublayer(self.captureManager.previewLayer)
        
        
        var overlay = OverlayView(frame: layerRect)
        overlay.rectForClearing = CGRectMake(30, 80, 320, 360)
        overlay.overallColor = UIColor.grayColor()
        self.view.addSubview(overlay)
        
        initScrollView(getListOfSubType(self.typeCloth))
        initPageControl(getListOfSubType(self.typeCloth))


        var x = 30
        for var i = 1; i < 4; i++ {
            var circleView = UIView()
            circleView.frame = CGRectMake(CGFloat(x), 460, 50, 50)
            var saveCenter = circleView.center
            circleView.layer.cornerRadius = 50 / 2.0;
            circleView.center = saveCenter;
            circleView.layer.borderColor = UIColor.whiteColor().CGColor
            circleView.layer.borderWidth = 2
            circleView.backgroundColor = UIColor.redColor()
            self.arrayUIView.append(circleView)
            self.view.addSubview(circleView)
            x = x + 60
        }
        
        var overlayButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        overlayButton.setImage(UIImage(named: "scanbutton.png"), forState: .Normal)
        overlayButton.frame = CGRectMake(160, 600, 60, 30);
        overlayButton.addTarget(self, action: "validateButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(overlayButton)
        
        var closeButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        closeButton.setImage(UIImage(named: "scanbutton.png"), forState: .Normal)
        closeButton.frame = CGRectMake(30, 30, 60, 30);
        closeButton.addTarget(self, action: "closeButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(closeButton)

        /*var valideButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        valideButton.setImage(UIImage(named: "scanbutton.png"), forState: .Normal)
        valideButton.frame = CGRectMake(300, 30, 60, 30);
        valideButton.addTarget(self, action: "validateButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(valideButton) */
        
        self.image = UIImageView(frame: CGRectMake(30, 600, 60, 60))
        self.image.contentMode = .ScaleAspectFit
        self.image.layer.borderColor = UIColor.blackColor().CGColor
        self.image.layer.borderWidth = 2
        self.view.addSubview(self.image)
        
        self.patternPicker = UIPickerView(frame: CGRectMake(250, 400, 120, 50))
        self.patternPicker.delegate = self
        self.patternPicker.dataSource = self
        self.view.addSubview(self.patternPicker)
        self.currentPattern = 0
        
        var overlayImageView = UIImageView(image: UIImage(named: "overlaygraphic.png"))
        overlayImageView.frame = CGRectMake(30, 80, 320, 360)
        self.view.addSubview(overlayImageView)
        
        
        self.skipImage = 0
        
    }
    
    func initScrollView(labels: [String]){
        
        scrollView = UIScrollView(frame: CGRectMake(150, 10, 100, 50))
        scrollView.contentSize = CGSizeMake(CGFloat(100 * labels.count), 50)
        scrollView.showsHorizontalScrollIndicator = false
        
        for var i = 0; i < labels.count; i++ {
            let x:CGFloat = (CGFloat(i) * 100.0) + 10.0
            
            var label = UILabel(frame: CGRectMake(x, 10, 100, 50))
            label.textAlignment = .Center
            label.text = labels[i]
            scrollView.addSubview(label)
        }
        scrollView.delegate = self
        self.view.addSubview(scrollView)
    }
    
    func initPageControl(labels: [String]){
        pageControl = UIPageControl(frame: CGRectMake(150, 60, 100, 10))
        pageControl.numberOfPages = labels.count
        pageControl.currentPage = 0
        self.pageSelected = 0
        pageControl.addTarget(self, action: "changePage:", forControlEvents: .ValueChanged)
        self.view.addSubview(pageControl)
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
    
    /***************************/
    /* AVCameraSessionDelegate */
    func cameraSessionDidOutputSampleBuffer(sampleBuffer: CMSampleBuffer!) {
        if (self.skipImage == 20) {
            if let image = imageFromSampleBuffer(sampleBuffer) {
                self.currentImage = image
                NSLog("Get sample")
                self.arrayColors = image.dominantColors()
                self.timeToScan = false
                //self.updateColorUIView(self.arrayColors)
                dispatch_sync(dispatch_get_main_queue(), {
                    for i in 0..<min(self.arrayColors.count, self.arrayUIView.count) {
                        self.arrayUIView[i].backgroundColor = self.arrayColors[i]
                    }
                    self.image.image = self.currentImage
                })
            }
            self.skipImage = 0
        } else {
            self.skipImage = self.skipImage + 1
        }
        
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
    
    func hideLabel(label: UILabel) {
        label.hidden = true
    }
    
    
    func changePage(pageControl: UIPageControl){
        self.pageSelected = pageControl.currentPage;
        NSLog("\( self.pageSelected )")
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth = self.scrollView.frame.size.width;
        var fractionalPage = self.scrollView.contentOffset.x / pageWidth;
        var page = lround(Double(fractionalPage));
        self.pageControl.currentPage = page;
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