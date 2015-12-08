//
//  ZipHandler.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 12/7/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

protocol ZipHandlerDelegate {
    func zipHandlerDidStart()
    func zipHandlerDidFinish()
}

class ZipHandler: NSObject {
    var filepath:String!
    var delegate:ZipHandlerDelegate?
    var device:Device!
    
    init(filepath:String, device:Device){
        print(">>zip init ziphandler")
        super.init()
        self.filepath = filepath
        self.device = device
    }
    
    func flash(){
        print(">>zip flash")
        delegate?.zipHandlerDidStart()
        let shell = ShellTasker(scriptFile: "installZip")
        print("startin flashing")
        shell.run(arguments: [self.device.adbIdentifier!, self.filepath]) { (output) -> Void in
            print("done flashing")
            self.delegate?.zipHandlerDidFinish()
        }
    }
}
