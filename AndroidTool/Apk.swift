//
//  Apk.swift
//  Shellpad
//
//  Created by Morten Just Petersen on 11/1/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class Apk: NSObject {
    var filepath:String!
    var launcherActivity:String?
    var appName:String = ""
    var packageName:String?
    var versionCode:String?
    var versionName:String?
    var iconPath:String?
    var localIconPath:String?
    
    
    init(rawAaptBadgingData:String) {
        super.init()
        parseRawInfo(rawAaptBadgingData)
    }
    
     func parseRawInfo(_ rawdata:String) {
            print(">>apkparskeapkinfo")
            let u = Util()
            let apk = self
            
            if let l = u.findMatchesInString(rawdata, regex: "launchable-activity: name='(.*?)'") {
                apk.launcherActivity = l[0]
            }
            
            if let n = u.findMatchesInString(rawdata, regex: "application-label:'(.*?)'") {
                apk.appName = n[0]
            }
            
            if let p = u.findMatchesInString(rawdata, regex: "package: name='(.*?)'") {
                apk.packageName = p[0]
            }
            
            if let versionCode = u.findMatchesInString(rawdata, regex: "versionCode='(.*?)'") {
                apk.versionCode = versionCode[0]
            }

            if let versionName = u.findMatchesInString(rawdata, regex: "versionName='(.*?)'") {
                apk.versionName = versionName[0]
            }
        }

    
}
