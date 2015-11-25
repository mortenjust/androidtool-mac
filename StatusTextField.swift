//
//  StatusTextField.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/24/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class StatusTextField: NSTextField {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    func prepareForNewStatus(){
        self.alphaValue = 1
    }
    
    func setText(text:String){
        self.stringValue = text
        slowlyDecay()
    }
    
    
    func slowlyDecay(){
        wantsLayer = true
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 1
        anim.toValue = 0
        anim.duration = 60 //* 5 // 5 mins
        self.layer?.addAnimation(anim, forKey: "opacity")
        alphaValue = 0
    }
    
}
