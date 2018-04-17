//
//  PreferencesWindowController.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 5/1/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    @IBAction func screenshotFolderClicked(_ sender: AnyObject) {
        selectFolder(
            title: "Screenshots",
            message: "Save screenshots in this folder",
            defaultsPath: C.PREF_SCREENSHOTFOLDER)
    }

    @IBAction func screenRecordingFolderClicked(_ sender: AnyObject) {
        selectFolder(
            title: "Screen recordings",
            message: "Save recordings in this folder",
            defaultsPath: C.PREF_SCREENRECORDINGSFOLDER)
    }
    
    @IBAction func androidSdkRootFolderClicked(_ sender: AnyObject) {
        selectFolder(
            title: "Android SDK Root",
            message: "Use this path for Android SDK Root",
            defaultsPath: C.PREF_ANDROID_SDK_ROOT,
            showHiddenFiles: true)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // all bindings are belong to IB
    }
    
    func selectFolder(
            title:String,
            message:String,
            defaultsPath:String,
            showHiddenFiles: Bool = false){
        let openPanel = NSOpenPanel();
        openPanel.title = title
        openPanel.message = message
        openPanel.showsHiddenFiles = showHiddenFiles
        openPanel.showsResizeIndicator=true;
        openPanel.canChooseDirectories = true;
        openPanel.canChooseFiles = false;
        openPanel.allowsMultipleSelection = false;
        openPanel.canCreateDirectories = true;
        openPanel.begin { (result) -> Void in
            if(result.rawValue == NSFileHandlingPanelOKButton){
                let path = openPanel.url!.path
                print("selected folder is \(path), saving to \(defaultsPath)");
                let ud = UserDefaults.standard
                ud.setValue(path, forKey: defaultsPath)
            }
        }
    }
}
