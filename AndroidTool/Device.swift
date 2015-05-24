//
//  Device.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import AVFoundation

protocol DeviceDelegate{
    //
}

enum DeviceType:String {
    case Phone="Phone", Watch="Watch", Tv="Tv", Auto="Auto"
}

enum DeviceOS {
    case Ios, Android
}

class Device: NSObject {

    var model : String?           // Nexus 6
    var name : String?              // Shamu
    var manufacturer : String?      // Motorola
    var type: DeviceType?
    var brand: String?              //  google
    var serial: String?
    var properties: [String:String]?
    var firstBoot : NSTimeInterval?
    var firstBootString : NSString?
    var adbIdentifier : String?
    var isEmulator : Bool = false
    var displayHeight : Int?
    var resolution : (width:Double, height:Double)?
    var deviceOS : DeviceOS!
    var uuid : String!
    var avDevice : AVCaptureDevice! // for iOS only
    
    convenience init(avDevice:AVCaptureDevice) {
        self.init()
        deviceOS = DeviceOS.Ios
        firstBoot = hashFromString(avDevice.uniqueID)
        brand = "Apple"
        name = avDevice.localizedName
        uuid = avDevice.uniqueID
        model = name
        self.avDevice = avDevice
    }
    
    convenience init(properties:[String:String], adbIdentifier:String) {
        self.init()
        
        deviceOS = .Android
        self.adbIdentifier = adbIdentifier.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        model = properties["ro.product.model"]
        name = properties["ro.product.name"]
        manufacturer = properties["ro.product.manufacturer"]
        brand = properties["ro.product.brand"]
        firstBootString = properties["ro.runtime.firstboot"]
        firstBoot = firstBootString?.doubleValue

        if let deviceSerial = properties["ro.serialno"]{
            serial = deviceSerial
        } else {
            isEmulator = true
            serial = adbIdentifier
        }
        
        if let characteristics = properties["ro.build.characteristics"] {
            if characteristics.rangeOfString("watch") != nil {
                type = DeviceType.Watch
            } else {
                type = DeviceType.Phone
            }
            }
        
        ShellTasker(scriptFile: "getResolutionForSerial").run(arguments: ["\(self.serial!)"], isUserScript: false) { (output) -> Void in
            let res = output as! String
            
            if res.rangeOfString("Physical size:") != nil {
                self.resolution = self.getResolutionFromString(output as! String)
            } else {
                println("Awkward. No size found. What I did find was \(res)")
            }

        }

    }
    
    func hashFromString(s:String) -> Double {
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
    
    func getResolutionFromString(string:String) -> (width:Double, height:Double) {
        let re = NSRegularExpression(pattern: "Physical size: (.*)x(.*)", options: nil, error: nil)!
        let matches = re.matchesInString(string, options: nil, range: NSRange(location: 0, length: count(string.utf16)))
        let result = matches[0] as! NSTextCheckingResult
        let width:NSString = (string as NSString).substringWithRange(result.rangeAtIndex(1))
        let height:NSString = (string as NSString).substringWithRange(result.rangeAtIndex(2))        
        let res = (width:width.doubleValue, height:height.doubleValue)
        return res
    }


}
