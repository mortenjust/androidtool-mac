//
//  WindowMoverTableCellView.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/12/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class WindowMoverTableCellView: NSTableCellView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override var mouseDownCanMoveWindow:Bool {
        return true
    }
    
    override func mouseUp(theEvent: NSEvent) {
        Swift.print("mouse up")
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        Swift.print("mouse entered")
    }
    
}
