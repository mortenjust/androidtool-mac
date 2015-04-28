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
    
    
    func getSerials(thenDoThis:(serials:[String]?, gotResults:Bool)->Void, finished:()->Void){
        
        ShellTasker(scriptFile: "getSerials").run(arguments: "") { (output) -> Void in
//            println(output)
//            println("#got serials")            
            let str = String(output)
            
            if count(str.utf16) < 2 {
                thenDoThis(serials: nil, gotResults: false)
                finished()
                return
            }

            let serials = split(str) { $0 == ";" }
//            println("serials count is \(serials.count)")
            thenDoThis(serials: serials, gotResults:true)
            finished()
        }
    }

    func getDetailsForSerial(serial:String, complete:(details:[String:String])->Void){
        ShellTasker(scriptFile: "getDetailsForSerial").run(arguments: serial) { (output) -> Void in
            var detailsDict = self.getPropsFromString(output as String)
            complete(details:detailsDict)
        }
    }
    
    func pollDevices(timer: NSTimer){
        var newDevices = [Device]()

        if updatingSuspended { return }
        
        getSerials({ (serials, gotResults) -> Void in
            if gotResults {
                for serial in serials! {
                    self.getDetailsForSerial(serial, complete: { (details) -> Void in
                        let device = Device(properties: details)
                        newDevices.append(device)
                        
//                        println("adding this device, list is up to \(newDevices.count)")
                        
                        if serials!.count == newDevices.count {
                            self.delegate.devicesUpdated(newDevices)
                        }
                    })
                }
            } else {
//                println("No devices found. Doing nothing.")
                self.delegate.devicesUpdated(newDevices)
            }
        }, finished: { () -> Void in
            // not really doing anything here afterall
        })
    }
    

    func suspend(){
        // some activites will break an open connection, an example is screen recording.
        updatingSuspended = true
//        println("suspending updates")
    }
    
    func unSuspend(){
        updatingSuspended = false
//        println("releasing updates")
    }
    
    
    func start(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "suspend", name: "suspendAdb", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unSuspend", name: "unSuspendAdb", object: nil)
        
        let mainTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "pollDevices:", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(mainTimer, forMode: NSDefaultRunLoopMode)
        mainTimer.fire()
    }

    func stop(){}
    
    func getPropsFromString(string:String) -> [String:String] {
        let re = NSRegularExpression(pattern: "\\[(.+?)\\]: \\[(.+?)\\]", options: nil, error: nil)!
        let matches = re.matchesInString(string, options: nil, range: NSRange(location: 0, length: count(string.utf16)))
        
//        println("number of matches: \(matches.count)")
        
        var propDict = [String:String]()
        
        for match in matches as! [NSTextCheckingResult] {
            let key = (string as NSString).substringWithRange(match.rangeAtIndex(1))
            let value = (string as NSString).substringWithRange(match.rangeAtIndex(2))
            // println("key is \(key) and value is \(value)")
            propDict[key] = value
        }
        return propDict
    }


}
