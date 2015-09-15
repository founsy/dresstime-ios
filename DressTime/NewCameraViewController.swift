//
//  NewCameraViewController.swift
//  DressTime
//
//  Created by Fab on 05/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import DominantColor

class NewCameraViewController : UIViewController {
    
    private var captureManager: CameraSessionManager?
    private var currentImage: UIImage?
    private var skipImage: Int = 0
    private var arrayColors:[UIColor] = []
    private var arrayUIView: [UIView] = []
    private var timeToScan: Bool = false
    private let labelsSubTop = ["tshirt", "shirt", "shirt-sleeve", "polo","polo-sleeve"]
    private let labelsSubPants = ["jeans", "jeans-slim", "trousers-pleated", "trousers-suit", "chinos", "trousers-regular", "trousers", "trousers-slim", "bermuda", "short"]
    private let labelsSubMaille = ["jumper-fin","jumper-epais ","cardigan","sweater"]
    
    
    var typeClothe: String!
    var subTypeClothe: String!
    
    @IBOutlet weak var scanArea: UIImageView!
    @IBOutlet weak var color1View: UIView!
    @IBOutlet weak var color3View: UIView!
    @IBOutlet weak var color2View: UIView!
    @IBOutlet weak var opacityView: UIView!
    
    @IBAction func onBackButton(sender: AnyObject) {
        self.captureManager!.session.stopRunning()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClose(sender: AnyObject) {
        self.captureManager!.session.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func onCapture(sender: AnyObject) {
        self.captureManager!.captureImage { (image, error) -> Void in
            if let err = error {
                NSLog("Error")
            } else {
                self.currentImage = self.cropImage(image!)
                NSLog("On Capture : \(self.currentImage?.size.width) - \(self.currentImage?.size.height)")
                self.arrayColors = self.currentImage!.dominantColors()
                self.timeToScan = false
                self.captureManager!.session.stopRunning()
                self.performSegueWithIdentifier("showConfirmation", sender: self)
            }
        }

    }
    
    @IBAction func onLight(sender: AnyObject) {
        self.captureManager!.toggleFlash()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        whiteNavBar()
        drawClearRectArea()
        self.captureManager = CameraSessionManager()
        self.captureManager!.addVideoPreviewLayer()
        let layerRect = self.view.layer.bounds
        
        self.captureManager!.previewLayer.bounds = layerRect
        self.captureManager!.previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))
        self.captureManager!.sessionDelegate = self
        
        
        var uiView = UIView(frame: layerRect)
        uiView.layer.addSublayer(self.captureManager!.previewLayer)
        self.view.addSubview(uiView)
        self.view.bringSubviewToFront(self.opacityView)
        
        self.color1View.layer.cornerRadius = 10.0
        self.color1View.layer.borderWidth = 1.0
        self.color1View.layer.borderColor = UIColor.whiteColor().CGColor
        self.color2View.layer.cornerRadius = 10.0
        self.color2View.layer.borderWidth = 1.0
        self.color2View.layer.borderColor = UIColor.whiteColor().CGColor
        self.color3View.layer.cornerRadius = 10.0
        self.color3View.layer.borderWidth = 1.0
        self.color3View.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.arrayUIView.append(self.color1View)
        self.arrayUIView.append(self.color2View)
        self.arrayUIView.append(self.color3View)
    }
    
