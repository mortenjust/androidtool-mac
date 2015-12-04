//
//  DeviceDiscoverer.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import AVFoundation

protocol DeviceDiscovererDelegate {
    func devicesUpdated(deviceList:[Device])
}

class DeviceDiscoverer:NSObject, IOSDeviceDelegate {
    var delegate : DeviceDiscovererDelegate!
    var previousDevices = [Device]()
    var updatingSuspended = false
    var mainTimer : NSTimer!
    var updateInterval:NSTimeInterval = 3
    var iosDeviceHelper : IOSDeviceHelper!
    var iosDevices = [Device]()
    var androidDevices = [Device]()
    
    func start(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "suspend", name: "suspendAdb", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unSuspend", name: "unSuspendAdb", object: nil)
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(updateInterval, target: self, selector: "pollDevices", userInfo: nil, repeats: false)
        
        mainTimer.fire()
        
        /// start IOSDeviceHelper by instantiating
        iosDeviceHelper = IOSDeviceHelper(delegate: self)
        iosDeviceHelper.startObservingIOSDevices()        
    }
    
    func stop(){}
    
    func getSerials(thenDoThis:(serials:[String]?, gotResults:Bool)->Void, finished:()->Void){
        let task = ShellTasker(scriptFile: "getSerials")
        task.outputIsVerbose = true
        task.run() { (output) -> Void in
            let str = String(output)
            
            if str.utf16.count < 2 {
                thenDoThis(serials: nil, gotResults: false)
                finished()
                return
            }

            let serials = str.characters.split { $0 == ";" }.map { String($0) }
            thenDoThis(serials: serials, gotResults:true)
            finished()
        }
    }

    func getDetailsForSerial(serial:String, complete:(details:[String:String])->Void){
        print("getDetailsForSerial: \(serial)")
        let task = ShellTasker(scriptFile: "getDetailsForSerial")
        task.outputIsVerbose = true
        task.run(arguments: ["\(serial)"], isUserScript: false) { (output) -> Void in
            let detailsDict = self.getPropsFromString(output as String)
            complete(details:detailsDict)
        }
    }
    
    func pollDevices(){
        var newDevices = [Device]()
        
        if updatingSuspended { return }

        print("+", terminator: "")
        
        getSerials({ (serials, gotResults) -> Void in
            if gotResults {
                for serial in serials! {
                    self.getDetailsForSerial(serial, complete: { (details) -> Void in
                        let device = Device(properties: details, adbIdentifier:serial)
                        newDevices.append(device)
                        if serials!.count == newDevices.count {
                            self.newDeviceCollector(updateWithList: newDevices, forDeviceOS:.Android)
                        }
                    })
                }
            } else {
                self.newDeviceCollector(updateWithList: newDevices, forDeviceOS:.Android)
            }
        }, finished: { () -> Void in
            // not really doing anything here afterall
        })
    
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(updateInterval, target: self, selector: "pollDevices", userInfo: nil, repeats: false)
    }



    func suspend(){
        // some activites will break an open connection, an example is screen recording.
        updatingSuspended = true
    }
    
    func unSuspend(){
        updatingSuspended = false
    }
    
    
    func getPropsFromString(string:String) -> [String:String] {
        let re = try! NSRegularExpression(pattern: "\\[(.+?)\\]: \\[(.+?)\\]", options: [])
        let matches = re.matchesInString(string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        
        var propDict = [String:String]()
        
        for match in matches {
            let key = (string as NSString).substringWithRange(match.rangeAtIndex(1))
            let value = (string as NSString).substringWithRange(match.rangeAtIndex(2))
            propDict[key] = value
        }
        return propDict
    }
    
    func iosDeviceAttached(device:AVCaptureDevice){
        // instantiate new Device, check if we know it, add to iosDevices[], tell deviceCollector about it
        
        print("Found device \(device.localizedName)")
        let newDevice = Device(avDevice: device)
        var known = false
        for d in iosDevices {
            if d.uuid == newDevice.uuid {
                print("wtf, already exists")
                known = true
            }
        }

        if !known {
            iosDevices.append(newDevice)
            newDeviceCollector(updateWithList: iosDevices, forDeviceOS: .Ios)
            // tell deviceCollector to merge with Android device and fire an update
        }
    }
    
    func newDeviceCollector(updateWithList deviceList: [Device], forDeviceOS:DeviceOS){
        var allDevices = [Device]()
        
        // merge lists
        if forDeviceOS == .Android {
            androidDevices = deviceList
        }
        if forDeviceOS == .Ios {
            iosDevices = deviceList
        }
        
        allDevices = androidDevices + iosDevices
        delegate.devicesUpdated(allDevices)
    }
    
    func iosDeviceDetached(device:AVCaptureDevice){
        // find the lost device in iosDevices[], remove it, and tell newDeviceCollector about it
        for index in 0...(iosDevices.count-1) {
            if iosDevices[index].uuid == device.uniqueID {
                print("removing \(device.localizedName)")
                iosDevices.removeAtIndex(index)
                newDeviceCollector(updateWithList: iosDevices, forDeviceOS: .Ios)
            }
        }
    }

    func iosDeviceDidStartPreparing(device:AVCaptureDevice){
        // this happens when
    }
    func iosDeviceDidEndPreparing(){}

}