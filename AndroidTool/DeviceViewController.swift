//
//  DeviceViewController.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class DeviceViewController: NSViewController, NSPopoverDelegate, UserScriptDelegate {
    var device : Device!
    @IBOutlet weak var deviceNameField: NSTextField!
    @IBOutlet  var cameraButton: NSButton!
    @IBOutlet weak var deviceImage: NSImageView!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var videoButton: NSButton!
    @IBOutlet weak var moreButton: NSButton!
    
    @IBOutlet var scriptsPopover: NSPopover!
    
    
    var shellTasker : ShellTasker!
    var isRecording = false
    var moreOpen = false
    var moreShouldClose = false
    
    func takeScreenshot(){
        self.startProgressIndication()
        
        if device.deviceOS == DeviceOS.Android {
        
            ShellTasker(scriptFile: "takeScreenshotOfDeviceWithSerial").run(arguments: [device.serial!]) { (output) -> Void in
                self.stopProgressIndication()
                Util().showNotification("Screenshot ready", moreInfo: "", sound: true)
            }
        }
            
        if device.deviceOS == DeviceOS.Ios {
            println("IOS screenshot")
            
            
            ShellTasker(scriptFile: "takeScreenshotOfDeviceWithUUID").run(arguments: [device.uuid!], isUserScript: false, isIOS: true, complete: { (output) -> Void in
                self.stopProgressIndication()
                Util().showNotification("Screenshot ready", moreInfo: "", sound: true)
            })
            
        }
    }
    
    @IBAction func cameraClicked(sender: NSButton) {
        takeScreenshot()
    }

    func userScriptEnded() {
        stopProgressIndication()
        Util().restartRefreshingDeviceList()
    }
    
    func userScriptStarted() {
        startProgressIndication()
        Util().stopRefreshingDeviceList()
    }
    
    func userScriptWantsSerial() -> String {
        return device.serial!
    }
    
    func popoverDidClose(notification: NSNotification) {
        Util().restartRefreshingDeviceList()
        moreOpen = false
    }

    @IBAction func moreClicked(sender: NSButton) {
        Util().stopRefreshingDeviceList()
        if !moreOpen{
            moreOpen = true
            scriptsPopover.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: 2)
            }
    }
    
    func startRecording(){
        Util().stopRefreshingDeviceList()
        isRecording = true
        cameraButton.enabled = false
        moreButton.enabled = false
        let restingButton = videoButton.image
        videoButton.image = NSImage(named: "stopButton")
        
        shellTasker = ShellTasker(scriptFile: "startRecordingForSerial")
        
        var scalePref = NSUserDefaults.standardUserDefaults().doubleForKey("scalePref")
        var bitratePref = Int(NSUserDefaults.standardUserDefaults().doubleForKey("bitratePref"))
        
        // get phone's resolution, multiply with user preference for screencap size (either 1 or lower)
        var res = device.resolution!

        if device.type == DeviceType.Phone {
            res = (device.resolution!.width*scalePref, device.resolution!.height*scalePref)
            }
        
        let args:[String] = [device.serial!, "\(Int(res.width))", "\(Int(res.height))", "\(bitratePref)"]
        
        shellTasker.run(arguments: args) { (output) -> Void in
            
            println("-----")
            println(output)
            println("-----")
            
            self.startProgressIndication()
            self.cameraButton.enabled = true
            self.moreButton.enabled = true
            self.videoButton.image = restingButton
            var postProcessTask = ShellTasker(scriptFile: "postProcessMovieForSerial")
            let postArgs = ["\(self.device.serial!)", "\(Int(res.width))", "\(Int(res.height))"]
            postProcessTask.run(arguments: args, complete: { (output) -> Void in
                Util().showNotification("Your recording is ready", moreInfo: "", sound: true)
                self.stopProgressIndication()
            })
        }
    }
    
    func stopRecording(){
        Util().restartRefreshingDeviceList()
        isRecording = false
        shellTasker.stop() // terminates script and fires the closure in startRecordingForSerial
    }
    
    @IBAction func videoClicked(sender: NSButton) {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    init?(device _device:Device){
        device = _device
        super.init(nibName: "DeviceViewController", bundle: nil)
        setup()
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(){
//        println("setting up view for \(device.name!)")
        
        
    }
    
    func startProgressIndication(){
        progressBar.usesThreadedAnimation = true
        progressBar.startAnimation(nil)
    }
    
    func stopProgressIndication(){
        progressBar.stopAnimation(nil)
    }
    
    override func awakeFromNib() {
        deviceNameField.stringValue = device.model!
        let brandName = device.brand!.lowercaseString
        deviceImage.image = NSImage(named: "logo\(brandName)")
        
        if device.isEmulator {
            cameraButton.enabled = false
            videoButton.enabled = false
            
            deviceNameField.stringValue = "Emulator"
        }
        
        // only enable video recording if we have resolution, which is a bit slow because it comes from a big call
        videoButton.enabled = false
        enableVideoButtonWhenReady()
    }
    
    func startWaitingForAndroidVideoReady(){
        if device.resolution != nil {
            println("not nil")
            videoButton.enabled = true
        } else {
            println("is nil")
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "enableVideoButtonWhenReady", userInfo: nil, repeats: false)
        }
    }
        
    func enableVideoButtonWhenReady(){
        switch device.deviceOS! {
        case .Android:
            startWaitingForAndroidVideoReady()
        case .Ios:
            videoButton.hidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}
