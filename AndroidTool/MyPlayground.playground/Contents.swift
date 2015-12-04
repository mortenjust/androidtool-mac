//: Playground - noun: a place where people can play

import Cocoa
import Foundation

var string = "Morten Just's iPhone"
var total = 0

let shouldDoOne = true
let shouldDoTwo = true

func maybeDoOne(actuallyDo:Bool, complete:()->Void) {
    if actuallyDo {
        print("Did one")
        }
    complete()
}


func maybeDoTwo(actuallyDo:Bool, complete:()->Void) {
    if actuallyDo {
        print("Did two")
        }
    complete()
}

func doFinalAction(){
    print("Did final action")
}


maybeDoOne(shouldDoOne) { () -> Void in
    maybeDoTwo(shouldDoTwo, complete: { () -> Void in
        doFinalAction()
    })
}