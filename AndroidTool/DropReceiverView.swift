//
//  DropReceiverView.swift
//  Shellpad
//
//  Created by Morten Just Petersen on 10/30/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

protocol DropDelegate {
    func dropDragEntered(filePath:String)
    func dropDragPerformed(filePath:String)
    func dropDragExited()
    func dropUpdated(mouseAt:NSPoint)
}

class DropReceiverView: NSView {
    
    var delegate:DropDelegate?
    var testVar = "only you can see this";
    
    func removeBackgroundColor(){
        layer?.backgroundColor = NSColor.clearColor().CGColor
        }
    
    func addBackgroundColor(){
        layer?.backgroundColor = NSColor(red:0.267, green:0.251, blue:0.290, alpha:1).CGColor
        }
    
    func setup(){
        wantsLayer = true
        let fileTypes = [
            "public.data"
        ]
        registerForDraggedTypes(fileTypes);
    }
    //https://developer.apple.com/library/mac/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        
        //        Swift.print("HELLO \(getPathFromBoard(sender.draggingPasteboard()))")
        let path = getPathFromBoard(sender.draggingPasteboard())
        delegate?.dropDragEntered(path)
        addBackgroundColor()
        return NSDragOperation.Copy
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        delegate?.dropUpdated(sender.draggingLocation())
        return NSDragOperation.Copy
    }
    override func draggingExited(sender: NSDraggingInfo?) {
        removeBackgroundColor()
        delegate?.dropDragExited()
    }
    
    override func concludeDragOperation(sender: NSDraggingInfo?) {
        let path = getPathFromBoard((sender?.draggingPasteboard())!)
        Swift.print("path is \(path)")
        removeBackgroundColor()
        delegate?.dropDragPerformed(path)
    }
    
    func getPathFromBoard(board:NSPasteboard) -> String {
        let url = NSURL(fromPasteboard: board)
        let path = url?.path!
        return path!;
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
    }
    
    
}
