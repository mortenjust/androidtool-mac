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
    var discoverer: DeviceDiscoverer!
    var preferencesWindowController: PreferencesWindowController!
    var rawOutputWindowController: RawOutputWindowController?
    
    var masterViewController: MasterViewController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        discoverer = DeviceDiscoverer()
        updateScriptFilesInMenu()
        checkForPreferences()

        if #available(OSX 10.10, *) {
            window.titlebarAppearsTransparent = true
            window.styleMask.update(with: NSWindow.StyleMask.fullSizeContentView);
        } else {
            // Fallback on earlier versions
        }
        window.isMovableByWindowBackground = true
        window.title = ""
        
        masterViewController = MasterViewController(
            nibName: "MasterViewController",
            bundle: nil)
        masterViewController.window = window
        
        window.contentView!.addSubview(masterViewController.view)
        //masterViewController.view.frame = window.contentView.bounds
        
        let insertedView = masterViewController.view
        let containerView = window.contentView!
        
        insertedView.translatesAutoresizingMaskIntoConstraints = false

        let viewDict: [String: Any] = ["inserted":insertedView, "container":containerView]
        let viewConstraintH = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[inserted]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: viewDict)
        let viewConstraintV = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[inserted]|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: viewDict)
        containerView.addConstraints(viewConstraintH)
        containerView.addConstraints(viewConstraintV)
        
        discoverer.delegate = masterViewController
        discoverer.start()
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        print("opening \(filename). If it's an APK we'll show a list of devices")
        masterViewController.installApk(filename)
        return true
    }
    
    @IBAction func revealFolderClicked(_ sender: NSMenuItem) {
        filesystem.revealScriptsFolder()
    }
    
    func checkForPreferences(){
        let ud = UserDefaults.standard
        ud.register(defaults: Constants.defaultPrefValues)
        
        if ud.string(forKey: C.PREF_SCREENSHOTFOLDER) == "" {
            ud.set(NSString(string: "~/Desktop/AndroidTool").expandingTildeInPath, forKey: C.PREF_SCREENSHOTFOLDER)
        }
        if ud.string(forKey: C.PREF_SCREENRECORDINGSFOLDER) == "" {
            ud.set(NSString(string: "~/Desktop/AndroidTool").expandingTildeInPath, forKey: C.PREF_SCREENRECORDINGSFOLDER)
        }
        
        let bitratePref = ud.double(forKey: C.PREF_BIT_RATE)
        let scalePref = ud.double(forKey: C.PREF_SCALE)
        let timeValuePref = ud.string(forKey: C.PREF_TIME_VALUE)
        let dataTypePref = ud.string(forKey: C.PREF_DATA_TYPE)

        print("bit: \(bitratePref)")
        
        if timeValuePref == "" {
            ud.set(Constants.defaultPrefValues[C.PREF_TIME_VALUE], forKey: C.PREF_TIME_VALUE)
        }
        
        if dataTypePref == "" {
            ud.set(Constants.defaultPrefValues[C.PREF_DATA_TYPE], forKey: C.PREF_DATA_TYPE)
        }
        
        if bitratePref == 0.0 {
            ud.set(Double(3025000), forKey: C.PREF_BIT_RATE)
        }
        
        if scalePref == 0.0 {
            ud.set(1, forKey: C.PREF_SCALE)
        }
    }
    
    // populate nsmenu with all scripts
    // run this script on all devices
    func updateScriptFilesInMenu(){
        scriptsMenu.removeAllItems()
        
        let screenshotItem = NSMenuItem(
            title: "Screenshots",
            action: #selector(screenshotsOfAllTapped),
            keyEquivalent: "S")
        let sepItem = NSMenuItem.separator()
        let sepItem2 = NSMenuItem.separator()
        let revealFolderItem = NSMenuItem(
            title: "Reveal Scripts Folder",
            action: #selector(revealFolderClicked),
            keyEquivalent: "F")

        scriptsMenu.addItem(screenshotItem)
        scriptsMenu.addItem(sepItem)
        
        try? filesystem.setUpSupportFolderScriptPath()
        let supportDir = filesystem.supportFolderScriptPath()
        let scriptFiles = filesystem.scriptsInScriptFolder(supportDir)

        for (i, scriptFile) in scriptFiles.enumerated() {
            // for scripts 0..9, add a keyboard shortcut
            var keyEq = ""
            if i<10 {
                keyEq = "\(i)"
            }
            let scriptItem = NSMenuItem(
                title: scriptFile.replacingOccurrences(of: ".sh", with: ""),
                action: #selector(runScript),
                keyEquivalent: keyEq)
            scriptsMenu.addItem(scriptItem)
        }
        
        scriptsMenu.addItem(sepItem2)
        scriptsMenu.addItem(revealFolderItem)
    }
    
    @objc func runScript(_ sender:NSMenuItem){
        DeviceList.stopRefreshing()
        let scriptPath = "\(filesystem.supportFolderScriptPath())/\(sender.title).sh"
        print("ready to run \(scriptPath) on all Android devices")
        
        let deviceVCs = masterViewController.deviceVCs
        for deviceVC in deviceVCs {
            if deviceVC.device.deviceOS == DeviceOS.android {
                let adbIdentifier = deviceVC.device.adbIdentifier!
                deviceVC.startProgressIndication()
                ShellTasker(scriptFile: scriptPath).run(arguments: ["\(adbIdentifier)"], isUserScript: true) { (output) -> Void in
                        deviceVC.stopProgressIndication()
                }
            }
        }
        DeviceList.restartRefreshing()
    }
    
    @IBAction func screenshotsOfAllTapped(_ sender: NSMenuItem) { // TODO:clicked, not tapped
        DeviceList.stopRefreshing()
        let deviceVCs = masterViewController.deviceVCs
        for deviceVC in deviceVCs {
            deviceVC.takeScreenshot()
        }
        DeviceList.restartRefreshing()
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        discoverer.updateInterval = 120
    }
    
    @IBAction func shouldOpenTerminalOutputWindow(_ sender: AnyObject) {
        var controller = rawOutputWindowController
        if controller == nil {
            controller = RawOutputWindowController(windowNibName:
                "RawOutputWindowController")
            rawOutputWindowController = controller
        }
        controller?.showWindow(sender)
    }
    
    @IBAction func refreshDeviceListClicked(_ sender: NSMenuItem) {
        discoverer.pollDevices()
    }

    @IBAction func showLogFileClicked(_ sender: NSMenuItem) {
        
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        print("pref")
        preferencesWindowController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        preferencesWindowController.showWindow(sender)
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        updateScriptFilesInMenu()
        discoverer.updateInterval = 3
        discoverer.pollDevices()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if (!window.isVisible) {
            window.setIsVisible(true)
            return true
        }
        return false
    }
}

