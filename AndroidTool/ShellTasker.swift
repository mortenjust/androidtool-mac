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
    
    func run(arguments args:[String]=[], isUserScript:Bool = false, isIOS:Bool = false, complete:@escaping (_ output:NSString)-> Void) {
        
        var output = NSString()
        var data = Data()
        
        var scriptPath:String
        
        if isUserScript {
            scriptPath = scriptFile
        } else {
            scriptPath = Bundle.main.path(forResource: scriptFile, ofType: "sh")!
        }
        
        let resourcesUrl = NSURL(fileURLWithPath: Bundle.main.path(forResource: "adb", ofType: "")!).deletingLastPathComponent
        
        let resourcesPath = resourcesUrl?.path
        
        //let resourcesPath = NSBundle.mainBundle().pathForResource("adb", ofType: "")?.stringByDeletingLastPathComponent
        
        let bash = "/bin/bash"
        
        task = Process()
        let pipe = Pipe()
        
        task.launchPath = bash
        
        var allArguments = [String]()
        allArguments.append("\(scriptPath)") // $1
        
        if !isIOS {
            allArguments.append(resourcesPath!) // $1
        } else
        {
            let imobileUrl = NSURL(fileURLWithPath: Bundle.main.path(forResource: "idevicescreenshot", ofType: "")!).deletingLastPathComponent
            let imobilePath = imobileUrl?.path
            //let imobilePath = NSBundle.mainBundle().pathForResource("idevicescreenshot", ofType: "")?.stringByDeletingLastPathComponent
            allArguments.append(imobilePath!) // $1
        }
        
        for arg in args {
            allArguments.append(arg)
        }
        
        task.arguments = allArguments
        
        //  was task.arguments = [scriptPath, resourcesPath!, args]
        
        task.standardOutput = pipe
        task.standardError = pipe
        
        // post a notification with the command, for the rawoutput debugging window
        if self.outputIsVerbose {
            postNotification(scriptPath as NSString, channel: C.NOTIF_COMMANDVERBOSE)
        } else {
            postNotification(scriptPath as NSString, channel: C.NOTIF_COMMAND)
        }
        
        self.task.launch()
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: pipe.fileHandleForReading, queue: nil) { (notification) -> Void in
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                data = pipe.fileHandleForReading.readDataToEndOfFile() // use .availabledata instead to stream from the console, pretty cool
                output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                DispatchQueue.main.async(execute: { () -> Void in
                    var channel = ""
                    if self.outputIsVerbose {
                        channel = C.NOTIF_NEWDATAVERBOSE
                        } else {
                        channel = C.NOTIF_NEWDATA
                        }
                    self.postNotification(output, channel: channel)
                    complete(output)
                })
            })
        }
        
        
    }
}
