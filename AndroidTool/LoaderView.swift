//
//  LoaderView.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/20/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class LoaderView: NSImageView {

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    func setup(){
        self.wantsLayer = true
        hidden = true
    }
    
    
    func startRotating(){
        hidden = false
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fillMode = kCAFillModeForwards
        rotate.fromValue = 0.0
        rotate.toValue = CGFloat(M_PI * 2.0)
        rotate.duration = 1
        rotate.repeatCount = Float.infinity
        layer?.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        layer?.anchorPoint = CGPointMake(0.5, 0.5)
        layer?.addAnimation(rotate, forKey: nil)
    }
    func stopRotatingAndReset(){
        stopRotating()
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.hidden = true
        }
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fillMode = kCAFillModeForwards
        rotate.toValue = 0.0
        rotate.duration = 0.3

        layer?.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        layer?.anchorPoint = CGPointMake(0.5, 0.5)
        
        layer?.addAnimation(rotate, forKey: nil)
        CATransaction.commit()
        
    }
    
    func stopRotating(){
        layer?.removeAllAnimations()
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
