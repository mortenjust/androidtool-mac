//
//  WindowMoverView.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/12/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class WindowMoverView: NSView {
    
    override func registerForDraggedTypes(newTypes: [String]) {
        Swift.print("$$ registering")
        let fileTypes = [
            ".apk"
        ]
        registerForDraggedTypes(fileTypes);
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        Swift.print("dragging entered")
        return NSDragOperation.Copy
    }
    
    override func acceptsFirstMouse(theEvent: NSEvent?) -> Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override var mouseDownCanMoveWindow:Bool {
        return true
    }
    
    override func mouseUp(theEvent: NSEvent) {
        Swift.print("mouse up windowmoverview")
        super.mouseUp(theEvent)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        Swift.print("mouse entered windowmoverivew")
        super.mouseEntered(theEvent)
    }
    
}
