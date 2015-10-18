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
    optional func cameraSessionDidOutputSampleBuffer(sampleBuffer: CMSampleBuffer!)
    func cameraSessionReady()
}

class CameraSessionManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var session: AVCaptureSession!
    var sessionQueue: dispatch_queue_t!
    var videoDeviceInput: AVCaptureDeviceInput!
    var videoDeviceOutput: AVCaptureVideoDataOutput!
    var videoConnection: AVCaptureConnection!
    var stillImageOutput: AVCaptureStillImageOutput!
    var runtimeErrorHandlingObserver: AnyObject?
    var previewLayer: AVCaptureVideoPreviewLayer!;
    
    var sessionDelegate: CameraSessionControllerDelegate?
    
    
    /* Class Methods
    ------------------------------------------*/
    
    class func deviceWithMediaType(mediaType: NSString, position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devicesWithMediaType(mediaType as String)
        
        if var captureDevice = devices.firstObject as? AVCaptureDevice {
            for object:AnyObject in devices {
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
        
        sessionQueue = dispatch_queue_create("CameraSessionController Session", DISPATCH_QUEUE_SERIAL)
        
        dispatch_async(sessionQueue, {
            self.session.beginConfiguration()
            self.addVideoInput()
            self.addVideoOutput()
            self.addStillImageOutput()
            self.session.commitConfiguration()
            dispatch_sync(dispatch_get_main_queue(),{
                self.cameraSessionReady()
            })
        })
    }
    
    func cameraSessionReady(){
        sessionDelegate?.cameraSessionReady()
    }
    
    /* Instance Methods
    ------------------------------------------*/
    func authorizeCamera() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
            (granted: Bool) -> Void in
            // If permission hasn't been granted, notify the user.
            if !granted {
                dispatch_async(dispatch_get_main_queue(), {
                    UIAlertView(
                        title: "Could not use camera!",
                        message: "This application does not have permission to use camera. Please update your privacy settings.",
                        delegate: self,
                        cancelButtonTitle: "OK").show()
                })
            }
        });
    }
    
    func addVideoInput() -> Bool {
        var success: Bool = false
        if let videoDevice: AVCaptureDevice = CameraSessionManager.deviceWithMediaType(AVMediaTypeVideo, position: AVCaptureDevicePosition.Back) {
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice) as AVCaptureDeviceInput
                
                try videoDevice.lockForConfiguration()
                 videoDevice.focusMode = .AutoFocus

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
        videoDeviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA)]
        
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
        dispatch_async(sessionQueue, {
            let weakSelf: CameraSessionManager? = self
            self.runtimeErrorHandlingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionRuntimeErrorNotification, object: self.sessionQueue, queue: nil, usingBlock: {
                (note: NSNotification!) -> Void in
                
                let strongSelf: CameraSessionManager = weakSelf!
                
                dispatch_async(strongSelf.sessionQueue, {
                    strongSelf.session.startRunning()
                })
            })
            self.session.startRunning()
        })
    }
    
    func teardownCamera() {
        dispatch_async(sessionQueue, {
            self.session.stopRunning()
            NSNotificationCenter.defaultCenter().removeObserver(self.runtimeErrorHandlingObserver!)
        })
    }
    
    func focusAndExposeAtPoint(point: CGPoint) {
        dispatch_async(sessionQueue, {
            let device: AVCaptureDevice = self.videoDeviceInput.device
            
            do {
                try device.lockForConfiguration()
                if device.focusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
                    device.focusPointOfInterest = point
                    device.focusMode = AVCaptureFocusMode.AutoFocus
                }
                
                if device.exposurePointOfInterestSupported && device.isExposureModeSupported(AVCaptureExposureMode.AutoExpose) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = AVCaptureExposureMode.AutoExpose
                }
                
                device.unlockForConfiguration()
            } catch let error as NSError{
                print(error)
            }
        })
    }
    
    func captureImage(completion:((image: UIImage?, error: NSError?) -> Void)?) {
        dispatch_async(sessionQueue, {
            if let connection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
                if (connection.enabled){
                    connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                    self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: {
                            (imageDataSampleBuffer: CMSampleBuffer?, error: NSError?) -> Void in
                        
                            if ((imageDataSampleBuffer == nil || error != nil)) {
                                completion!(image:nil, error:nil)
                            } else if let sample = imageDataSampleBuffer {
                                let imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sample)
                                let image: UIImage = UIImage(data: imageData)!
                                let rotatedImage = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: UIImageOrientation.DownMirrored)
                                completion!(image:rotatedImage, error:nil)
                            }
                        }
                    )
                }
            }
        })
    }
    
    
    func addVideoPreviewLayer() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
    func addVideoIn() {
        let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
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
        if let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) {
            if (device.hasTorch) {
                do {
                try device.lockForConfiguration()
                } catch {
                }
                
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                } else {
                    do {
                       try device.setTorchModeOnWithLevel(1.0)
                    } catch {
                    
                    }
                }
                device.unlockForConfiguration()
            }
        }
    }
    
    
    /* AVCaptureVideoDataOutput Delegate
    ------------------------------------------*/
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if (connection.supportsVideoOrientation){
            //connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        }
        if (connection.supportsVideoMirroring) {
            //connection.videoMirrored = true
            connection.videoMirrored = false
        }
        sessionDelegate?.cameraSessionDidOutputSampleBuffer?(sampleBuffer)
    }
    
}