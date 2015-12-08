//
//  CameraButton.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 12/6/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class CameraButton: NSButton {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        unregisterDraggedTypes()
    }

    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
