//
//  WIndowMoverImageView.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/13/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class WindowMoverImageView: NSImageView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override var mouseDownCanMoveWindow:Bool {
        return true
    }

    
    

}