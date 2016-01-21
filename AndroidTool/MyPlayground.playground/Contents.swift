//: Playground - noun: a place where people can play

import Cocoa
import Foundation

var string = "~/Desktop"
var bol:Bool = true

"hej \(bol)"


NSString(string: "~user/Desktop/AndroidTool").stringByExpandingTildeInPath



func getFileSize(filePath:String) -> UInt64 {
    
    do {
        let atts:NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
        return atts.fileSize()
    } catch _ {
    }
    
    return 1
}

let filepath="/Users/mortenjust/Downloads/obb/com.ea.game.nfs14_row-4317.obb"

getFileSize(filepath)