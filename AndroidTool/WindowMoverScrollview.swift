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
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        Swift.print("mouse dragged in windowmoverscrollwview")
        super.mouseDragged(with: theEvent)
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        Swift.print("mouse up")
        super.mouseUp(with: theEvent)
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        Swift.print("mouse entered")
        super.mouseEntered(with: theEvent)
    }
    
}
