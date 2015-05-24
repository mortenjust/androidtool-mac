//
//  AppDelegate.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var scriptsMenu: NSMenu!
    var preferencesWindowController: PreferencesWindowController!
    
    var masterViewController: MasterViewController!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        checkForUpdate()
        updateScriptFilesInMenu()
        checkForPreferences()
        
        if !Util().isMavericks() {        
            window.movableByWindowBackground = true
            window.titleVisibility = NSWindowTitleVisibility.Hidden
            window.titlebarAppearsTransparent = true;
            window.styleMask |= NSFullSizeContentViewWindowMask;
            }
        
        masterViewController = MasterViewController(nibName: "MasterViewController", bundle: nil)
        masterViewController.window = window
        
        window.contentView.addSubview(masterViewController.view)
        //masterViewController.view.frame = window.contentView.bounds
        
        var insertedView = masterViewController.view
        var containerView = window.contentView as! NSView
        
        insertedView.translatesAutoresizingMaskIntoConstraints = false

        let viewDict = ["inserted":insertedView, "container":containerView]
        let viewConstraintH = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[inserted]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: viewDict)
        let viewConstraintV = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[inserted]|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: viewDict)
        containerView.addConstraints(viewConstraintH)
        containerView.addConstraints(viewConstraintV)
        
        
    }

    func application(sender: NSApplication, openFile filename: String) -> Bool {
        println("opening \(filename). If it's an APK we'll show a list of devices")
        masterViewController.installApk(filename)
        return true
    }
    
    @IBAction func revealFolderClicked(sender: NSMenuItem) {
        Util().revealScriptsFolder()
    
    }

    
    func checkForPreferences(){
        var ud = NSUserDefaults.standardUserDefaults()
        
        let bitratePref = ud.doubleForKey("bitratePref")
        let scalePref = ud.doubleForKey("scalePref")

        println("bit: \(bitratePref)")
        
        
        if bitratePref == 0.0 {
            ud.setDouble(Double(3025000), forKey: "bitratePref")
        }
        
        if scalePref == 0.0 {
            ud.setDouble(1, forKey: "scalePref")
        }
    
    }
    
    
    // populate nsmenu with all scripts
    // run this script on all devices
    
    func updateScriptFilesInMenu(){
        scriptsMenu.removeAllItems()
        
        let screenshotItem = NSMenuItem(title: "Screenshots", action: "screenshotsOfAllTapped:", keyEquivalent: "S")
        let sepItem = NSMenuItem.separatorItem()
        let sepItem2 = NSMenuItem.separatorItem()
        let revealFolderItem = NSMenuItem(title: "Reveal Scripts Folder", action: "revealFolderClicked:", keyEquivalent: "F")

        scriptsMenu.addItem(screenshotItem)
        scriptsMenu.addItem(sepItem)
        
        var supportDir = Util().getSupportFolderScriptPath()
        var scriptFiles = Util().getFilesInScriptFolder(supportDir)!

        var i = 0
        for scriptFile in scriptFiles {

            // for scripts 0..9, add a keyboard shortcut
            var keyEq = ""
            if i<10 {
                keyEq = "\(i)"
                }
            let scriptItem = NSMenuItem(title: scriptFile.stringByReplacingOccurrencesOfString(".sh", withString: ""), action: "runScript:", keyEquivalent: keyEq)
            scriptsMenu.addItem(scriptItem)
            i++
            }
        
        scriptsMenu.addItem(sepItem2)
        scriptsMenu.addItem(revealFolderItem)
    }
    
    func runScript(sender:NSMenuItem){
        Util().stopRefreshingDeviceList()
        let scriptPath = "\(Util().getSupportFolderScriptPath())/\(sender.title).sh"
        println("ready to run \(scriptPath) on all Android devices")
        
        let deviceVCs = masterViewController.deviceVCs
        for deviceVC in deviceVCs {
            if deviceVC.device.deviceOS == DeviceOS.Android {
                let serial = deviceVC.device.serial!
                deviceVC.startProgressIndication()
                ShellTasker(scriptFile: scriptPath).run(arguments: ["\(serial)"], isUserScript: true) { (output) -> Void in
                        deviceVC.stopProgressIndication()
                }
            }
        }
        
        Util().restartRefreshingDeviceList()
    }
    
    @IBAction func screenshotsOfAllTapped(sender: NSMenuItem) { // TODO:clicked, not tapped
        Util().stopRefreshingDeviceList()
        let deviceVCs = masterViewController.deviceVCs
        for deviceVC in deviceVCs {
            deviceVC.takeScreenshot()
        }
        Util().restartRefreshingDeviceList()
    }
    
    func checkForUpdate(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let url = NSURL(string: "http://mortenjust.com/androidtool/latestversion")
            if let version = NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding, error: nil) {
            
            var nsu = NSUserDefaults.standardUserDefaults()
            let knowsAboutNewVersion = nsu.boolForKey("UserKnowsAboutNewVersion")
            
            dispatch_async(dispatch_get_main_queue()) {
                let currentVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
                if (currentVersion != version) && !knowsAboutNewVersion {
//                    var alert = NSAlert()
//                    alert.messageText = "An update is available! Go to mortenjust.com/androidtool to download"
//                    alert.runModal()
                    nsu.setObject(true, forKey: "UserKnowsAboutNewVersion")
                    }
                }
            }
        }
    }
    
    
    func applicationWillResignActive(notification: NSNotification) {
        masterViewController.discoverer.updateInterval = 120
    }
    
    @IBAction func refreshDeviceListClicked(sender: NSMenuItem) {
        masterViewController.discoverer.pollDevices()
    }

    @IBAction func showLogFileClicked(sender: NSMenuItem) {
        
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        println("pref")
        preferencesWindowController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        preferencesWindowController.showWindow(sender)

    }

    
    
    func applicationDidBecomeActive(notification: NSNotification) {
//        Util().restartRefreshingDeviceList()
        masterViewController.discoverer.updateInterval = 3
        updateScriptFilesInMenu()
        masterViewController.discoverer.pollDevices()
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

