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

class CameraViewController : DTViewController {
    
    fileprivate var captureManager: CameraSessionManager?
    fileprivate var currentImage: UIImage?
    fileprivate var bufferImage: UIImage?
    fileprivate var skipImage: Int = 0
    fileprivate var arrayColors:[UIColor] = []
    fileprivate var arrayUIView: [UIView] = []
    fileprivate var timeToScan: Bool = false
    fileprivate let labelsSubTop = ["tshirt", "shirt", "shirt-sleeve", "polo","polo-sleeve"]
    fileprivate let labelsSubPants = ["jeans", "jeans-slim", "trousers-pleated", "trousers-suit", "chinos", "trousers-regular", "trousers", "trousers-slim", "bermuda", "short"]
    fileprivate let labelsSubMaille = ["jumper-fin","jumper-epais ","cardigan","sweater"]
    fileprivate var isCapturing = false
    
    var typeClothe: String!
    var subTypeClothe: String!
    
    @IBOutlet weak var scanArea: UIImageView!
    @IBOutlet weak var color1View: UIView!
    @IBOutlet weak var color3View: UIView!
    @IBOutlet weak var color2View: UIView!
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var messageColorLabel: UILabel!
    
    @IBAction func onBackButton(_ sender: AnyObject) {
        self.captureManager!.session.stopRunning()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClose(_ sender: AnyObject) {
        self.captureManager!.session.stopRunning()
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func onCapture(_ sender: AnyObject) {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            self.currentImage = UIImage(named: "login-bg")
            self.arrayColors = self.currentImage!.dominantColors()
            self.performSegue(withIdentifier: "showConfirmation", sender: self)
        #else
            if (!self.isCapturing){
                self.isCapturing = true
                self.captureManager!.captureImage { (image, error) -> Void in
                    self.isCapturing = false
                    if let _ = image {
                        self.currentImage = self.cropImage(image!)
                        self.arrayColors = self.currentImage!.dominantColors()
                        self.timeToScan = false
                        self.captureManager!.session.stopRunning()
                        self.performSegue(withIdentifier: "showConfirmation", sender: self)
                    } else {
                        NSLog("Error")
                    }
                }
            }
        #endif
    }
    
    @IBAction func onLight(_ sender: AnyObject) {
        self.captureManager!.toggleFlash()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "Capture_Camera"
 
        whiteNavBar()
        drawClearRectArea()
        
        self.captureManager = CameraSessionManager()
        self.captureManager?.controller = self
        self.captureManager!.addVideoPreviewLayer()
        let layerRect = self.view.layer.bounds
        
        self.captureManager!.previewLayer.bounds = layerRect
        self.captureManager!.previewLayer.position = CGPoint(x: layerRect.midX, y: layerRect.midY)
        self.captureManager!.sessionDelegate = self
        
        let uiView = UIView(frame: layerRect)
        uiView.layer.addSublayer(self.captureManager!.previewLayer)
        
        self.view.addSubview(uiView)
        self.view.bringSubview(toFront: self.opacityView)
        
        self.color1View.layer.cornerRadius = 10.0
        self.color1View.layer.borderWidth = 1.0
        self.color1View.layer.borderColor = UIColor.white.cgColor
        self.color2View.layer.cornerRadius = 10.0
        self.color2View.layer.borderWidth = 1.0
        self.color2View.layer.borderColor = UIColor.white.cgColor
        self.color3View.layer.cornerRadius = 10.0
        self.color3View.layer.borderWidth = 1.0
        self.color3View.layer.borderColor = UIColor.white.cgColor
        
        self.arrayUIView.append(self.color1View)
        self.arrayUIView.append(self.color2View)
        self.arrayUIView.append(self.color3View)
        
        //Set Translation
        messageColorLabel.text = NSLocalizedString("captureStep2ColorMsg", comment: "the awesome color of your clothe")
    }
    
    fileprivate func whiteNavBar(){
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        bar.tintColor = UIColor.black
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]
        self.navigationItem.backBarButtonItem   = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        self.captureManager!.startCamera()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showConfirmation"){
            let controller = segue.destination as! CaptureConfirmationViewController
            if let image = self.currentImage {
                #if (arch(i386) || arch(x86_64)) && os(iOS)
                     let img = image
                #else
                    let img = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: UIImageOrientation.right)
                #endif
                let result = self.wrapResultObject(UIImageJPEGRepresentation(img, 1.0)!, labels: getListOfSubType(self.typeClothe))
                controller.clotheObject = result
                controller.previousController = self
            }
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    deinit {
        self.captureManager!.session.stopRunning()
        captureManager = nil
    }
    
    fileprivate func drawClearRectArea(){
        //opacityView is a UIView of what I want to be "solid"
        let outerPath = UIBezierPath(rect: self.view.frame)
        
        //croppingView is a subview of shadowView that is laid out in interface builder using auto layout
        //croppingView is hidden.
        self.view.layoutIfNeeded()
        self.scanArea.layoutIfNeeded()

        let rectPath = UIBezierPath(rect: CGRect(x: self.scanArea.frame.origin.x + 2, y: self.scanArea.frame.origin.y + 2, width: self.scanArea.frame.width - 4, height: self.scanArea.frame.height + 11))
        outerPath.usesEvenOddFillRule = true
        outerPath.append(rectPath)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = outerPath.cgPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.fillColor = UIColor.white.cgColor
        
        self.opacityView.layer.mask = maskLayer
    
    }
    
    fileprivate func getListOfSubType(_ type:String) -> [String]{
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
    
    func imageFromSampleBuffer(_ sampleBuffer :CMSampleBuffer) -> UIImage? {
        let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        let baseAddress: UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, Int(0))!
        
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width: Int = CVPixelBufferGetWidth(imageBuffer)
        let height: Int = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitsPerCompornent:Int = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        let newContext: CGContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: bitsPerCompornent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        newContext.saveGState()
       
        let imageRef: CGImage = newContext.makeImage()!
        
        let resultImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImageOrientation.up)
        UIGraphicsEndImageContext()
        
        return resultImage
    }
    
