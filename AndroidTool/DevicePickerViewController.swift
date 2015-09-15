//
//  DevicePickerViewController.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/24/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa


class DevicePickerViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var deviceTable: NSTableView!

    var devices : [Device]!
    var apkPath: String!

    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }

    @IBAction func cancelPressed(sender: AnyObject) {
        if #available(OSX 10.10, *) {
            self.dismissController(nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return devices.count
    }

    func installApkOnDevice(device:Device){
        let adbIdentifier = device.adbIdentifier!
        
        for subview in view.subviews {
            let s = subview 
            s.removeFromSuperview()
        }
        
        let spinner = NSProgressIndicator(frame: view.bounds)
        spinner.style = NSProgressIndicatorStyle.SpinningStyle
        spinner.frame.origin.x = view.bounds.maxX/2 - spinner.bounds.size.width/2
        
        let args = ["\(adbIdentifier)",
                    "\(apkPath)"]
        
        //["\(serial) install -r \"\(apkPath)\""]
        
        ShellTasker(scriptFile: "installApkOnDevice").run(arguments: args) { (output) -> Void in

            Util().showNotification("App installed on \(device.readableIdentifier())", moreInfo: "\(output)", sound: true)
            spinner.removeFromSuperview()
            if #available(OSX 10.10, *) {
                self.dismissController(nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        installApkOnDevice(devices[row])
        return true
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return devices[row].model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        deviceTable.reloadData()
        print("devicescount: \(devices.count)")
    }
    
    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
        // Do view setup here.
    }
    
}
