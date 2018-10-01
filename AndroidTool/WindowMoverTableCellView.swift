//
//  WindowMoverTableCellView.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/12/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class WindowMoverTableCellView: NSTableCellView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override var mouseDownCanMoveWindow:Bool {
        return true
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        Swift.print("mouse up")
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        Swift.print("mouse entered")
    }
    
}
