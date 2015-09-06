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
        var devices: NSArray = AVCaptureDevice.devicesWithMediaType(mediaType as String)
        
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
        var error: NSError?
        
        if var videoDevice: AVCaptureDevice = CameraSessionManager.deviceWithMediaType(AVMediaTypeVideo, position: AVCaptureDevicePosition.Back) {
            videoDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &error) as! AVCaptureDeviceInput;
            videoDevice.lockForConfiguration(&error)
            if (error == nil){
                videoDevice.focusMode = .AutoFocus
                //videoDevice.exposureMode = AVCaptureExposureMode.AutoExpose
            }
            if (error == nil) {
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                    success = true
                }
            }
            videoDevice.unlockForConfiguration()
        }
        return success
    }
    
    
    func addVideoOutput() {
        
        videoDeviceOutput = AVCaptureVideoDataOutput()
        videoDeviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString:kCVPixelFormatType_32BGRA]
        
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
            var weakSelf: CameraSessionManager? = self
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
            var device: AVCaptureDevice = self.videoDeviceInput.device
            var error: NSError?
            
            if device.lockForConfiguration(&error) {
                if device.focusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
                    device.focusPointOfInterest = point
                    device.focusMode = AVCaptureFocusMode.AutoFocus
                }
                
                if device.exposurePointOfInterestSupported && device.isExposureModeSupported(AVCaptureExposureMode.AutoExpose) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = AVCaptureExposureMode.AutoExpose
                }
                
                device.unlockForConfiguration()
            }
            else {
                // TODO: Log error.
            }
        })
    }
    
    func captureImage(completion:((image: UIImage?, error: NSError?) -> Void)?) {
      //  if (stillImageOutput != nil) {
      //      return
      //  }
        
        dispatch_async(sessionQueue, {
            self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(
                self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo),completionHandler: {
                    (imageDataSampleBuffer: CMSampleBuffer?, error: NSError?) -> Void in
                    if ((imageDataSampleBuffer == nil || error != nil)) {
                        completion!(image:nil, error:nil)
                    }
                    else if let sample = imageDataSampleBuffer {
                        var imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sample)
                        var image: UIImage = UIImage(data: imageData)!
                        var rotatedImage = UIImage(CGImage: image.CGImage, scale: 1.0, orientation: UIImageOrientation.DownMirrored)
                        completion!(image:rotatedImage, error:nil)
                    }
                }
            )
        })
    }
    
    
    func addVideoPreviewLayer() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
    func addVideoIn() {
        var videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if ((videoDevice) != nil){
            var error: NSError?
            var videoIn = AVCaptureDeviceInput(device: videoDevice, error: &error)
            if (error == nil){
                if (self.session.canAddInput(videoIn)){
                    self.session.addInput(videoIn)
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
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            device.lockForConfiguration(nil)
            if (device.torchMode == AVCaptureTorchMode.On) {
                device.torchMode = AVCaptureTorchMode.Off
            } else {
                device.setTorchModeOnWithLevel(1.0, error: nil)
            }
            device.unlockForConfiguration()
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