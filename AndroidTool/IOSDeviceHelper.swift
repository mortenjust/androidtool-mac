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
    func iosRecorderDidStartPreparing(_ device:AVCaptureDevice)
    func iosRecorderDidEndPreparing()
    func iosRecorderDidFinish(_ outputFileURL: URL!)
    func iosRecorderFailed(_ title:String, message:String?)
}

protocol IOSDeviceDelegate {
    func iosDeviceAttached(_ device:AVCaptureDevice)
    func iosDeviceDetached(_ device:AVCaptureDevice)

}

class IOSDeviceHelper: NSObject, AVCaptureFileOutputRecordingDelegate {
    var session : AVCaptureSession!
    var movieOutput : AVCaptureMovieFileOutput!
    var stillImageOutput : AVCaptureStillImageOutput!
    var delegate : IOSDeviceDelegate!
    var recorderDelegate : IOSRecorderDelegate!
    var input : AVCaptureDeviceInput!
    var saveFilesInPath : String!
    var file : URL!
    
    // this class has two modes. One is a per-device instantiated recorder. The other is a discoverer of all iOS devices that are plugged in and out. The class should probably be split into two at one point.
    
    init(recorderDelegate:IOSRecorderDelegate, forDevice device: AVCaptureDevice){
        super.init()
        self.recorderDelegate = recorderDelegate
        setup()

        input = (try! AVCaptureDeviceInput(device: device))
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
        saveFilesInPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.desktopDirectory, .userDomainMask, true)[0]
        var saveFileUrl = URL(fileURLWithPath: saveFilesInPath)
        saveFileUrl = saveFileUrl.appendingPathComponent("AndroidTool")
        saveFilesInPath = saveFileUrl.path
        //saveFilesInPath = saveFilesInPath.stringByAppendingPathComponent("AndroidTool")
        print("looking")
        makeDevicesVisible() // has to be here to be able to discover iOS devices
    }
    
    
    func toggleRecording(_ device : AVCaptureDevice, previewView:NSView?=nil){
        if !movieOutput.isRecording {

            if previewView != nil {
                let layer = AVCaptureVideoPreviewLayer(session: session) as AVCaptureVideoPreviewLayer
                layer.frame = previewView!.bounds
                previewView!.layer?.addSublayer(layer)
                }
            
            print("$$$ start recording of device \(device.localizedName)")
            let filePath = generateFilePath("iOS-recording-", type: "mov")
            file = URL(fileURLWithPath: filePath)
            
            recorderDelegate.iosRecorderDidStartPreparing(device)
            self.movieOutput.startRecording(toOutputFileURL: file, recordingDelegate: self)
        }
        else
        {
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + DispatchTimeInterval.seconds(3),
                execute: { () -> Void in
                    print("stopRecording")
                    self.movieOutput.stopRecording()
                    self.recorderDelegate.iosRecorderDidFinish(self.file!)
                    self.file = nil
                })
        }
    }
    
    func startObservingIOSDevices(){
        // grab the ones already plugged in
        for foundDevice in AVCaptureDevice.devices() {
            print(foundDevice)
            if (foundDevice as AnyObject).modelID! == "iOS Device" {
                let device = foundDevice as! AVCaptureDevice
                let deviceName = device.localizedName
                let uuid = device.uniqueID
                print("hello \(deviceName!) aka \(uuid!)")
                deviceFound(foundDevice as AnyObject)
            }
        }
        
        // then the ones that come and leave
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureDeviceWasDisconnected, object: nil, queue: nil) { (notif) -> Void in
            self.deviceLost(notif.object! as AnyObject)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureDeviceWasConnected, object: nil, queue: nil) { (notif) -> Void in
            self.deviceFound(notif.object! as AnyObject)
        }
    }
    
    func generateFilePath(_ prefix:String, type:String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd-HHmmSS"
        let datestamp = formatter.string(from: Date())
        let filename = "\(prefix)\(datestamp).\(type)"
        let fileUrl = URL(fileURLWithPath: saveFilesInPath).appendingPathComponent(filename)
        let filePath = fileUrl.path
        //let filePath = saveFilesInPath.stringByAppendingPathComponent(filename)
        print("### Filepath: \(filePath)")
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
    
    func deviceFound(_ device:AnyObject){
        print("devicefound, add to UI")
        delegate.iosDeviceAttached(device as! AVCaptureDevice)
    }
    
    func deviceLost(_ device:AnyObject){
        print("lostdevice")
        delegate.iosDeviceDetached(device as! AVCaptureDevice)
        endSession()
    }
    
    func makeDevicesVisible(){
        print("making visible")
        var prop = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))
        var allow : UInt32 = 1
        let dataSize : UInt32 = 4
        let zero : UInt32 = 0
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &prop, zero, nil, dataSize, &allow)
    }
    
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {

        recorderDelegate.iosRecorderDidEndPreparing()
        print("recording did start")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        if error == nil {
            print("------------------------- recording did end")
            }
        
        if error != nil {
            print("Recording ended in error")
            print(error)
            recorderDelegate.iosRecorderFailed(error.localizedDescription, message: nil)
        }
    }
    
}
