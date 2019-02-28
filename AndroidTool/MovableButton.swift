//
//  MovableButton.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 12/6/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class MovableButton: NSButton {
    
    func moveUpBy(_ y:CGFloat, delaySeconds:CFTimeInterval=0){
        self.layer?.removeAllAnimations()
        let moveTo:CGFloat = (layer?.position.y)! + y
        let move = CABasicAnimation(keyPath: "position.y")
        move.duration = 1
        move.beginTime = CACurrentMediaTime() + delaySeconds
        move.toValue = moveTo
        move.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.frame.origin.y = (self.layer?.position.y)! + y
        }
        
        layer?.add(move, forKey: "moveUp")
        CATransaction.commit()
    }
    
    func moveDownBy(_ y:CGFloat, delaySeconds:CFTimeInterval=0){
        self.layer?.removeAllAnimations()
        let moveTo:CGFloat = (layer?.position.y)! - y
        let move = CABasicAnimation(keyPath: "position.y")
        move.duration = 1
        move.beginTime = CACurrentMediaTime() + delaySeconds
        move.toValue = moveTo
        move.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.frame.origin.y = (self.layer?.position.y)! - y
        }
        
        layer?.add(move, forKey: "moveDown")
        CATransaction.commit()
    }
    
    func fadeIn(){
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.duration = 1
        fade.fromValue = 0
        fade.toValue = 1
        CATransaction.begin()
        layer?.add(fade, forKey: "fadeIn")
        CATransaction.commit()
        layer?.opacity = 1
    }
    
    func fadeOut(_ completion:@escaping ()->Void){
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.duration = 1
        fade.toValue = 0

        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            completion()
        }
        layer?.add(fade, forKey: "fadeIn")
        CATransaction.commit()
        layer?.opacity = 0
    }
    
    func moveUpForUninstallButton(_ delaySeconds:CFTimeInterval=0){
        moveUpBy(20, delaySeconds: delaySeconds)
    }
    
    func moveDownForUninstallButton(_ delaySeconds:CFTimeInterval=0){
        moveDownBy(20, delaySeconds: delaySeconds)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
