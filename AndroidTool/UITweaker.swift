//
//  UITweaker.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/16/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

protocol UITweakerDelegate {
    func UITweakerStatusChanged(_ status: String)
}

class UITweaker: NSObject {
    var adbIdentifier:String
    var delegate:UITweakerDelegate?

    
    init(adbIdentifier:String){
        self.adbIdentifier = adbIdentifier;
    }
    
    struct Tweak {
        var command:String
        var description:String!
    }
    
    func start(_ callback:@escaping ()->Void){
        var cmdString = ""
        for tweak in collectAllTweaks() {
            cmdString = "\(tweak.command)~\(cmdString)"
        }
        
        ShellTasker(scriptFile: "setDemoModeOptions").run(arguments: [self.adbIdentifier, cmdString], isUserScript: false, isIOS: false) { (output) -> Void in
//            print("Done executing \(cmdString)")
            print(output)
            callback()
        }
    }
    
    func collectAllTweaks() -> [Tweak] {
        let ud = UserDefaults.standard
        var tweaks = [Tweak]()
        
        for prop in C.tweakProperties {
            switch prop {
                case "airplane", "nosim", "carriernetworkchange": // network showhide
                    let cmd = "network"
                    var show = "hide"
                    if ud.bool(forKey: prop) { show = "show" }
                    let tweak = Tweak(command: "\(cmd) -e \(prop) \(show)", description: "\(show) \(prop)")
                    tweaks.append(tweak)
                case "location", "alarm", "sync", "tty", "eri", "mute", "speakerphone": // status showhide
                    let cmd = "status"
                    var show = "hide"
                    if ud.bool(forKey: prop) { show = "show" }
                    let tweak = Tweak(command: "\(cmd) -e \(prop) \(show)", description: "\(show) \(prop)")
                    tweaks.append(tweak)
                case "bluetooth":
                    var show = "hide"
                    if ud.bool(forKey: "bluetooth") {
                        show = "connected"
                    }
                    let tweak = Tweak(command: "status -e bluetooth \(show)", description: "Tweaking Bluetooth")
                    tweaks.append(tweak)
                case "notifications":
                    var visible = "false"
                    if ud.bool(forKey: prop) {
                        visible = "true"
                    }
                    let tweak = Tweak(command: "\(prop) -e visible \(visible)", description: "Tweaking notfications")
                    tweaks.append(tweak)
                case "clock":
                    if ud.bool(forKey: prop) {
                        let hhmm = formatTime(ud.string(forKey: C.PREF_TIME_VALUE)!)
                        let tweak = Tweak(command: "clock -e hhmm \(hhmm)", description: "Setting time to \(ud.string(forKey: C.PREF_TIME_VALUE)!)")
                        tweaks.append(tweak)
                    }
                case "wifi":
                    var show = "hide"
                    var level = ""
                    if ud.bool(forKey: "wifi") {
                        show = "show"
                        level = " -e level 4"
                    }
                    let tweak = Tweak(command: "network -e \(prop) \(show) \(level)", description: "\(show) \(prop)")
                    tweaks.append(tweak)
                case "mobile":
                    var tweak:Tweak!
                    if ud.bool(forKey: prop){
                        let mobileDatatype = ud.string(forKey: C.PREF_MOBILE_DATATYPE)
                        let mobileLevel = ud.string(forKey: C.PREF_MOBILE_LEVEL)!.replacingOccurrences(of: " bars", with: "").replacingOccurrences(of: " bar", with: "")
                        tweak = Tweak(command: "network -e mobile show -e datatype \(mobileDatatype!) -e level \(mobileLevel)", description: "Turn cell icon on")
                    } else {
                        tweak = Tweak(command: "network -e mobile hide", description: "Turn cell icon off")
                    }
                    tweaks.append(tweak)
                case "batteryCharging":
                    var showCharging = "false"
                    var description = "Set battery not charging"
                    let batLevel = ud.string(forKey: C.PREF_BATTERY_LEVEL)?.replacingOccurrences(of: "%", with: "")
                    if ud.bool(forKey: "batteryCharging") {
                        showCharging = "true"
                        description = "Set battery charging"
                    }
                    let tweak = Tweak(command: "battery -e plugged \(showCharging) -e level \(batLevel!)", description: description)
                    tweaks.append(tweak)
                default:
                    break
            }
        }
        return tweaks
    }
    
    func formatTime(_ t:String) -> String { // remove : in hh:mm
        return t.replacingOccurrences(of: ":", with: "")
    }
    
    func end(){
        
        ShellTasker(scriptFile: "exitDemoMode").run(arguments: [self.adbIdentifier], isUserScript: false, isIOS: false) { (output) -> Void in
            ///aaaaand done
        }
    }
}
