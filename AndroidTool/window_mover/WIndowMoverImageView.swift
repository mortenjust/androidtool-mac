//
//  WIndowMoverImageView.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/13/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class WindowMoverImageView: NSImageView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var mouseDownCanMoveWindow:Bool {
        return true
    }

    
    

}
