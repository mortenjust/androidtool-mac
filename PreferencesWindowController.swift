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
        selectFolder("Screenshots", message: "Save screenshots in this folder", defaultsPath: "screenshotsFolder")
    }

    @IBAction func screenRecordingFolderClicked(_ sender: AnyObject) {
        
        selectFolder("Screen recordings", message: "Save recordings in this folder", defaultsPath: "screenRecordingsFolder")
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // all bindings are belong to IB
    }
    
    
    
    func selectFolder(_ title:String, message:String, defaultsPath:String){
        let openPanel = NSOpenPanel();
        openPanel.title = title
        openPanel.message = message
        openPanel.showsResizeIndicator=true;
        openPanel.canChooseDirectories = true;
        openPanel.canChooseFiles = false;
        openPanel.allowsMultipleSelection = false;
        openPanel.canCreateDirectories = true;
        openPanel.begin { (result) -> Void in
            if(result == NSFileHandlingPanelOKButton){
                let path = openPanel.url!.path
                print("selected folder is \(path), saving to \(defaultsPath)");
                let ud = UserDefaults.standard
                ud.setValue(path, forKey: defaultsPath)
            }
        }
    }
    
}