    fileprivate func wrapResultObject(_ image: Data, labels: [String]) -> [String: AnyObject]{
        var colors = ""
        for i in 0 ..< min(self.arrayColors.count, 3) {
            if (colors != ""){
                colors+=","
            }
            colors += self.arrayColors[i].hexStringFromColor()
        }
        
        let jsonObject: [String: AnyObject] = [
            "clothe_id": UUID().uuidString as AnyObject,
            "clothe_partnerid": -1 as AnyObject,
            "clothe_partnerName": "" as AnyObject,
            "clothe_type": self.typeClothe as AnyObject,
            "clothe_subtype": self.subTypeClothe as AnyObject,
            "clothe_name": "" as AnyObject,
            "clothe_cut":"" as AnyObject,
            "clothe_image": image as AnyObject,
            "clothe_colors": colors as AnyObject
        ]
        
        return jsonObject
    }
    
    func rectToCropImg(_ image: UIImage) -> CGRect{
        let visibleLayerFrame = self.scanArea.frame
        let metaRect = self.captureManager!.previewLayer.metadataOutputRectOfInterest(for: visibleLayerFrame)
        let originalSize = image.size;
        
        var cropRect = CGRect( x: metaRect.origin.x * originalSize.width, y: metaRect.origin.y * originalSize.height, width: metaRect.size.width * originalSize.width, height: metaRect.size.height * originalSize.height)
        
        cropRect = cropRect.integral
        return cropRect
    }
    
    fileprivate func cropImage(_ image: UIImage) -> UIImage {
       // println(self.scanArea.frame)
        let rect = rectToCropImg(image)
        let imageRef = image.cgImage?.cropping(to: rect);
        // or use the UIImage wherever you like
        return UIImage(cgImage: imageRef!)
    }
    
}

extension CameraViewController: CameraSessionControllerDelegate{
    func cameraSessionDidOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!){
        if (self.skipImage == 20) {
            if let image = imageFromSampleBuffer(sampleBuffer) {
                self.bufferImage = cropImage(image)
                self.arrayColors = self.bufferImage!.dominantColors()
                self.timeToScan = false
                DispatchQueue.main.sync(execute: {
                    for i in 0..<min(self.arrayColors.count, self.arrayUIView.count) {
                        self.arrayUIView[i].backgroundColor = self.arrayColors[i]
                    }
                })
            }
            self.skipImage = 0
        } else {
            self.skipImage = self.skipImage + 1
        }

    }
    func cameraSessionReady(){
        //self.captureManager!.toggleFlash()
        //self.captureManager!.startCamera()
    }
}
