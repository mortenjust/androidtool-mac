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
    var scriptFile:String!
    var task:NSTask!

    
    init(scriptFile:String){
//        println("initiate with \(scriptFile)")
        self.scriptFile = scriptFile
    }
    
    func stop(){
//        println("shelltask stop")
        task.terminate()
    }
    
    func run(arguments args:[String]=[], isUserScript:Bool = false, isIOS:Bool = false, complete:(output:NSString)-> Void) {
        
        var output = NSString()
        var data = NSData()
        
        if scriptFile == nil {
            return
        }
        
//        println("running \(scriptFile)")
        
        var scriptPath:AnyObject!
        
        if isUserScript {
            scriptPath = scriptFile as AnyObject
            } else {
            scriptPath = NSBundle.mainBundle().pathForResource(scriptFile, ofType: "sh") as! AnyObject
            }

        let sp = scriptPath as! String        
        
        var resourcesPath = NSBundle.mainBundle().pathForResource("adb", ofType: "")?.stringByDeletingLastPathComponent
        
        var bash = "/bin/bash"
        
        task = NSTask()
        let pipe = NSPipe()

        task.launchPath = bash
        
        var allArguments = [String]()
        allArguments.append("\(scriptPath)") // $1

        if !isIOS {
            allArguments.append(resourcesPath!) // $1
            } else
            {
            let imobilePath = NSBundle.mainBundle().pathForResource("idevicescreenshot", ofType: "")?.stringByDeletingLastPathComponent
            allArguments.append(imobilePath!) // $1
            }
        
        for arg in args {
           allArguments.append(arg)
        }
        
        task.arguments = allArguments
        
//  was      task.arguments = [scriptPath, resourcesPath!, args]

        task.standardOutput = pipe
        

        self.task.launch()
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: pipe.fileHandleForReading, queue: nil) { (notification) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                data = pipe.fileHandleForReading.readDataToEndOfFile() // use .availabledata instead to stream from the console, pretty cool
                output = NSString(data: data, encoding: NSUTF8StringEncoding)!
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    complete(output: output)
                })
             })
        }

 
    }
}