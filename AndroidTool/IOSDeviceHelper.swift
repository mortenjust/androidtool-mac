//
//  IOSDeviceHelper.swift
//  ioscreenrec
//
//  Created by Morten Just Petersen on 5/5/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreMediaIO

protocol IOSRecorderDelegate {
    func iosRecorderDidStartPreparing(device:AVCaptureDevice)
    func iosRecorderDidEndPreparing()
    func iosRecorderDidFinish(outputFileURL: NSURL!)
    func iosRecorderFailed(title:String, message:String?)
}

protocol IOSDeviceDelegate {
    func iosDeviceAttached(device:AVCaptureDevice)
    func iosDeviceDetached(device:AVCaptureDevice)

}

class IOSDeviceHelper: NSObject, AVCaptureFileOutputRecordingDelegate {
    var session : AVCaptureSession!
    var movieOutput : AVCaptureMovieFileOutput!
    var stillImageOutput : AVCaptureStillImageOutput!
    var delegate : IOSDeviceDelegate!
    var recorderDelegate : IOSRecorderDelegate!
    var input : AVCaptureDeviceInput!
    var saveFilesInPath : String!
    var file : NSURL!
    
    // this class has two modes. One is a per-device instantiated recorder. The other is a discoverer of all iOS devices that are plugged in and out. The class should probably be split into two at one point.
    
    init(recorderDelegate:IOSRecorderDelegate, forDevice device: AVCaptureDevice){
        super.init()
        self.recorderDelegate = recorderDelegate
        setup()

        var err : NSError? = nil
        input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &err) as! AVCaptureDeviceInput
        session.addOutput(movieOutput)
        session.addInput(input)
        session.startRunning()
    }
    
    init(delegate: IOSDeviceDelegate){
        super.init()
        self.delegate = delegate
        setup()
    }
    
    func setup() {
        session = AVCaptureSession()
        movieOutput = AVCaptureMovieFileOutput()
        // TODO: A preference for this directory, which will then be default
        saveFilesInPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DesktopDirectory, .UserDomainMask, true)[0] as! String
        saveFilesInPath = saveFilesInPath.stringByAppendingPathComponent("AndroidTool")
        println("looking")
        makeDevicesVisible() // has to be here to be able to discover iOS devices
    }
    
    
    func toggleRecording(device : AVCaptureDevice, previewView:NSView?=nil){
        if !movieOutput.recording {

            if previewView != nil {
                let layer = AVCaptureVideoPreviewLayer.layerWithSession(session) as! AVCaptureVideoPreviewLayer
                layer.frame = previewView!.bounds
                previewView!.layer?.addSublayer(layer)
                }
            
            println("$$$ start recording of device \(device.localizedName)")
            let filePath = generateFilePath("iOS-recording-", type: "mov")
            file = NSURL(fileURLWithPath: filePath)!
            
            recorderDelegate.iosRecorderDidStartPreparing(device)
            self.movieOutput.startRecordingToOutputFileURL(file, recordingDelegate: self)
        }
        else
        {
            dispatch_after(3, dispatch_get_main_queue(), { () -> Void in
                println("stopRecording")
                self.movieOutput.stopRecording()
                self.recorderDelegate.iosRecorderDidFinish(self.file!)
                self.file = nil
            })
        }
    }
    
    func startObservingIOSDevices(){
        // grab the ones already plugged in
        for foundDevice in AVCaptureDevice.devices() {
            println(foundDevice)
            if foundDevice.modelID! == "iOS Device" {
                let device = foundDevice as! AVCaptureDevice
                let deviceName = device.localizedName
                let uuid = device.uniqueID
                println("hello \(deviceName) aka \(uuid)")
                deviceFound(foundDevice)
            }
        }
        
        // then the ones that come and leave
        NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureDeviceWasDisconnectedNotification, object: nil, queue: nil) { (notif) -> Void in
            self.deviceLost(notif.object!)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureDeviceWasConnectedNotification, object: nil, queue: nil) { (notif) -> Void in
            self.deviceFound(notif.object!)
        }
    }
    
    func generateFilePath(prefix:String, type:String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMdd-HHmmSS"
        let datestamp = formatter.stringFromDate(NSDate())
        let filename = "\(prefix)\(datestamp).\(type)"
        let filePath = saveFilesInPath.stringByAppendingPathComponent(filename)
        println("### Filepath: \(filePath)")
        return filePath
    }
    
  
    
    func addStillImageOutput() {
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
    }
    func endSession(){}
    
    func deviceFound(device:AnyObject){
        println("devicefound, add to UI")
        delegate.iosDeviceAttached(device as! AVCaptureDevice)
    }
    
    func deviceLost(device:AnyObject){
        println("lostdevice")
        delegate.iosDeviceDetached(device as! AVCaptureDevice)
        endSession()
    }
    
    func makeDevicesVisible(){
        println("making visible")
        var prop = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))
        var allow : UInt32 = 1
        var dataSize : UInt32 = 4
        var zero : UInt32 = 0
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &prop, zero, nil, dataSize, &allow)
    }
    
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {

        recorderDelegate.iosRecorderDidEndPreparing()
        println("recording did start")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        if error == nil {
            println("------------------------- recording did end")
            }
        
        if error != nil {
            println("Recording ended in error")
            println(error)
            recorderDelegate.iosRecorderFailed(error.description, message: nil)
        }
    }
    
}
