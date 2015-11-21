//
//  UITweaker.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/16/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class UITweaker: NSObject {
    var adbIdentifier:String!
    
    init(adbIdentifier:String){
        self.adbIdentifier = adbIdentifier;
    }
    
    func start(callback:()->Void){
        var cmdString = ""
        for command in collectAllCommands() {
            cmdString = "\(command)~\(cmdString)"
        }
        
        ShellTasker(scriptFile: "setDemoModeOptions").run(arguments: [self.adbIdentifier, cmdString], isUserScript: false, isIOS: false) { (output) -> Void in
//            print("Done executing \(cmdString)")
            print(output)
            callback()
        }
    }
    
    
    func collectAllCommands() -> [String] {
        let ud = NSUserDefaults.standardUserDefaults()
        var commands = [String]()
        
        ud.boolForKey("showWifi") ? (commands.append("network -e wifi show")) : (commands.append("network -e wifi hide"))
        ud.boolForKey("showNotifications") ? (commands.append("notifications -e visible true")) : (commands.append("notifications -e visible false"))
        
        if ud.boolForKey("changeTime") {
            let hhmm = formatTime(ud.stringForKey("timeValue")!)
            commands.append("clock -e hhmm \(hhmm)")
        }
        
        ud.boolForKey("showBluetooth") ? (commands.append("status -e bluetooth connected")) : (commands.append("status -e bluetooth hide"))
        ud.boolForKey("showAlarm") ? (commands.append("status -e alarm show")) : (commands.append("status -e alarm hide"))
        ud.boolForKey("showSync") ? (commands.append("status -e sync show")) : (commands.append("status -e sync hide"))
        ud.boolForKey("showWifi") ? (commands.append("network -e wifi show -e level 4")) : (commands.append("network -e wifi hide"))
        ud.boolForKey("showLocation") ? (commands.append("status -e location show")) : (commands.append("status -e location hide"))
        ud.boolForKey("showVolume") ? (commands.append("status -e volume show")) : (commands.append("status -e volume hide"))
        ud.boolForKey("showMute") ? (commands.append("status -e mute show")) : (commands.append("status -e mute hide"))
        ud.boolForKey("showNotifications") ? (commands.append("notifications -e visible true")) : (commands.append("notifications -e visible false"))
        
        let batLevel = ud.stringForKey("batteryLevel")?.stringByReplacingOccurrencesOfString("%", withString: "")
        ud.boolForKey("showCharging") ?
            (commands.append("battery -e plugged true -e level \(batLevel!)")) : (commands.append("battery -e plugged false -e level \(batLevel!)"))
        
        if ud.boolForKey("showMobile") {
            let dataType = ud.stringForKey("dataType")!
            let mobileLevel = ud.stringForKey("mobileLevel")!.stringByReplacingOccurrencesOfString(" bars", withString: "").stringByReplacingOccurrencesOfString(" bar", withString: "")
            commands.append("network -e mobile show -e datatype \(dataType) -e level \(mobileLevel)")
        } else {
        // hide cell
            commands.append("network -e mobile hide")
        }

        
        // TODO: Let user hide the cell bars, and also control how        commands.append("network -e mobile datatype \(dataType) ? level \(mobileLevel)")
        return commands

    }
    
    
    func formatTime(t:String) -> String { // remove : in hh:mm
        return t.stringByReplacingOccurrencesOfString(":", withString: "")
    }
    
    func end(){
        
        ShellTasker(scriptFile: "exitDemoMode").run(arguments: [self.adbIdentifier], isUserScript: false, isIOS: false) { (output) -> Void in
            ///aaaaand done
        }
    }
}
