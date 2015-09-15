//
//  previewPopoverViewController.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 5/9/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class previewPopoverViewController: NSViewController {

    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
        // Do view setup here.
    }
    
}
