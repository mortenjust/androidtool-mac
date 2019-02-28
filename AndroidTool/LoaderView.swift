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
        isHidden = true
    }
    
    
    func startRotating(){
        isHidden = false
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fillMode = .forwards
        rotate.fromValue = 0.0
        rotate.toValue = CGFloat(.pi * 2.0)
        rotate.duration = 1
        rotate.repeatCount = Float.infinity
        layer?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer?.add(rotate, forKey: nil)
    }
    func stopRotatingAndReset(){
        stopRotating()
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.isHidden = true
        }
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fillMode = .forwards
        rotate.toValue = 0.0
        rotate.duration = 0.3

        layer?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        layer?.add(rotate, forKey: nil)
        CATransaction.commit()
        
    }
    
    func stopRotating(){
        layer?.removeAllAnimations()
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
