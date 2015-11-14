//
//  WindowMoverScrollview.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/12/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class WindowMoverScrollview: NSScrollView {
    
    
    override var mouseDownCanMoveWindow:Bool {
        return true
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        Swift.print("mouse dragged in windowmoverscrollwview")
        super.mouseDragged(theEvent)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        Swift.print("mouse up")
        super.mouseUp(theEvent)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        Swift.print("mouse entered")
        super.mouseEntered(theEvent)
    }
    
}
