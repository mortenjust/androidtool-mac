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
            let apk = self
            
            if let l = rawdata.matches("launchable-activity: name='(.*?)'") {
                apk.launcherActivity = l[0]
            }
            
            if let n = rawdata.matches("application-label:'(.*?)'") {
                apk.appName = n[0]
            }
            
            if let p = rawdata.matches("package: name='(.*?)'") {
                apk.packageName = p[0]
            }
            
            if let versionCode = rawdata.matches("versionCode='(.*?)'") {
                apk.versionCode = versionCode[0]
            }

            if let versionName = rawdata.matches("versionName='(.*?)'") {
                apk.versionName = versionName[0]
            }
        }
}
