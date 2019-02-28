//
//  Device.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import AVFoundation

enum DeviceType:String {
    case Phone="Phone", Watch="Watch", Tv="Tv", Auto="Auto"
}

enum DeviceOS {
    case ios, android
}

class Device: NSObject {

    var model : String?           // Nexus 6
    var name : String?              // Shamu
    var manufacturer : String?      // Motorola
    var type: DeviceType?
    var brand: String?              //  google
    var serial: String?
    var properties: [String:String]?
    var firstBoot : TimeInterval?
    var firstBootString : String?
    var adbIdentifier : String?
    var isEmulator : Bool = false
    var displayHeight : Int?
    var resolution : (width:Double, height:Double)?
    var deviceOS : DeviceOS!
    var uuid : String!
    var avDevice : AVCaptureDevice! // for iOS only
    var currentActivity : String = ""
    
    convenience init(avDevice:AVCaptureDevice) {
        self.init(deviceOS: .ios)
        firstBoot = hashFromString(avDevice.uniqueID)
        brand = "Apple"
        name = avDevice.localizedName
        uuid = avDevice.uniqueID
        model = name
        self.avDevice = avDevice
    }
    
    convenience init(properties:[String:String], adbIdentifier:String) {
        self.init(deviceOS: .android)
        
        self.adbIdentifier = adbIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        
        model = properties["ro.product.model"]
        name = properties["ro.product.name"]
        manufacturer = properties["ro.product.manufacturer"]
        brand = properties["ro.product.brand"]
        firstBootString = properties["ro.runtime.firstboot"]
        if let fbs = firstBootString {
            firstBoot = TimeInterval(fbs)
        }
        if let deviceSerial = properties["ro.serialno"]{
            serial = deviceSerial
        } else {
            isEmulator = true
            serial = adbIdentifier
        }
        
        if let characteristics = properties["ro.build.characteristics"] {
            if characteristics.range(of: "watch") != nil {
                type = DeviceType.Watch
            } else {
                type = DeviceType.Phone
            }
        }
        
        let task = ShellTasker(scriptFile: "getResolutionForSerial")
        task.outputIsVerbose = true
        task.run(arguments: ["\(self.adbIdentifier!)"], isUserScript: false) { (output) -> Void in
            let res = output as String
            if res.range(of: "Physical size:") != nil {
                self.resolution = self.getResolutionFromString(output as String)
            } else {
                print("Awkward. No size found. What I did find was \(res)")
            }
        }
    }
    
    init(deviceOS: DeviceOS) {
        self.deviceOS = deviceOS
    }
    
    
    func getCurrentActivity(_ completion:@escaping (_ activityName:String)->Void){
        let task = ShellTasker(scriptFile: "getCurrentActivityForIdentifier")
        task.outputIsVerbose = true
        task.run(arguments: ["\(self.adbIdentifier!)"], isUserScript: false, isIOS: false) { (output) -> Void in
            let res = output as String
            self.currentActivity = res
            completion(res)
        }

    }
    
    func hashFromString(_ s:String) -> Double {
        return Double(abs((s as NSString).hash))
    }
    
    func readableIdentifier() -> String {
        if let modelString = model {
            return modelString
        } else if let nameString = name {
            return nameString
        } else if let manufacturerString = manufacturer {
            return manufacturerString
        } else if let serialString = serial {
            return serialString
        } else {
            return "Mobile device"
        }
    }
    
    func getResolutionFromString(_ string:String) -> (width:Double, height:Double) {
        let re = try! NSRegularExpression(pattern: "Physical size: (.*)x(.*)", options: [])
        let matches = re.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        let result = matches[0] 
        let width:NSString = (string as NSString).substring(with: result.range(at: 1)) as NSString
        let height:NSString = (string as NSString).substring(with: result.range(at: 2)) as NSString        
        let res = (width:width.doubleValue, height:height.doubleValue)
        return res
    }
}
