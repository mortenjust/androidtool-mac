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
    var apkPath: String?
    
    @IBOutlet weak var spinner: NSProgressIndicator!

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }

    @IBAction func cancelPressed(_ sender: AnyObject) {
        if #available(OSX 10.10, *) {
            self.dismiss(nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return devices.count
    }

    func installApkOnDevice(_ device:Device){
        let adbIdentifier = device.adbIdentifier!
        
        spinner.isHidden = false
        spinner.startAnimation(nil)
        
        guard let apkPath = apkPath else {
            Util
                .showNotification("APK Path wasn't set yet.",
                                    moreInfo: "")
            return
        }
        let args = ["\(adbIdentifier)",
                    "\(apkPath)"]
        
        ShellTasker(scriptFile: "installApkOnDevice").run(arguments: args) { (output) -> Void in

            Util.showNotification("App installed on \(device.readableIdentifier())", moreInfo: "\(output)", sound: true)
            if #available(OSX 10.10, *) {
                self.dismiss(nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        installApkOnDevice(devices[row])
        return true
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
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
