//
//  DropPassThroughImageView.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 12/6/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class DropPassThroughImageView: NSImageView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup(){
        unregisterDraggedTypes()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
}
