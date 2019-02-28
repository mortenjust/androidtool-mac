//
//  Util.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Foundation
import AppKit

private let deleteToResetName = "delete_to_reset"

class Util {
    var deviceWidth:CGFloat = 373
    var deviceHeight:CGFloat = 127

    // view is self.view
    func changeWindowSize(_ window:NSWindow, view:NSView, addHeight:CGFloat=0, addWidth:CGFloat=0) {
        var frame = window.frame
        frame.size = CGSize(width: frame.size.width+addWidth, height: frame.size.height+addHeight)
        frame.origin.y -= addHeight
        window.setFrame(frame, display: true, animate: true)
        view.frame.size.height += addHeight
        view.frame.origin.y -= addHeight
    }
    
    
    func changeWindowHeight(_ window:NSWindow, view:NSView, newHeight:CGFloat=0) {
        var frame = window.frame
        frame.origin.y += frame.size.height; // origin.y is top Y coordinate now
        frame.origin.y -= newHeight // new Y coordinate for the origin
        frame.size.height = newHeight
        frame.size = CGSize(width: frame.size.width, height: newHeight)
        window.setFrame(frame, display: true, animate: true)
    }

    
    static func showNotification(_ title:String, moreInfo:String, sound:Bool=true) -> Void {
        let unc = NSUserNotificationCenter.default
        
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = moreInfo
        if sound == true {
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        unc.deliver(notification)
    }
    
    func getSupportFolderScriptPath() -> String {
        let supportFolder:String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let folder = "\(supportFolder)/AndroidTool"
        let scriptFolder = "\(folder)/UserScripts"
        return scriptFolder
    }
 
    func setUpSupportFolderScriptPath() {
        let fileM = FileManager.default
        let scriptFolder = getSupportFolderScriptPath()
        
        let scriptUrl = URL.init(fileURLWithPath: scriptFolder)
        do {
            try fileM.createDirectory(at: scriptUrl, withIntermediateDirectories: true, attributes: nil)
            let deleteToReset = scriptUrl.appendingPathComponent(deleteToResetName)
            if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
                if fileM.fileExists(atPath: deleteToReset.path) {
                    if (Util.checkVersionMatch(appVersion: appVersion, pathToVersionFile: deleteToReset)) {
                        // it a match, do nothing
                        return
                    } else {
                        try fileM.removeItem(at: deleteToReset)
                    }
                }
                Util.copyInceptionScripts(userScriptFolder: scriptFolder)
                try appVersion.write(to: deleteToReset, atomically: false, encoding: .utf8)
            }
        } catch _ {}
    }
    
    private static func checkVersionMatch(appVersion: String, pathToVersionFile: URL) -> Bool {
        do {
            let savedVersion = try String(contentsOf: pathToVersionFile, encoding: .utf8)
            return appVersion == savedVersion
        } catch _ { }
        return false
    }
    
    private static func copyInceptionScripts(userScriptFolder: String) {
        let fileM = FileManager.default
        // copy files from UserScriptsInception to this new folder
        if let resourceDir = Bundle.main.resourcePath {
            let inceptionScriptDir = "\(resourceDir)/UserScriptsInception"
            do {
                for fileName in try fileM.contentsOfDirectory(atPath: inceptionScriptDir) {
                    let destFile = "\(userScriptFolder)/\(fileName)"
                    if fileM.fileExists(atPath: destFile) {
                        try fileM.removeItem(atPath: destFile)
                    }
                    try fileM.copyItem(
                        atPath: "\(inceptionScriptDir)/\(fileName)",
                        toPath: destFile)
                }
            } catch _ {
            }
        }
    }
    
    func revealScriptsFolder(){
        let folder = getSupportFolderScriptPath()
        NSWorkspace.shared.openFile(folder)
        }
    
    func getScriptsInScriptFolder(_ folder:String) -> [String]? {
        let fileM = FileManager.default
        var files = [String]()
        let someFiles = fileM.enumerator(atPath: folder)
        while let file = someFiles?.nextObject() as? String  {
            if file != ".DS_Store" && file != deleteToResetName {
                files.append(file)
            }
        }
        return files
    }
    
    func restartRefreshingDeviceList(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: "unSuspendAdb"), object: self, userInfo:nil)
    }
    
    func stopRefreshingDeviceList(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: "suspendAdb"), object: self, userInfo:nil)
    }
    
    func findMatchesInString(_ rawdata:String, regex:String) -> [String]? {
        do {
            let re = try NSRegularExpression(pattern: regex,
                options: NSRegularExpression.Options.caseInsensitive)
            
            let matches = re.matches(in: rawdata,
                options: NSRegularExpression.MatchingOptions.reportProgress,
                range:
                NSRange(location: 0, length: rawdata.utf16.count))
            
            if matches.count != 0 {
                var results = [String]()
                for match in matches {
                    let result = (rawdata as NSString).substring(with: match.range(at: 1))
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
    
    
    
    func fadeViewTo(_ alphaValue:Float, view:NSView, delay:CFTimeInterval=0){
        view.wantsLayer = true

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.duration = 0.3
        fade.beginTime = CACurrentMediaTime() + delay
        fade.toValue = alphaValue
        fade.timingFunction = CAMediaTimingFunction(name: .easeOut)

        
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
        view.layer?.add(fade, forKey: "fader")
        view.layer?.add(move, forKey: "mover")
        CATransaction.commit()
        
        view.layer?.position.y = move.toValue as! CGFloat
        view.layer?.opacity = alphaValue
        
        
    }
    
    
    func fadeViewOut(_ view:NSView){
        fadeViewTo(0, view: view)
    }
    
    func fadeViewIn(_ view:NSView){
        fadeViewTo(1, view: view)
    }
    
    
    func getStaggerDelay()->CFTimeInterval{ return 2}
    
    func fadeViewsInStaggered(_ views:[NSView]){
        var delay:CFTimeInterval = 0
        for view in views {
            fadeViewTo(1, view: view, delay: delay)
            delay += getStaggerDelay()
        }
    }
    
    func fadeViewsOutStaggered(_ views:[NSView]){
        var delay:CFTimeInterval = 0
        for view in views {
            fadeViewTo(0, view: view, delay: delay)
            delay += getStaggerDelay()
        }
    }

    static func formatBytes(_ byteCount:UInt64) -> String {
        let formatter = ByteCountFormatter()
        let formatted = formatter.string(fromByteCount: Int64(byteCount))
        return formatted
    }
    
    static func getFileSizeForFilePath(_ filePath:String) -> UInt64 {
        
        do {
            let atts:NSDictionary = try FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            return atts.fileSize()
        } catch _ {
        }
        
        return 1
    }
    
    static func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}


