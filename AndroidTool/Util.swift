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
    
    func findMatchesInString(rawdata:String, regex:String) -> [String]? {
        do {
            let re = try NSRegularExpression(pattern: regex,
                options: NSRegularExpressionOptions.CaseInsensitive)
            
            let matches = re.matchesInString(rawdata,
                options: NSMatchingOptions.ReportProgress,
                range:
                NSRange(location: 0, length: rawdata.utf16.count))
            
            if matches.count != 0 {
                var results = [String]()
                for match in matches {
                    let result = (rawdata as NSString).substringWithRange(match.rangeAtIndex(1))
                    results.append(result)
                }
                return results
            }
            else {
                return nil
            }
            
        } catch {
            print("Problem!")
            return nil
        }
    }
    
    
    
    func fadeViewTo(alphaValue:Float, view:NSView, delay:CFTimeInterval=0){
        view.wantsLayer = true

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.duration = 0.3
        fade.beginTime = CACurrentMediaTime() + delay
        fade.toValue = alphaValue
        fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        
        let move = CABasicAnimation(keyPath: "position.y")
        if alphaValue == 0 {
            move.toValue = view.frame.origin.y-10
        } else {
            move.toValue = view.frame.origin.y
        }
        move.duration = fade.duration
        move.beginTime = fade.beginTime
        move.timingFunction = fade.timingFunction
        
        
        CATransaction.begin()
        view.layer?.addAnimation(fade, forKey: "fader")
        view.layer?.addAnimation(move, forKey: "mover")
        CATransaction.commit()
        
        view.layer?.position.y = move.toValue as! CGFloat
        view.layer?.opacity = alphaValue
        
        
    }
    
    
    func fadeViewOut(view:NSView){
        fadeViewTo(0, view: view)
    }
    
    func fadeViewIn(view:NSView){
        fadeViewTo(1, view: view)
    }
    
    
    func getStaggerDelay()->CFTimeInterval{ return 2}
    
    func fadeViewsInStaggered(views:[NSView]){
        var delay:CFTimeInterval = 0
        for view in views {
            fadeViewTo(1, view: view, delay: delay)
            delay += getStaggerDelay()
        }
    }
    
    func fadeViewsOutStaggered(views:[NSView]){
        var delay:CFTimeInterval = 0
        for view in views {
            fadeViewTo(0, view: view, delay: delay)
            delay += getStaggerDelay()
        }
    }

    static func formatBytes(byteCount:UInt64) -> String {
        let formatter = NSByteCountFormatter()
        let formatted = formatter.stringFromByteCount(Int64(byteCount))
        return formatted
    }
    
    static func getFileSizeForFilePath(filePath:String) -> UInt64 {
        
        do {
            let atts:NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
            return atts.fileSize()
        } catch _ {
        }
        
        return 1
    }
}


