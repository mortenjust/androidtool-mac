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

class DeviceList {
    
    static func restartRefreshing(){
        postNotification(namd: "unSuspendAdb")
    }
    
    static func stopRefreshing(){
        postNotification(namd: "suspendAdb")
    }
    
    private static func postNotification(namd name: String) {
        NotificationCenter
            .default
            .post(name: Notification.Name(rawValue: name), object: self, userInfo:nil)
    }
    
}

extension NSViewController {
    
    func fadeViewsOutStaggered(_ views:[NSView]){
        var delay:CFTimeInterval = 0
        for view in views {
            fadeViewTo(0, view: view, delay: delay)
            delay += staggerDelay
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
    
    var staggerDelay: CFTimeInterval {
        return 2
    }
    
    func fadeViewOut(_ view:NSView){
        fadeViewTo(0, view: view)
    }
    
    func fadeViewIn(_ view:NSView){
        fadeViewTo(1, view: view)
    }
    
    
    func fadeViewsInStaggered(_ views:[NSView]){
        var delay:CFTimeInterval = 0
        for view in views {
            fadeViewTo(1, view: view, delay: delay)
            delay += staggerDelay
        }
    }
    
    func changeWindowHeight(_ window:NSWindow, view:NSView, newHeight:CGFloat=0) {
        var frame = window.frame
        frame.origin.y += frame.size.height; // origin.y is top Y coordinate now
        frame.origin.y -= newHeight // new Y coordinate for the origin
        frame.size.height = newHeight
        frame.size = CGSize(width: frame.size.width, height: newHeight)
        window.setFrame(frame, display: true, animate: true)
    }
    
}

extension NSUserNotification {
    
    static func deliver(_ title:String, moreInfo:String, sound:Bool=true) -> Void {
        let unc = NSUserNotificationCenter.default
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = moreInfo
        if sound == true {
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        unc.deliver(notification)
    }

    
}

let filesystem = FileManager.default

extension FileManager {
    
    func setUpSupportFolderScriptPath() throws {
        let scriptFolder = supportFolderScriptPath()
        
        let scriptUrl = URL(fileURLWithPath: scriptFolder)
        try createDirectory(at: scriptUrl, withIntermediateDirectories: true, attributes: nil)
        let deleteToReset = scriptUrl.appendingPathComponent(deleteToResetName)
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            if fileExists(atPath: deleteToReset.path) {
                if checkVersionMatch(appVersion: appVersion, pathToVersionFile: deleteToReset) {
                    // it a match, do nothing
                    return
                } else {
                    try removeItem(at: deleteToReset)
                }
            }
            try? copyInceptionScripts(userScriptFolder: scriptFolder)
            try appVersion.write(to: deleteToReset, atomically: false, encoding: .utf8)
        }
    }

    func supportFolderScriptPath() -> String {
        let supportFolder:String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let folder = "\(supportFolder)/AndroidTool"
        let scriptFolder = "\(folder)/UserScripts"
        return scriptFolder
    }
    
    private func copyInceptionScripts(userScriptFolder: String) throws {
        // copy files from UserScriptsInception to this new folder
        if let resourceDir = Bundle.main.resourcePath {
            let inceptionScriptDir = "\(resourceDir)/UserScriptsInception"
            for fileName in try contentsOfDirectory(atPath: inceptionScriptDir) {
                let destFile = "\(userScriptFolder)/\(fileName)"
                if fileExists(atPath: destFile) {
                    try removeItem(atPath: destFile)
                }
                try copyItem(
                    atPath: "\(inceptionScriptDir)/\(fileName)",
                    toPath: destFile)
            }
        }
    }
    
    func revealScriptsFolder(){
        let folder = supportFolderScriptPath()
        NSWorkspace.shared.openFile(folder)
    }

    private func checkVersionMatch(appVersion: String, pathToVersionFile: URL) -> Bool {
        if let savedVersion = try? String(contentsOf: pathToVersionFile, encoding: .utf8) {
            return appVersion == savedVersion
        } else {
            return false
        }
    }
    
    func sizeOfFileAtPath(_ filePath:String) -> UInt64 {
        if let atts:NSDictionary = try? attributesOfItem(atPath: filePath) as NSDictionary {
            return atts.fileSize()
        } else {
            return 1
        }
    }
    
    func scriptsInScriptFolder(_ folder: String) -> [String] {
        var files = [String]()
        let someFiles = enumerator(atPath: folder)
        while let file = someFiles?.nextObject() as? String  {
            if file != ".DS_Store" && file != deleteToResetName {
                files.append(file)
            }
        }
        return files
    }
    
    
}

extension String {
    
    func matches(_ regex:String) -> [String]? {
        do {
            let re = try NSRegularExpression(pattern: regex,
                                             options: .caseInsensitive)
            let matches = re.matches(in: self,
                                     options: .reportProgress,
                                     range:
                NSRange(location: 0, length: utf16.count))
            if matches.count != 0 {
                var results = [String]()
                for match in matches {
                    let result = (self as NSString).substring(with: match.range(at: 1))
                    results.append(result)
                }
                return results
            } else {
                return nil
            }
            
        } catch {
            print("Problem!")
            return nil
        }
    }
    
    init(byteCount: UInt64) {
        let formatter = ByteCountFormatter()
        let formatted = formatter.string(fromByteCount: Int64(byteCount))
        self = formatted
    }


    
}

struct Lock {
    
    private let token = NSObject()
    
    func synced(_ work: () -> ()) {
        objc_sync_enter(token)
        work()
        objc_sync_exit(token)
    }
    
}
