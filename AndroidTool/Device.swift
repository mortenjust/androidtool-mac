//
//  Device.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

protocol DeviceDelegate{
    //
}

enum DeviceType:String {
    case Phone="Phone", Watch="Watch", Tv="Tv", Auto="Auto"
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
    
    
    init(properties:[String:String], adbIdentifier:String) {
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
            return "Android device"
        }
    }


}
