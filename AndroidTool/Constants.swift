//
//  Constants.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 11/13/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class Constants {
    static let NOTIF_NEWDATA = "mj.newData"
    static let NOTIF_NEWDATAVERBOSE = "mj.newDataVerbose"
    static let NOTIF_NEWSESSION = "mj.newSession"
    static let NOTIF_ALLOUTPUT = "mj.newAllOutput"
    static let NOTIF_COMMAND = "mj.command"
    static let NOTIF_COMMANDVERBOSE = "mj.commandVerbose"
    static let DROP_INVITE = "Drop a ZIP or APK prototype"
    static let PREF_SCREENSHOTFOLDER = "screenshotsFolder"
    static let PREF_SCREENRECORDINGSFOLDER = "screenRecordingsFolder"
    static let PREF_USEACTIVITYINFILENAME = "useActivityInFilename"
    static let PREF_LAUNCHINSTALLEDAPP = "launchInstalledApp"
    static let PREF_FLASHIMAGESINZIPFILES = "flashImagesInZipFiles"
    static let PREF_GENERATEGIF = "generateGif"
    
    
    static let defaultPrefValues = [
        "timeValue":"10:09"
        ,"mobileDatatype":"No data type"
        ,"batteryLevel": "100%"
        ,"mobileLevel" : "4 bars"
        ,"verboseOutput" : false
        ,"screenRecordingsFolder": ""
        ,"screenshotsFolder": ""
        ,"createGIF": true
        ,"useActivityInFilename":true
        ,"launchInstalledApp":true
        ,"flashImagesInZipFiles":false
        ,"generateGif":false
    ] as [String : Any]
    
    static let tweakProperties = ["bluetooth", "clock", "alarm", "sync", "wifi", "location", "volume", "mute", "notifications", "mobile", "mobileDatatype", "mobileLevel", "batteryLevel", "batteryCharging", "airplane", "nosim", "speakerphone"]
    
    static let WIFI = "wifi"
    static let NOTIFICATIONS = "notifications"
    static let TIME = "time"
    static let TIMEVALUE = "timeValue"
    static let BLUETOOTH = "bluetooth"
    static let ALARM = "alarm"
    static let SYNC = "sync"
    static let LOCATION = "location"
    static let VOLUME = "volume"
    static let MUTE = "mute"
    static let DATATYPE = "datatype"
    static let BATTERYLEVEL = "batteryLevel"
    static let CHARGING = "charging"
    static let VERBOSEOUTPUT = "verboseOutput"
}
