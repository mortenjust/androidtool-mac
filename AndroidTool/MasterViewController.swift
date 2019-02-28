//
//  MasterViewController.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class MasterViewController:
        NSViewController,
        DeviceDiscovererDelegate,
        NSTableViewDelegate,
        NSTableViewDataSource  {
    
    var devices = [Device]()
    var deviceVCs = [DeviceViewController]()
    var window : NSWindow!
    var previousSig:Double = 0
    
    @IBOutlet var emptyStateView: NSImageView!
    @IBOutlet weak var devicesTable: NSTableView!
    
    func installApk(_ apkPath:String){
        showDevicePicker(apkPath)
    }
    
    func showDevicePicker(_ apkPath:String){
        let devicePickerVC = DevicePickerViewController(
            nibName: "DevicePickerViewController",
            bundle: nil)
        devicePickerVC.devices = devices
        devicePickerVC.apkPath = apkPath
        
        if #available(OSX 10.10, *) {
            self.presentAsSheet(devicePickerVC)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return devices.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let deviceVC = DeviceViewController(device: devices[row])
        deviceVCs.append(deviceVC!) // save it from deallocation
        return deviceVC?.view
    }
    
    func deviceListSignature(_ deviceList:[Device]) -> Double {
        var signature = Double(deviceList.count)
        for device in deviceList {
            if let firstboot = device.firstBoot {
                signature += firstboot
            }
        }
        return signature
    }
    
    func showEmptyState(){
        // resize window
        if !emptyStateView.isDescendant(of: view) {
            emptyStateView.frame.origin.y = -15
            emptyStateView.frame.origin.x = 45
            view.addSubview(emptyStateView)
        }
    }
    
    func removeEmptyState(){
        emptyStateView.removeFromSuperview()
    }
    
    func devicesUpdated(_ deviceList: [Device]) {
        let newSig = deviceListSignature(deviceList)
        devices = deviceList
        
        if devices.count == 0 {
            previousSig = 0
            devicesTable.reloadData()
            showEmptyState()
        } else {
            removeEmptyState()
        }
        
        devices.sort(by: {$0.model < $1.model})
        // refresh each device with updated data like current activity
//        for deviceVC in deviceVCs {
//            for device in devices {
//                if deviceVC.device.adbIdentifier == device.adbIdentifier {
//                    deviceVC.device = device
//                    deviceVC.setStatusToCurrentActivity()
//                }
//            }
//        }
        
        // make sure we don't refresh the tableview when it's not necessary
        if newSig != previousSig  {
            
            // adjust window height accordingly
            let deviceHeight:CGFloat = 127
            var newHeight = deviceHeight
            if devices.count != 0 {
                newHeight = CGFloat(devices.count) * newHeight + 20
            } else {
                newHeight = 171 // emptystate height
            }
            changeWindowHeight(window, view: view, newHeight: newHeight)
            
            previousSig = newSig
            devicesTable.reloadData()
        }
    }

    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
    }
}
