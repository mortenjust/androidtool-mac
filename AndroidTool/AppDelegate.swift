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
    var rawOutputWindowController: RawOutputWindowController!
    
    
    var masterViewController: MasterViewController!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        updateScriptFilesInMenu()
        checkForPreferences()

    
        if #available(OSX 10.10, *) {
            window.titlebarAppearsTransparent = true
            window.styleMask = window.styleMask | NSFullSizeContentViewWindowMask;
        } else {
            // Fallback on earlier versions
        }
        window.movableByWindowBackground = true
        window.title = ""
        
        masterViewController = MasterViewController(nibName: "MasterViewController", bundle: nil)
        masterViewController.window = window
        
        window.contentView!.addSubview(masterViewController.view)
        //masterViewController.view.frame = window.contentView.bounds
        
        let insertedView = masterViewController.view
        let containerView = window.contentView as NSView!
        
        insertedView.translatesAutoresizingMaskIntoConstraints = false

        let viewDict = ["inserted":insertedView, "container":containerView]
        let viewConstraintH = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[inserted]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: viewDict)
        let viewConstraintV = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[inserted]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewDict)
        containerView.addConstraints(viewConstraintH)
        containerView.addConstraints(viewConstraintV)
        
        
    }

    func application(sender: NSApplication, openFile filename: String) -> Bool {
        print("opening \(filename). If it's an APK we'll show a list of devices")
        masterViewController.installApk(filename)
        return true
    }
    
    @IBAction func revealFolderClicked(sender: NSMenuItem) {
        Util().revealScriptsFolder()
    
    }

    
    func checkForPreferences(){
        let ud = NSUserDefaults.standardUserDefaults()
        ud.registerDefaults(Constants.defaultPrefValues)
        
        if ud.stringForKey(C.PREF_SCREENSHOTFOLDER) == "" {
            ud.setObject(NSString(string: "~/Desktop/AndroidTool").stringByExpandingTildeInPath, forKey: C.PREF_SCREENSHOTFOLDER)
        }
        if ud.stringForKey(C.PREF_SCREENRECORDINGSFOLDER) == "" {
            ud.setObject(NSString(string: "~/Desktop/AndroidTool").stringByExpandingTildeInPath, forKey: C.PREF_SCREENRECORDINGSFOLDER)
        }
        
        
        
        let bitratePref = ud.doubleForKey("bitratePref")
        let scalePref = ud.doubleForKey("scalePref")
        let timeValuePref = ud.stringForKey("timeValue")
        let dataTypePref = ud.stringForKey("dataType")

        
        print("bit: \(bitratePref)")
        
        if timeValuePref == "" {
            ud.setObject(Constants.defaultPrefValues["timeValue"], forKey: "timeValue")
        }
        
        if dataTypePref == "" {
            ud.setObject(Constants.defaultPrefValues["dataType"], forKey: "dataType")
        }
        
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
        
        let supportDir = Util().getSupportFolderScriptPath()
        let scriptFiles = Util().getFilesInScriptFolder(supportDir)!

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
        print("ready to run \(scriptPath) on all Android devices")
        
        let deviceVCs = masterViewController.deviceVCs
        for deviceVC in deviceVCs {
            if deviceVC.device.deviceOS == DeviceOS.Android {
                let adbIdentifier = deviceVC.device.adbIdentifier!
                deviceVC.startProgressIndication()
                ShellTasker(scriptFile: scriptPath).run(arguments: ["\(adbIdentifier)"], isUserScript: true) { (output) -> Void in
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
    
    func applicationWillResignActive(notification: NSNotification) {
        masterViewController.discoverer.updateInterval = 120
    }
    
    @IBAction func rawWindowClicked(sender: AnyObject) {
        rawOutputWindowController = RawOutputWindowController(windowNibName: "RawOutputWindowController")
        rawOutputWindowController.showWindow(sender)
    }  
    
    @IBAction func refreshDeviceListClicked(sender: NSMenuItem) {
        masterViewController.discoverer.pollDevices()
    }

    @IBAction func showLogFileClicked(sender: NSMenuItem) {
        
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        print("pref")
        preferencesWindowController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        preferencesWindowController.showWindow(sender)

    }

    
    
    func applicationDidBecomeActive(notification: NSNotification) {
//        Util().restartRefreshingDeviceList()
        
        if masterViewController == nil {
            applicationDidFinishLaunching(notification)
        }
        
        masterViewController.discoverer.updateInterval = 3
        updateScriptFilesInMenu()
        masterViewController.discoverer.pollDevices()
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

