//
//  TerminalOutputTextView.swift
//  Shellpad/androidtool
//
//  Created by Morten Just Petersen on 11/1/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class TerminalOutputTextView: NSTextView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup(){
        Swift.print("TerminalOutputTextView")
        font = NSFont(name: "Courier", size: 12)
        backgroundColor = NSColor(red:0.231, green:0.216, blue:0.251, alpha:1)
        textColor = NSColor(red:0.392, green:0.294, blue:0.890, alpha:1)
        startListening()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    func startListening(){
        NSNotificationCenter.defaultCenter().addObserverForName(Constants.NOTIF_NEWDATA, object: nil, queue: nil) { (notif) -> Void in
            Swift.print("#mj.newData notif")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let s = notif.object as! String
                self.append(s)
                
            })
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(C.NOTIF_NEWDATAVERBOSE, object: nil, queue: nil) { (notif) -> Void in
            Swift.print("#mj.newData verbose notif")
            
            let wantsVerbose = NSUserDefaults.standardUserDefaults().boolForKey(C.VERBOSEOUTPUT)
            
            if wantsVerbose {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let s = notif.object as! String
                    
                    self.append(s)
                    
                })
            }
        }
        
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constants.NOTIF_COMMAND, object: nil, queue: nil) { (notif) -> Void in
            Swift.print("#mj.newData notif")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let s = notif.object as! String
                self.append("\n\n\(s)", atts: Styles().commandAtts())
            })
        }
        
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constants.NOTIF_COMMANDVERBOSE, object: nil, queue: nil) { (notif) -> Void in
            Swift.print("#mj.newDataverbose notif")
            let wantsVerbose = NSUserDefaults.standardUserDefaults().boolForKey(C.VERBOSEOUTPUT)
            if wantsVerbose {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let s = notif.object as! String
                    self.append("\n\n\(s)", atts: Styles().commandAtts())
                })
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constants.NOTIF_NEWSESSION, object: nil, queue: nil) { (notif) -> Void in
            Swift.print("#mj.newSession notif")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.newSession()
            })
        }
    }
    
    func newSession(){
        append("\n\n----\n\n")
    }
    
    func append(appended: String, atts:[String:AnyObject] = Styles().terminalAtts()) {
        let s = NSAttributedString(string: "\n"+appended, attributes: atts)
        self.textStorage?.appendAttributedString(s)
        self.scrollToEndOfDocument(nil)
    }
}
