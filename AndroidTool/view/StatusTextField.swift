//
//  StatusTextField.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/24/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class StatusTextField: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup(){
        wantsLayer = true
    }
    
    
    
    func animateIn(_ completion:@escaping ()->Void?){

        let moveTo = (layer?.frame.origin.y)! - 5
        let move = CABasicAnimation(keyPath: "position.y")
        move.toValue = moveTo
        move.duration = 0.2
        
        move.isRemovedOnCompletion = true
        move.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0
        fade.toValue = 1
        fade.duration = 0.2
        fade.isRemovedOnCompletion = true
        fade.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            completion()
        }
        
        layer?.add(fade, forKey: "basicOpacity")
        layer?.opacity = 1
        layer?.add(move, forKey: "basicMove")
        layer?.frame.origin.y = moveTo
        
        CATransaction.commit()
        

    }
    
    
    func animateOut(_ completion:@escaping ()->Void){
        let moveTo = (layer?.frame.origin.y)! + 5
        let move = CABasicAnimation(keyPath: "position.y")
        move.toValue = moveTo
        move.duration = 0.2
        move.isRemovedOnCompletion = true
        move.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1
        fade.toValue = 0
        fade.isRemovedOnCompletion = true
        fade.duration = 0.2
        fade.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            completion()
        }
        
        layer?.add(fade, forKey: "basicOpacity")
        layer?.opacity = 0
        layer?.add(move, forKey: "basicMove")
        layer?.frame.origin.y = moveTo
        
        CATransaction.commit()
    }
    

    func setText(_ text:String, shouldFadeOut:Bool = true){
        animateOut { () -> Void in
            self.stringValue = text
            
            if shouldFadeOut {
                self.animateIn { () -> Void? in
                    self.slowlyDecay()
                }
            }

        }
    }
    
    
    func slowlyDecay(){
        wantsLayer = true
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 1
        anim.toValue = 0
        anim.duration = 60 //* 5 // 5 mins
        self.layer?.add(anim, forKey: "opacity")
        alphaValue = 0
    }
    
}