    private func whiteNavBar(){
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        bar.tintColor = UIColor.blackColor()
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
        self.navigationItem.backBarButtonItem   = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.captureManager!.session.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showConfirmation"){
            let controller = segue.destinationViewController as! CaptureConfirmationViewController
            if let image = self.currentImage {
                let img = UIImage(CGImage: image.CGImage, scale: 1.0, orientation: UIImageOrientation.Right)
                let result = self.wrapResultObject(UIImageJPEGRepresentation(img, 1.0), labels: getListOfSubType(self.typeClothe))
                controller.clotheObject = result
                controller.previousController = self
            }
        }
    }
    
    deinit {
        captureManager = nil
    }
    
    private func drawClearRectArea(){
        //opacityView is a UIView of what I want to be "solid"
        var outerPath = UIBezierPath(rect: self.view.frame)
        
        //croppingView is a subview of shadowView that is laid out in interface builder using auto layout
        //croppingView is hidden.
        self.view.layoutIfNeeded()
        self.scanArea.layoutIfNeeded()

        var rectPath = UIBezierPath(rect: CGRectMake(self.scanArea.frame.origin.x - 5, self.scanArea.frame.origin.y+2, self.scanArea.frame.width-5, self.scanArea.frame.height-4))
        outerPath.usesEvenOddFillRule = true
        outerPath.appendPath(rectPath)
        
        var maskLayer = CAShapeLayer()
        maskLayer.path = outerPath.CGPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.fillColor = UIColor.whiteColor().CGColor
        
        self.opacityView.layer.mask = maskLayer
    
    }
    
    private func getListOfSubType(type:String) -> [String]{
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
        
        CGContextSaveGState(newContext)
       
        let imageRef: CGImageRef = CGBitmapContextCreateImage(newContext)
        
        let resultImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Up)!
        UIGraphicsEndImageContext()
        
        return resultImage
    }
    
    private func wrapResultObject(image: NSData, labels: [String]) -> [String: AnyObject]{
        var colors = ""
        
        for var i = 0; i < self.arrayColors.count && i < 3; i++ {
            if (colors != ""){
                colors+=","
            }
            colors += "\(UIColor.hexStringFromColor(self.arrayColors[i]))"
        }
        
        let jsonObject: [String: AnyObject] = [
            "clothe_id": NSUUID().UUIDString,
            "clothe_partnerid": -1,
            "clothe_partnerName": "",
            "clothe_type": self.typeClothe,
            "clothe_subtype": self.subTypeClothe,
            "clothe_name": "",
            "clothe_cut":"",
            "clothe_image": image,
            "clothe_colors": colors
        ]
        
        return jsonObject
    }
    
    func rectToCropImg(image: UIImage) -> CGRect{
        var visibleLayerFrame = self.scanArea.frame
        var metaRect = self.captureManager!.previewLayer.metadataOutputRectOfInterestForRect(visibleLayerFrame)
        println("MetaRect")
        println(metaRect)
        var originalSize = image.size;
        
        var cropRect = CGRectMake( metaRect.origin.x * originalSize.width, metaRect.origin.y * originalSize.height, metaRect.size.width * originalSize.width, metaRect.size.height * originalSize.height)
        
        cropRect = CGRectIntegral(cropRect)
        println("cropRect")
        println(cropRect)
        return cropRect
    }
    
    private func cropImage(image: UIImage) -> UIImage {
       // println(self.scanArea.frame)
        var rect = rectToCropImg(image)
        //let cropRect = CGRectMake(rect.origin.x, rect.origin.y, self.scanArea.frame.width, self.scanArea.frame.height)
        
        //self.scanArea.frame// rectToCropImg(image)//self.captureManager!.previewLayer.convertRect(self.scanArea.frame, fromLayer: self.captureManager!.previewLayer)  //rectToCropImg(image)
        //println(cropRect)
        
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
        // or use the UIImage wherever you like
        return UIImage(CGImage: imageRef)!
    }
    
}

extension NewCameraViewController: CameraSessionControllerDelegate{
    func cameraSessionDidOutputSampleBuffer(sampleBuffer: CMSampleBuffer!){
        if (self.skipImage == 20) {
            if let image = imageFromSampleBuffer(sampleBuffer) {
                self.currentImage = image//cropImage(image)
                NSLog("Get sample")
                self.arrayColors = self.currentImage!.dominantColors()
                self.timeToScan = false
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
    func cameraSessionReady(){
        self.captureManager!.startCamera()
    }
}