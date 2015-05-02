//
//  MasterViewController.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController, DeviceDiscovererDelegate, NSTableViewDelegate, NSTableViewDataSource  {
    
    var discoverer = DeviceDiscoverer()
    var devices : [Device]!
    var deviceVCs = [DeviceViewController]()
    var window : NSWindow!
    var previousSig:Double = 0
    
    @IBOutlet var emptyStateView: NSImageView!
    @IBOutlet weak var devicesTable: NSTableView!
    
    override func awakeFromNib() {
        discoverer.delegate = self
        devices = [Device]()
        discoverer.start()
    }
    
    
    func installApk(apkPath:String){
        showDevicePicker(apkPath)
    }

    
    func showDevicePicker(apkPath:String){
        var devicePickerVC = DevicePickerViewController(nibName: "DevicePickerViewController", bundle: nil)
        devicePickerVC?.devices = devices
        devicePickerVC?.apkPath = apkPath
        self.presentViewControllerAsSheet(devicePickerVC!)
    }


    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
//        println("asked number of rows")
        if devices == nil { return 0 }
        return devices.count
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let deviceVC = DeviceViewController(device: devices[row])
        deviceVCs.append(deviceVC!) // save it from deallocation
        return deviceVC?.view
    }
    
    func removeDevice(device:Device){
        
    }

    func fingerPrintForDeviceList(deviceList:[Device]) -> Double {
        var total:Double = 0
        for d in deviceList {
            total += d.firstBoot!
        }
        
        total = total/Double(deviceList.count)
        return total
    }
    
    func deviceListSignature(deviceList:[Device]) -> Double {
        var total:Double = 0
        for device in deviceList {
            if let firstboot = device.firstBoot {
                total += device.firstBoot!
                }
        }
        let signa = total/Double(deviceList.count)
        return signa
    }
    
    func showEmptyState(){
        // resize window 
        
        if !emptyStateView.isDescendantOf(view) {
            emptyStateView.frame.origin.y = -15
            emptyStateView.frame.origin.x = 45
            view.addSubview(emptyStateView)
            }
    }
    
    func removeEmptyState(){
        emptyStateView.removeFromSuperview()
    }
    
    func devicesUpdated(deviceList: [Device]) {
      
        let newSig = deviceListSignature(deviceList)
        
        if deviceList.count == 0 {
            previousSig=0
            devicesTable.reloadData()
            showEmptyState()
        } else {
            removeEmptyState()
        }
        
        // make sure we don't refresh the tableview when it's not necessary
        if newSig != previousSig {
            
            println("new sig")
        
            var et = devices
            var to = deviceList

            devices = deviceList
            devices.sort({$0.model < $1.model})
            devicesTable.reloadData()

            var newHeight=Util().deviceHeight

            // adjust window height accordingly
            if devices.count != 0 {
                newHeight = CGFloat(devices.count) * (Util().deviceHeight)
            } else {
                newHeight = 171 // emptystate height
            }
            Util().changeWindowHeight(window, view: self.view, newHeight: newHeight)
            previousSig = newSig
            }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
