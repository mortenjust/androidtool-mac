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

protocol IOSDeviceDelegate {
    func iosDeviceAttached(device:AVCaptureDevice)
    func iosDeviceDetached(device:AVCaptureDevice)
    func iosDeviceDidStartPreparing(device:AVCaptureDevice)
    func iosDeviceDidEndPreparing()
}

class IOSDeviceHelper: NSObject, AVCaptureFileOutputRecordingDelegate {
    var session : AVCaptureSession!
    var movieOutput : AVCaptureMovieFileOutput!
    var stillImageOutput : AVCaptureStillImageOutput!
    var delegate : IOSDeviceDelegate!
    var input : AVCaptureDeviceInput!
    var saveFilesInPath : String!
    
    init(delegate: IOSDeviceDelegate){
        super.init()
        self.delegate = delegate
        session = AVCaptureSession()
        movieOutput = AVCaptureMovieFileOutput()
        
        registerNotifications()
        
        // TODO: A preference for this directory, which will then be default
        saveFilesInPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DesktopDirectory, .UserDomainMask, true)[0] as! String
        saveFilesInPath = saveFilesInPath.stringByAppendingPathComponent("AndroidTool")
        
        println("looking")
        makeDevicesVisible() // has to be right before calling these
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
    }
    
    func registerNotifications(){
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
    
    func toggleRecording(device : AVCaptureDevice){
        
        if !movieOutput.recording {
            
            println("$$$ start recording of device \(device.localizedName)")
            var err : NSError? = nil
            input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &err) as! AVCaptureDeviceInput
            
            session.addOutput(movieOutput)
            session.addInput(input)
            session.startRunning()
            
            let filePath = generateFilePath("iOS-recording-", type: "mov")
            let file = NSURL(fileURLWithPath: filePath)!
            
            delegate.iosDeviceDidStartPreparing(device)
            self.movieOutput.startRecordingToOutputFileURL(file, recordingDelegate: self)
            
        }
        else
        {
            println("stopRecording")
            self.movieOutput.stopRecording()
            
            dispatch_after(1, dispatch_get_main_queue(), { () -> Void in
                
                self.session.removeInput(self.input)
                self.session.stopRunning()
                self.session.removeOutput(self.movieOutput)
            })
        }
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
        //
        
        delegate.iosDeviceDidEndPreparing()
        println("recording did start")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        println("------------------------- recording did end")
        
        if error != nil {
            println(error)
        }
        
        
        
        //
    }
    
}
