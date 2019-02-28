//
//  ObbHandler.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 1/20/16.
//  Copyright © 2016 Morten Just Petersen. All rights reserved.
//

import Cocoa

protocol ObbHandlerDelegate: AnyObject {
    func obbHandlerDidStart(_ bytes: String)
    func obbHandlerDidFinish()
}

class ObbHandler {
    var filePath: String
    var delegate: ObbHandlerDelegate?
    var device: Device
    var fileSize: UInt64
    
    init(filePath: String,
         device:Device){
        print(">>obb init obbhandler")
        fileSize = filesystem.sizeOfFileAtPath(filePath)
        self.filePath = filePath
        self.device = device
    }
    
    func pushToDevice(){
        print(">>zip flash")

        let shell = ShellTasker(scriptFile: "installObbForSerial")
        let bytes = String(byteCount: fileSize)
        
        delegate?.obbHandlerDidStart(bytes)
        
        print("startin obb copying the \(bytes) file")
        shell.run(arguments: [device.adbIdentifier!, filePath]) { (output) -> Void in
            print("done copying OBB to device")
            self.delegate?.obbHandlerDidFinish()
        }
    }

}

