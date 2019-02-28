//: Playground - noun: a place where people can play

import Cocoa
import Foundation

var string = "~/Desktop"
var bol:Bool = true

"hej \(bol)"


NSString(string: "~user/Desktop/AndroidTool").expandingTildeInPath



func getFileSize(filePath:String) -> UInt64 {
    
    do {
        let atts:NSDictionary = try FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
        return atts.fileSize()
    } catch _ {
        return 0
    }
}

let filepath=NSString(string:"~/Desktop/test.txt").expandingTildeInPath

getFileSize(filePath: filepath)
