//
//  WindowMoverView.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/12/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class WindowMoverView: NSView {
    
    override func register(forDraggedTypes newTypes: [String]) {
        Swift.print("$$ registering")
        let fileTypes = [
            ".apk"
        ]
        register(forDraggedTypes: fileTypes);
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        Swift.print("dragging entered")
        return NSDragOperation.copy
    }
    
    override func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var mouseDownCanMoveWindow:Bool {
        return true
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        Swift.print("mouse up windowmoverview")
        super.mouseUp(with: theEvent)
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        Swift.print("mouse entered windowmoverivew")
        super.mouseEntered(with: theEvent)
    }
    
}
