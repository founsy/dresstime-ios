//
//  CameraSessionManager.swift
//  CustomCamera
//
//  Created by Fab on 11/07/2015.
//
//

import Foundation
import CoreMedia
import CoreImage
import AVFoundation
import UIKit

@objc protocol CameraSessionControllerDelegate {
    @objc optional func cameraSessionDidOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!)
    func cameraSessionReady()
}

class CameraSessionManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var session: AVCaptureSession!
    var sessionQueue: DispatchQueue!
    var videoDeviceInput: AVCaptureDeviceInput!
    var videoDeviceOutput: AVCaptureVideoDataOutput!
    var videoConnection: AVCaptureConnection!
    var stillImageOutput: AVCaptureStillImageOutput!
    var runtimeErrorHandlingObserver: AnyObject?
    var previewLayer: AVCaptureVideoPreviewLayer!;
    
    var sessionDelegate: CameraSessionControllerDelegate?
    
    var controller: UIViewController?
    
    /* Class Methods
    ------------------------------------------*/
    
    class func deviceWithMediaType(_ mediaType: NSString, position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices(withMediaType: mediaType as String) as NSArray
        
        if var captureDevice = devices.firstObject as? AVCaptureDevice {
            for object:Any in devices {
                let device = object as! AVCaptureDevice
                if (device.position == position) {
                    captureDevice = device
                    break
                }
            }
            return captureDevice
        }
        return nil
    }
    
    
    /* Lifecycle
    ------------------------------------------*/
    
    override init() {
        super.init();
        
        session = AVCaptureSession()
        
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        authorizeCamera();
        
        sessionQueue = DispatchQueue(label: "CameraSessionController Session", attributes: [])
        
            sessionQueue.async(execute: {
            self.session.beginConfiguration()
                _ = self.addVideoInput()
                self.addVideoOutput()
                self.addStillImageOutput()
                #if (arch(i386) || arch(x86_64)) && os(iOS)
                    print("Simulator Mode")
                #else
                    self.session.commitConfiguration()
                    self.startCamera()
                #endif
                
                DispatchQueue.main.sync(execute: {
                    self.cameraSessionReady()
                })
            })
    }
    
    deinit {
        self.session.stopRunning()
        self.previewLayer = nil
        self.session = nil
        self.controller = nil
    }
    
    func cameraSessionReady(){
        sessionDelegate?.cameraSessionReady()
    }
    
    /* Instance Methods
    ------------------------------------------*/
    func authorizeCamera() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {
            (granted: Bool) -> Void in
            // If permission hasn't been granted, notify the user.
            if !granted {
                let alert = UIAlertController(title: "Could not use camera!", message: "This application does not have permission to use camera. Please update your privacy settings.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                self.controller?.present(alert, animated: true){}
            }
        });
    }
    
    func addVideoInput() -> Bool {
        var success: Bool = false
        if let videoDevice: AVCaptureDevice = CameraSessionManager.deviceWithMediaType(AVMediaTypeVideo as NSString, position: AVCaptureDevicePosition.back) {
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice) as AVCaptureDeviceInput
                
                try videoDevice.lockForConfiguration()
                if (videoDevice.isFocusModeSupported(.autoFocus)){
                    videoDevice.focusMode = .autoFocus
                }
                if (videoDevice.isFlashModeSupported(AVCaptureFlashMode.auto)){
                    videoDevice.flashMode = AVCaptureFlashMode.auto
                }
                
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                    success = true
                }
                videoDevice.unlockForConfiguration()
                
            } catch let error as NSError {
                print(error)
            }
        }
       
        return success
    }
    
    
    func addVideoOutput() {
        
        videoDeviceOutput = AVCaptureVideoDataOutput()
        videoDeviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)]
        
        videoDeviceOutput.alwaysDiscardsLateVideoFrames = true
        
        videoDeviceOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if session.canAddOutput(videoDeviceOutput) {
            session.addOutput(videoDeviceOutput)
        }
    }
    
    func addStillImageOutput() {
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
    }
    
    func startCamera() {
        sessionQueue.async(execute: {
            let weakSelf: CameraSessionManager? = self
            self.runtimeErrorHandlingObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureSessionRuntimeError, object: self.sessionQueue, queue: nil, using: {
                (note: Foundation.Notification!) -> Void in
                
                let strongSelf: CameraSessionManager = weakSelf!
                
                strongSelf.sessionQueue.async(execute: {
                    strongSelf.session.startRunning()
                })
            })
            self.session.startRunning()
        })
    }
    
    func teardownCamera() {
        sessionQueue.async(execute: {
            self.session.stopRunning()
            NotificationCenter.default.removeObserver(self.runtimeErrorHandlingObserver!)
        })
    }
    
    func focusAndExposeAtPoint(_ point: CGPoint) {
        sessionQueue.async(execute: {
            let device: AVCaptureDevice = self.videoDeviceInput.device
            
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureFocusMode.autoFocus) {
                    device.focusPointOfInterest = point
                    device.focusMode = AVCaptureFocusMode.autoFocus
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(AVCaptureExposureMode.autoExpose) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = AVCaptureExposureMode.autoExpose
                }
                
                device.unlockForConfiguration()
            } catch let error as NSError{
                print(error)
            }
        })
    }
    
    func captureImage(_ completion:((_ image: UIImage?, _ error: NSError?) -> Void)?) {
        sessionQueue.async(execute: {
            if let connection = self.stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
                if (connection.isEnabled){
                    connection.videoOrientation = AVCaptureVideoOrientation.portrait
                    self.stillImageOutput.captureStillImageAsynchronously(from: connection, completionHandler: { (imageDataSampleBuffer, error) in
                        if ((imageDataSampleBuffer == nil || error != nil)) {
                            completion!(nil, nil)
                        } else if let sample = imageDataSampleBuffer {
                            let imageData: Data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sample)
                            let image: UIImage = UIImage(data: imageData)!
                            let rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: UIImageOrientation.downMirrored)
                            completion!(rotatedImage, nil)
                        }
                    })
                }
            }
        })
    }
    
    
    func addVideoPreviewLayer() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
    func addVideoIn() {
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if ((videoDevice) != nil){
            var videoIn: AVCaptureInput?
            
            do {
                videoIn = try AVCaptureDeviceInput(device: videoDevice)
            } catch {
            
            }
            if let v = videoIn{
                if (self.session.canAddInput(v )){
                    self.session.addInput(v )
                } else {
                    NSLog("Couldn't add video input")
                }
            } else {
                NSLog("Couldn't create video capture device");
            }
        } else {
            NSLog("Couldn't create video input");
            
        }
        
    }
    
    func toggleFlash(){
        sessionQueue.async(execute: {
            if let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) {
                if (device.hasTorch) {
                    do {
                        try device.lockForConfiguration()
                    } catch {
                    }
                    
                    if (device.torchMode == AVCaptureTorchMode.on) {
                        device.torchMode = AVCaptureTorchMode.off
                    } else {
                        do {
                            try device.setTorchModeOnWithLevel(1.0)
                        } catch {
                            
                        }
                    }
                    device.unlockForConfiguration()
                }
            }
        })
    }
    
    
    /* AVCaptureVideoDataOutput Delegate
    ------------------------------------------*/
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if (connection.isVideoOrientationSupported){
            //connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            connection.videoOrientation = AVCaptureVideoOrientation.portrait
        }
        if (connection.isVideoMirroringSupported) {
            //connection.videoMirrored = true
            connection.isVideoMirrored = false
        }
        sessionDelegate?.cameraSessionDidOutputSampleBuffer?(sampleBuffer)
    }
    
}
