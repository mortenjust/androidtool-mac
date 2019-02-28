//
//  scriptsPopoverViewController.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/26/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc protocol UserScriptDelegate : class {
    func userScriptStarted()
    func userScriptEnded()
    func userScriptWantsSerial() -> String
}

class scriptsPopoverViewController: NSViewController {
    let buttonHeight:CGFloat = 30
    
    // accepted answer here http://stackoverflow.com/questions/26180268/interface-builder-iboutlet-and-protocols-for-delegate-and-datasource-in-swift
    @IBOutlet var delegate : UserScriptDelegate!
    
    func setup(){
        let folder = filesystem.supportFolderScriptPath()
        let allScripts = filesystem.scriptsInScriptFolder(folder)

        if allScripts.count > 0 {
            addScriptsToView(allScripts, view: view)
        }
    }
    
    func addScriptsToView(_ scripts:[String], view:NSView){
        var i:CGFloat = 1
        
        view.frame.size.height = CGFloat(scripts.count) * (buttonHeight+3) + buttonHeight

        let folderButton = NSButton(frame: NSRect(x: 10.0, y: 3,
            width: view.bounds.width-15.0,
            height: buttonHeight))
        folderButton.image = NSImage(named: "revealFolder")
        folderButton.isBordered = false
        folderButton.action = #selector(revealScriptFolderClicked)
        folderButton.target = self
        view.addSubview(folderButton)
        
        for script in scripts {
            let scriptButton = NSButton(frame: NSRect(x: 10.0, y: (i*buttonHeight+3),
                                        width: view.bounds.width-15.0,
                                        height: buttonHeight))

            let friendlyScriptName = script.replacingOccurrences(of: ".sh", with: "")
            scriptButton.title = friendlyScriptName
            if #available(OSX 10.10.3, *) {
                scriptButton.setButtonType(NSButton.ButtonType.accelerator)
            } else {
                // Fallback on earlier versions
            }
            scriptButton.bezelStyle = NSButton.BezelStyle.rounded
            scriptButton.action = #selector(runScriptClicked)
            scriptButton.target = self
            
            view.addSubview(scriptButton)
            i += 1
        }
    }
    
    func runScript(_ scriptPath:String){
        delegate.userScriptStarted()
        let serial:String = delegate.userScriptWantsSerial()
        
        print("ready to run on \(serial)")
        
        ShellTasker(scriptFile: scriptPath).run(arguments: ["\(serial)"], isUserScript: true) { (output) -> Void in
            self.delegate.userScriptEnded()
        }
    }
    
    @objc func runScriptClicked(_ sender:NSButton){
        let scriptName = "\(sender.title).sh"
        let scriptPath = "\(filesystem.supportFolderScriptPath())/\(scriptName)"
        print("ready to run \(scriptPath)")
        runScript(scriptPath)
    }
    
    @objc func revealScriptFolderClicked(_ sender:NSButton) {
        filesystem.revealScriptsFolder()
    }
    
    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
        // Do view setup here.
    }
    
    override func awakeFromNib() {
        setup()
    }
}
