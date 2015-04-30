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
        self.dismissController(nil)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return devices.count
    }

    func installApkOnDevice(device:Device){
        let serial = device.serial!
        
        var spinner = NSProgressIndicator(frame: view.bounds)
        spinner.style = NSProgressIndicatorStyle.SpinningStyle
        view.addSubview(spinner)
        spinner.startAnimation(self)
        
        ShellTasker(scriptFile: "installApkOnDevice").run(arguments: "\(serial) install -r \(apkPath)") { (output) -> Void in

            Util().showNotification("App installed on \(device.model)", moreInfo: "\(output)", sound: true)
            spinner.stopAnimation(self)
            self.dismissController(nil)
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
        println("devicescount: \(devices.count)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
