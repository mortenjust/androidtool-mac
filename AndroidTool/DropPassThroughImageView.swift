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
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
}
