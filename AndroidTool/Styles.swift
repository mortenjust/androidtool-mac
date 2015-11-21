//
//  Styles.swift
//  Shellpad/androidtool
//
//  Created by Morten Just Petersen on 10/31/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class Styles: NSObject {
    
    override init() {
        super.init()
    }
    
    func terminalAtts() -> [String:AnyObject]{
        var atts = [String:AnyObject]()
        atts[NSForegroundColorAttributeName] = NSColor(red:0.671, green:0.671, blue:0.671, alpha:1)
        atts[NSFontAttributeName] = NSFont(name: "Monaco", size: 8.0)
        return atts
    }
    
    func commandAtts() -> [String:AnyObject]{
        var atts = [String:AnyObject]()
        atts[NSForegroundColorAttributeName] = NSColor(red:1, green:1, blue:1, alpha:1)
        atts[NSFontAttributeName] = NSFont(name: "Monaco", size: 8.0);
        return atts
    }
}
