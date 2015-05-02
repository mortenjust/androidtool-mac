//
//  DeviceDiscoverer.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

protocol DeviceDiscovererDelegate {
    func devicesUpdated(deviceList:[Device])
}

class DeviceDiscoverer:NSObject {
    var delegate : DeviceDiscovererDelegate!
    var previousDevices = [Device]()
    var updatingSuspended = false
    var mainTimer : NSTimer!
    var updateInterval:NSTimeInterval = 3
    
    func getSerials(thenDoThis:(serials:[String]?, gotResults:Bool)->Void, finished:()->Void){
        ShellTasker(scriptFile: "getSerials").run() { (output) -> Void in
            let str = String(output)
            
            if count(str.utf16) < 2 {
                thenDoThis(serials: nil, gotResults: false)
                finished()
                return
            }

            let serials = split(str) { $0 == ";" }
            thenDoThis(serials: serials, gotResults:true)
            finished()
        }
    }

    func getDetailsForSerial(serial:String, complete:(details:[String:String])->Void){
        ShellTasker(scriptFile: "getDetailsForSerial").run(arguments: ["\(serial)"], isUserScript: false) { (output) -> Void in
            var detailsDict = self.getPropsFromString(output as String)
            complete(details:detailsDict)
        }
    }
    
    func pollDevices(){
        var newDevices = [Device]()
        
        if updatingSuspended { return }
        print("+")
        
        getSerials({ (serials, gotResults) -> Void in
            if gotResults {
                for serial in serials! {
                    self.getDetailsForSerial(serial, complete: { (details) -> Void in
                        let device = Device(properties: details, adbIdentifier:serial)
                        newDevices.append(device)
                        if serials!.count == newDevices.count {
                            self.delegate.devicesUpdated(newDevices)
                        }
                    })
                }
            } else {
                self.delegate.devicesUpdated(newDevices)
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
    
    func start(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "suspend", name: "suspendAdb", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unSuspend", name: "unSuspendAdb", object: nil)
        
        mainTimer = NSTimer.scheduledTimerWithTimeInterval(updateInterval, target: self, selector: "pollDevices", userInfo: nil, repeats: false)
        
//        NSRunLoop.currentRunLoop().addTimer(mainTimer, forMode: NSDefaultRunLoopMode)
        mainTimer.fire()
    }

    func stop(){}
    
    func getPropsFromString(string:String) -> [String:String] {
        let re = NSRegularExpression(pattern: "\\[(.+?)\\]: \\[(.+?)\\]", options: nil, error: nil)!
        let matches = re.matchesInString(string, options: nil, range: NSRange(location: 0, length: count(string.utf16)))
        
        var propDict = [String:String]()
        
        for match in matches as! [NSTextCheckingResult] {
            let key = (string as NSString).substringWithRange(match.rangeAtIndex(1))
            let value = (string as NSString).substringWithRange(match.rangeAtIndex(2))
            propDict[key] = value
        }
        return propDict
    }


}
