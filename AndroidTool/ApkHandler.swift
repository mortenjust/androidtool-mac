//
//  ApkHandler.swift
//  Shellpad
//
//  Created by Morten Just Petersen on 11/1/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

protocol ApkHandlerDelegate {
    func apkHandlerDidStart()
    func apkHandlerDidGetInfo(apk:Apk)
    func apkHandlerDidUpdate(update:String)
    func apkHandlerDidFinish()
}

class ApkHandler: NSObject {
    var filepath:String!
    var delegate:ApkHandlerDelegate?
    var device:Device!
    
    init(filepath:String, device:Device){
        print(">>apk init apkhandler")
        super.init()
        self.filepath = filepath
        self.device = device
    }
    
    init(device:Device){
        print(">>apk init apkhandler with no apk")
        super.init()
        self.device = device
    }
    
    func installAndLaunch(complete:()->Void){
        delegate?.apkHandlerDidStart()
        print(">>apkhandle")
        
        getInfoFromApk() { (apk) -> Void in
            self.install({ () -> Void in
                self.delegate?.apkHandlerDidUpdate("Launching \(apk.appName)...")
                self.launch(apk)
                complete()
            })
        }
    }
    
    func install(completion:()->Void){
        print(">>apkinstall")
        delegate?.apkHandlerDidUpdate("Installing...")
        
        if device.adbIdentifier == nil { print("no adbIdentifier, aborting"); return }
        let s = ShellTasker(scriptFile: "installApkOnDevice")
        
        s.run(arguments: [device.adbIdentifier!, filepath]) { (output) -> Void in
            self.delegate?.apkHandlerDidUpdate("Installed")
            completion()
        }
    }
    
    func uninstallPackageWithName(packageName:String, completion:()->Void){
        print(">>Uninstall")
        delegate?.apkHandlerDidUpdate("Uninstalling app")
        let s = ShellTasker(scriptFile: "uninstallPackageOnDevice")
        let args = [device.adbIdentifier!, packageName]
        
        s.run(arguments: args, isUserScript: false, isIOS: false) { (output) -> Void in
            completion()
        }
        
    }
    
    func getInfoFromApk(complete:(Apk) -> Void){
        print(">>apkgetinfofromapk")
        delegate?.apkHandlerDidUpdate("Getting info...")
        
        let shell = ShellTasker(scriptFile: "getApkInfo")
        shell.run(arguments: [self.filepath]) { (output) -> Void in
            let apk = Apk(rawAaptBadgingData: output as String)
            self.delegate?.apkHandlerDidGetInfo(apk)
            
            // try getting the icon out
            
            let iconShell = ShellTasker(scriptFile: "extractIconFromApk")
            iconShell.run(arguments: [self.filepath]) { (output) -> Void in
                print("Ready to add nsurl path to apk object: \(output)")
                
                apk.localIconPath = (output as String).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
 
                
                complete(apk)
            }
            
        }
    }
    
    
    func launch(apk:Apk){
        print(">>apklaunch")
        delegate?.apkHandlerDidUpdate("Launching...")
        
        if let packageName = apk.packageName, launcherActivity = apk.launcherActivity {
            
            let ac = "\(packageName)/\(launcherActivity)"
            
            print("apklaunch of \(ac)")
            
            let s = ShellTasker(scriptFile: "launchActivity")
            s.run(arguments: [device.adbIdentifier!, ac]) { (output) -> Void in
                print("apk done launching")
                self.delegate?.apkHandlerDidUpdate("Running \(apk.appName)")
                self.delegate?.apkHandlerDidFinish()
            }
        }
    }
}
