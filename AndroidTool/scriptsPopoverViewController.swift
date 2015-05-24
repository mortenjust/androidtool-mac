//
//  scriptsPopoverViewController.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/26/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

@objc protocol UserScriptDelegate : class {
    func userScriptStarted()
    func userScriptEnded()
    func userScriptWantsSerial() -> String
}

class scriptsPopoverViewController: NSViewController {
    let buttonHeight:CGFloat = 30
    
    // accepted answer here http://stackoverflow.com/questions/26180268/interface-builder-iboutlet-and-protocols-for-delegate-and-datasource-in-swift
    @IBOutlet var delegate : UserScriptDelegate!
    
    let fileM = NSFileManager.defaultManager()

    func setup(){
        let folder = Util().getSupportFolderScriptPath()
        let allScripts = Util().getFilesInScriptFolder(folder)

        if allScripts?.count > 0 {
            addScriptsToView(allScripts!, view: self.view)
            }
    }
    
    
    func addScriptsToView(scripts:[String], view:NSView){
        var i:CGFloat = 1
        
        view.frame.size.height = CGFloat(scripts.count) * (buttonHeight+3) + buttonHeight

        let folderButton = NSButton(frame: NSRect(x: 10.0, y: 3,
            width: view.bounds.width-15.0,
            height: buttonHeight))
        folderButton.image = NSImage(named: "revealFolder")
        folderButton.bordered = false
        folderButton.action = "revealScriptFolderClicked:"
        folderButton.target = self
        view.addSubview(folderButton)
        
        for script in scripts {
            let scriptButton = NSButton(frame: NSRect(x: 10.0, y: (i*buttonHeight+3),
                                        width: view.bounds.width-15.0,
                                        height: buttonHeight))

            let friendlyScriptName = script.stringByReplacingOccurrencesOfString(".sh", withString: "")
            scriptButton.title = friendlyScriptName
            scriptButton.setButtonType(NSButtonType.AcceleratorButton)
            scriptButton.bezelStyle = NSBezelStyle.RoundedBezelStyle
            scriptButton.action = "runScriptClicked:"
            scriptButton.target = self
            
            view.addSubview(scriptButton)
            i++
        }
    }
    
    func runScript(scriptPath:String){
        delegate.userScriptStarted()
        let serial:String = delegate.userScriptWantsSerial()
        
        println("ready to run on \(serial)")
        
        ShellTasker(scriptFile: scriptPath).run(arguments: ["\(serial)"], isUserScript: true) { (output) -> Void in
            self.delegate.userScriptEnded()
        }
    }
    
    func runScriptClicked(sender:NSButton){
        let scriptName = "\(sender.title).sh"
        let scriptPath = "\(Util().getSupportFolderScriptPath())/\(scriptName)"
        println("ready to run \(scriptPath)")
        runScript(scriptPath)
    }
    
    func revealScriptFolderClicked(sender:NSButton) {
        Util().revealScriptsFolder()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func awakeFromNib() {
//        println("awake from nib-style")
        setup()
    }
    
    
}
