//
//  Util.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Foundation
import AppKit


class Util {
    var deviceWidth:CGFloat = 373
    var deviceHeight:CGFloat = 127

    // view is self.view
    func changeWindowSize(window:NSWindow, view:NSView, addHeight:CGFloat=0, addWidth:CGFloat=0) {
        var frame = window.frame
        frame.size = CGSizeMake(frame.size.width+addWidth, frame.size.height+addHeight)
        frame.origin.y -= addHeight
        window.setFrame(frame, display: true, animate: true)
        view.frame.size.height += addHeight
        view.frame.origin.y -= addHeight
    }
    
//    func changeWindowHeight(window:NSWindow, view:NSView, newHeight:CGFloat=0) {
//        var frame = window.frame
//        frame.size = CGSizeMake(frame.size.width, newHeight)
////        frame.origin.y -= newHeight
//        window.setFrame(frame, display: true, animate: true)
//        view.frame.size.height += newHeight
//        view.frame.origin.y -= newHeight
//    }
    
    
    func changeWindowHeight(window:NSWindow, view:NSView, newHeight:CGFloat=0) {
        var frame = window.frame
        frame.origin.y += frame.size.height; // origin.y is top Y coordinate now
        frame.origin.y -= newHeight // new Y coordinate for the origin
        frame.size.height = newHeight
        frame.size = CGSizeMake(frame.size.width, newHeight)
        window.setFrame(frame, display: true, animate: true)
    }

    
    func showNotification(title:String, moreInfo:String, sound:Bool=true) -> Void {
        let unc = NSUserNotificationCenter.defaultUserNotificationCenter()
        
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = moreInfo
        if sound == true {
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        unc.deliverNotification(notification)
    }
    
    
    func getSupportFolderScriptPath() -> String {
        
        let fileM = NSFileManager.defaultManager()
        
        let supportFolder:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] 
        
        let folder = "\(supportFolder)/AndroidTool"
        let scriptFolder = "\(folder)/UserScripts"
        
        if !fileM.fileExistsAtPath(folder) {
            do {
                try fileM.createDirectoryAtPath(folder, withIntermediateDirectories: false, attributes: nil)
            } catch _ {
            }
            do {
                try fileM.createDirectoryAtPath(scriptFolder, withIntermediateDirectories: false, attributes: nil)
            } catch _ {
            }
            
            // copy files from UserScriptsInception to this new folder - TODO: Take all, not just bugreport
            let inceptionScript = NSBundle.mainBundle().pathForResource("Take Bugreport", ofType: "sh")
            do {
                try fileM.copyItemAtPath(inceptionScript!, toPath: "\(scriptFolder)/Take Bugreport.sh")
            } catch _ {
            }
        }
        return scriptFolder
    }
    
    func revealScriptsFolder(){
        let folder = getSupportFolderScriptPath()
        NSWorkspace.sharedWorkspace().openFile(folder)
        }
    
    func getFilesInScriptFolder(folder:String) -> [String]? {
        let fileM = NSFileManager.defaultManager()
        var files = [String]()
        let someFiles = fileM.enumeratorAtPath(folder)
        while let file = someFiles?.nextObject() as? String  {
            if file != ".DS_Store" {
                files.append(file)
            }
        }
        return files
    }
    
    func isMavericks() -> Bool {
        if #available(OSX 10.10, *) {
            return NSProcessInfo.processInfo().operatingSystemVersion.minorVersion != 10 ? true : false
        } else {
            // Fallback on earlier versions
            return false
        }
    }
    
    
    func restartRefreshingDeviceList(){
        NSNotificationCenter.defaultCenter().postNotificationName("unSuspendAdb", object: self, userInfo:nil)
    }
    
    func stopRefreshingDeviceList(){
        NSNotificationCenter.defaultCenter().postNotificationName("suspendAdb", object: self, userInfo:nil)
    }

}


