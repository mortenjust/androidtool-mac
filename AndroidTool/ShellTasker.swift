//
//  ShellTasker.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/23/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa


protocol ShellTaskDelegate {
    func shellTaskDidBegin()
    func shellTaskDidFinish()
}

class ShellTasker: NSObject {
    var scriptFile:String
    var task:Process!
    var outputIsVerbose = false;
    
    init(scriptFile:String){
        self.scriptFile = scriptFile
        print("T:\(scriptFile)")
    }
    
    func stop(){
        task.terminate()
    }
    
    func postNotification(_ message:NSString, channel:String){
        NotificationCenter.default.post(name: Notification.Name(rawValue: channel), object: message)
    }
    
    func run(
            arguments args:[String]=[],
            isUserScript:Bool = false,
            isIOS:Bool = false,
            complete:@escaping (_ output:NSString)-> Void) {
        
        let scriptPath = isUserScript
            ? scriptFile
            : Bundle.main.path(forResource: scriptFile, ofType: "sh")!
        let resourcesPath = Bundle.main.resourcePath!
        
        task = Process()
        task.launchPath = "/bin/bash"
        let pipe = Pipe()
        
        var allArguments = [String]()
        allArguments.append("\(scriptPath)") // $1
        
        if !isIOS {
            allArguments.append(resourcesPath) // $1
        } else {
            let imobileUrl = NSURL(fileURLWithPath: Bundle.main.path(forResource: "idevicescreenshot", ofType: "")!).deletingLastPathComponent
            let imobilePath = imobileUrl?.path
            //let imobilePath = NSBundle.mainBundle().pathForResource("idevicescreenshot", ofType: "")?.stringByDeletingLastPathComponent
            allArguments.append(imobilePath!) // $1
        }
        
        for arg in args {
            allArguments.append(arg)
        }
        
        let defaultAndoridSdkRoot = resourcesPath + "/android-sdk"
        let useUserAndoridSdkRoot = UserDefaults.standard.bool(forKey: C.PREF_USE_USER_ANDROID_SDK_ROOT)
        let androidSdkRoot = useUserAndoridSdkRoot
            ? UserDefaults.standard.string(forKey: C.PREF_ANDROID_SDK_ROOT) ?? defaultAndoridSdkRoot
            : defaultAndoridSdkRoot
        
        task.arguments = allArguments
        task.standardOutput = pipe
        task.standardError = pipe
        task.environment = [
            "ANDROID_SDK_ROOT": androidSdkRoot
        ]
        
        // post a notification with the command, for the rawoutput debugging window
        postNotification(scriptPath as NSString, channel: notificationChannel())
        
        self.task.launch()
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(
            forName:NSNotification.Name.NSFileHandleDataAvailable,
            object: pipe.fileHandleForReading,
            queue: nil)
        { (notification) -> Void in
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                let data = pipe.fileHandleForReading.availableData
                let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                DispatchQueue.main.async(execute: { () -> Void in
                    self.postNotification(output, channel: self.notificationChannel())
                    complete(output)
                })
            })
        }
    }
    
    private func notificationChannel() -> String {
        return self.outputIsVerbose ? C.NOTIF_NEWDATAVERBOSE : C.NOTIF_NEWDATA
    }
}
