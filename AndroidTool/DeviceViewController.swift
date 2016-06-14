//
//  DeviceViewController.swift
//  AndroidTool
//
//  Created by Morten Just Petersen on 4/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import AVFoundation

class DeviceViewController: NSViewController, NSPopoverDelegate, UserScriptDelegate, IOSRecorderDelegate, DropDelegate, ApkHandlerDelegate, ZipHandlerDelegate, ObbHandlerDelegate {
    var device : Device!
    @IBOutlet weak var deviceNameField: NSTextField!
    @IBOutlet  var cameraButton: NSButton!
    @IBOutlet weak var deviceImage: NSImageView!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var videoButton: MovableButton!
    @IBOutlet weak var moreButton: MovableButton!
    @IBOutlet weak var loaderButton: LoaderView!
    @IBOutlet weak var statusLabel: StatusTextField!
    var restingButton : NSImage!
    @IBOutlet var scriptsPopover: NSPopover!
    @IBOutlet var previewPopover: NSPopover!
    @IBOutlet var previewView: NSView!
    @IBOutlet weak var uninstallButton: MovableButton!
    
    
    // install invite
    
    @IBOutlet var installInviteView: NSView!
    @IBOutlet weak var inviteAppName: NSTextField!
    @IBOutlet weak var inviteVersions: NSTextField!
    @IBOutlet weak var invitePackageName: NSTextField!
    @IBOutlet weak var inviteIcon: NSImageView!
    
    
    var iosHelper : IOSDeviceHelper!
    var shellTasker : ShellTasker!
    var isRecording = false
    var moreOpen = false
    var moreShouldClose = false
    var uiTweaker : UITweaker!
    var dropView : DropReceiverView!
    var apkToUninstall : Apk!
    
    func shouldChangeStatusBar() -> Bool {
        if device.type == .Watch {
            return false
        }
        
        return NSUserDefaults.standardUserDefaults().boolForKey("changeAndroidStatusBar")
    }
    
    func setStatus(text:String, shouldFadeOut:Bool = true){
        statusLabel.setText(text, shouldFadeOut: shouldFadeOut)
    }
    
    
    func maybeChangeStatusBar(should:Bool, completion:()->Void){
        if should {
            setStatus("Changing status bar")
            uiTweaker.start({ () -> Void in
                completion()
            })
        } else {
            completion()
        }
    }
    
    func maybeUseActivityFilename(should:Bool, completion:()->Void){
        if should{
            setStatus("Using activity as filename")
            device.getCurrentActivity({ (activityName) -> Void in
                completion()
            })
        } else {
            completion()
        }
        
    }
    
    
    func takeScreenshot(){
        setStatus("Taking screenshot...")
        self.startProgressIndication()
        if device.deviceOS == DeviceOS.Android {
            maybeChangeStatusBar(self.shouldChangeStatusBar(), completion: { () -> Void in
                self.maybeUseActivityFilename(self.shouldUseActivityInFilename(), completion: { () -> Void in
                    self.takeAndroidScreenshot()
                })
            })
        }
        if device.deviceOS == DeviceOS.Ios {
            print("IOS screenshot")
            let args = [device.uuid!, getFolderForScreenshots()]
            ShellTasker(scriptFile: "takeScreenshotOfDeviceWithUUID").run(arguments: args, isUserScript: false, isIOS: true, complete: { (output) -> Void in
                self.setStatus("Screenshot ready")
                self.stopProgressIndication()
                Util().showNotification("Screenshot ready", moreInfo: "", sound: true)
                self.setStatus("Screenshot ready")
            })
            
        }
    }
    
    func getFolderForScreenshots() -> String {
        return NSUserDefaults.standardUserDefaults().stringForKey(C.PREF_SCREENSHOTFOLDER)!
    }
    
    func getFolderForScreenRecordings() -> String {
        return NSUserDefaults.standardUserDefaults().stringForKey(C.PREF_SCREENRECORDINGSFOLDER)!
    }
    
    func cleanActivityName(a:String) -> String {
//        let trimmed = a.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByTrimmingCharactersInSet(NSCharacterSet.URLPathAllowedCharacterSet())
        
        var trimmed = a.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        trimmed = trimmed.stringByReplacingOccurrencesOfString("/", withString: "")
        
        
        let components = trimmed.componentsSeparatedByString(".")
        
        var cleanName=""
        if components.count > 1 {
            cleanName = "\(components[components.count-2])-\(components[components.count-1])"
            }
        return cleanName
    }
    
    func shouldUseActivityInFilename() -> Bool {
        let should = NSUserDefaults.standardUserDefaults().boolForKey(C.PREF_USEACTIVITYINFILENAME)
        if !should {
            device.currentActivity = ""
        }
        return should
    }
    
    func takeAndroidScreenshot(){
        setStatus("Taking screenshot")
        let activity = self.cleanActivityName(device.currentActivity)
        
        let args = [self.device.adbIdentifier!,
                    getFolderForScreenshots(),
                    activity
        ]
        
        ShellTasker(scriptFile: "takeScreenshotOfDeviceWithSerial").run(arguments: args) { (output) -> Void in
            Util().showNotification("Screenshot ready", moreInfo: "", sound: true)
            self.exitDemoModeIfNeeded()
            self.stopProgressIndication()
            self.setStatus("Screenshot ready")
        }
    }
    
    
    func exitDemoModeIfNeeded(){
        if self.shouldChangeStatusBar() {
            self.setStatus("Changing status bar back to normal")
            ShellTasker(scriptFile: "exitDemoMode").run(arguments: [self.device.adbIdentifier!], isUserScript: false, isIOS: false, complete: { (output) -> Void in
                // done, back to normal
            })
        }
    }
    
    @IBAction func cameraClicked(sender: NSButton) {
        takeScreenshot()
    }

    func userScriptEnded() {
        setStatus("Script finished")
        stopProgressIndication()
        Util().restartRefreshingDeviceList()
    }
    
    func userScriptStarted() {
        setStatus("Script running")
        startProgressIndication()
        Util().stopRefreshingDeviceList()
    }
    
    func userScriptWantsSerial() -> String {
        return device.adbIdentifier!
    }
    
    func popoverDidClose(notification: NSNotification) {
        Util().restartRefreshingDeviceList()
        moreOpen = false
    }

    @IBAction func moreClicked(sender: NSButton) {
        Util().stopRefreshingDeviceList()
        if !moreOpen{
            moreOpen = true
            scriptsPopover.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: NSRectEdge(rawValue: 2)!)
            }
    }
    
    func openPreviewPopover(){
//        previewPopover.showRelativeToRect(videoButton.bounds, ofView: videoButton, preferredEdge: 2)
    }
    
    func closePreviewPopover(){
        previewPopover.close()
    }
    
    
    func iosRecorderFailed(title: String, message: String?) {
        let alert = NSAlert()
        alert.messageText = title
        alert.runModal()
     
        cameraButton.enabled = true
        videoButton.enabled = true
        isRecording = false
        self.videoButton.image = NSImage(named: "recordButtonWhite")
    }
    
    func iosRecorderDidEndPreparing() {
        videoButton.alphaValue = 1
        print("recorder did end preparing")
        self.videoButton.image = NSImage(named: "stopButton")
        self.videoButton.enabled = true
    }
    
    func iosRecorderDidStartPreparing(device: AVCaptureDevice) {
        print("recorder did start preparing")
    }
    
    func startRecording(){
        setStatus("Starting screen recording")
        Util().stopRefreshingDeviceList()
        isRecording = true
        self.restingButton = self.videoButton.image // restingbutton is "recordButtonWhite"
        videoButton.image = NSImage(named: "stopButton")
        videoButton.enabled = false
        cameraButton.enabled = false
        moreButton.enabled = false


        switch device.deviceOS! {
        case .Android:
            if shouldChangeStatusBar() {
                setStatus("Changing status bar")
                uiTweaker.start({ () -> Void in
                    self.videoButton.enabled = true
                    self.startRecordingOnAndroidDevice(self.restingButton!)
                })
            } else {
                self.videoButton.enabled = true
                startRecordingOnAndroidDevice(restingButton!)
            }
        case .Ios:
            // iOS starts recording 1 second delayed, so delaying the STOP button to signal this to the user
            videoButton.enabled = true
            openPreviewPopover()
            videoButton.alphaValue = 0.5
            startRecordingOnIOSDevice()
        }
    }
    
    func startRecordingOnIOSDevice(){
        iosHelper.toggleRecording(device.avDevice)
    }
    
    func startRecordingOnAndroidDevice(restingButton:NSImage){
        shellTasker = ShellTasker(scriptFile: "startRecordingForSerial")
        
        let scalePref = NSUserDefaults.standardUserDefaults().doubleForKey("scalePref")
        let bitratePref = Int(NSUserDefaults.standardUserDefaults().doubleForKey("bitratePref"))
        
        // get phone's resolution, multiply with user preference for screencap size (either 1 or lower)
        var res = device.resolution!
        
        if device.type == DeviceType.Phone {
            res = (device.resolution!.width*scalePref, device.resolution!.height*scalePref)
        }
        
        let args:[String] = [device.adbIdentifier!,
                            "\(Int(res.width))",
                            "\(Int(res.height))",
                            "\(bitratePref)",
                            getFolderForScreenRecordings(),
                            "\(NSUserDefaults.standardUserDefaults().boolForKey(C.PREF_GENERATEGIF))"
                            ]
        
        setStatus("Recording screen")
        
        
        shellTasker.run(arguments: args) { (output) -> Void in
            self.setStatus("Fetching screen recording")
            print("-----")
            print(output)
            print("-----")
            
            self.startProgressIndication()
            self.cameraButton.enabled = true
            self.moreButton.enabled = true
            self.videoButton.image = restingButton
            let postProcessTask = ShellTasker(scriptFile: "postProcessMovieForSerial")

            postProcessTask.run(arguments: args, complete: { (output) -> Void in
                Util().showNotification("Your recording is ready", moreInfo: "", sound: true)
                self.exitDemoModeIfNeeded()
                self.setStatus("Recording finished")
                self.stopProgressIndication()

            })
        }
    
    }
    
    func iosRecorderDidFinish(outputFileURL: NSURL!) {
        NSWorkspace.sharedWorkspace().openFile(outputFileURL.path!)
        self.videoButton.image = restingButton
        
        Util().showNotification("Your recording is ready", moreInfo: "", sound: true)
        cameraButton.enabled = true
        
        let movPath = outputFileURL.path!
        let gifUrl = outputFileURL.URLByDeletingPathExtension!
        let gifPath = "\(gifUrl.path!).gif"
        let ffmpegPath = NSBundle.mainBundle().pathForResource("ffmpeg", ofType: "")!
        let scalePref = NSUserDefaults.standardUserDefaults().doubleForKey("scalePref")
        let args = [ffmpegPath, movPath, gifPath, "\(scalePref)", getFolderForScreenRecordings()]
        
        
        
        ShellTasker(scriptFile: "convertMovieFiletoGif").run(arguments: args, isUserScript: false, isIOS: false) { (output) -> Void in
            print("done converting to gif")
            self.stopProgressIndication()
        }
        
        // convert to gif shell args
        // $ffmpeg = $1
        // $inputFile = $2
        // $outputFile = $3
    }
    
    func stopRecording(){
        Util().restartRefreshingDeviceList()
        isRecording = false
        videoButton.alphaValue = 1

        switch device.deviceOS! {
        case .Android:
            shellTasker.stop() // terminates script and fires the closure in startRecordingForSerial
        case .Ios:
            iosHelper.toggleRecording(device.avDevice) // stops recording and fires delegate:
        }
    }
    
    @IBAction func videoClicked(sender: NSButton) {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    init?(device _device:Device){
        device = _device
        super.init(nibName: "DeviceViewController", bundle: nil)
        setup()
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(){
        if device.deviceOS == .Android {
            uiTweaker = UITweaker(adbIdentifier: device.adbIdentifier!)
            }
      dropView = self.view as! DropReceiverView
      dropView.delegate = self
        
    
//        let apk = Apk(rawAaptBadgingData: "hej")
//        showUninstallButton(apk)
        
    }
    
    func startProgressIndication(){
        Util().stopRefreshingDeviceList()
        dispatch_after(1, dispatch_get_main_queue()) { () -> Void in
            self.loaderButton.startRotating()
        }
    }
    
    func stopProgressIndication(){
        Util().restartRefreshingDeviceList()
//        progressBar.stopAnimation(nil)
        loaderButton.stopRotatingAndReset()
    }
    
    override func awakeFromNib() {
        if let model = device.model {
            deviceNameField.stringValue = model
            }
        let brandName = device.brand!.lowercaseString
        let imageName = "logo\(brandName)"
        print("imageName: \(imageName)")
        var image = NSImage(named: imageName)
        
        if image == nil {
            image = NSImage(named: "androidlogo")
        }
        deviceImage.image = image
        
        if device.isEmulator {
//            cameraButton.enabled = false
            videoButton.enabled = false
            deviceNameField.stringValue = "Emulator"
            
        }
        
        // only enable video recording if we have resolution, which is a bit slow because it comes from a big call
        videoButton.enabled = false
        enableVideoButtonWhenReady()
        
        if device.deviceOS == DeviceOS.Ios {
            iosHelper = IOSDeviceHelper(recorderDelegate: self, forDevice:device.avDevice)
            moreButton.hidden = true
        }
        
    }
    
    func startWaitingForAndroidVideoReady(){
        if device.resolution != nil {
            print("resolution not nil")
            videoButton.enabled = true
        } else {
            print("resolution is nil")
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "enableVideoButtonWhenReady", userInfo: nil, repeats: false)
        }
    }
        
    func enableVideoButtonWhenReady(){
        switch device.deviceOS! {
        case .Android:
            startWaitingForAndroidVideoReady()
        case .Ios:
            // videoButton.hidden = false
            print("showing video button for iOS")
            videoButton.enabled = true
        }
    }

    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
        setStatus("")
    }
    
    
    func hideButtons(){
        Util().fadeViewsOutStaggered([moreButton, cameraButton, videoButton])
        uninstallButton.alphaValue = 0
    }
    
    
    func showButtons(){
        Util().fadeViewsInStaggered([moreButton, cameraButton, videoButton])
        uninstallButton.alphaValue = 1
    }
    
    
    func transitionInstallInvite(moveIn:Bool=true, completion:()->Void){
        let move = CABasicAnimation(keyPath: "position.y")
        move.duration = 0.3
        
        if moveIn {
            move.toValue = 30
            move.fromValue = 20
        } else {
            move.toValue = 20
            move.fromValue = 30
        }
            
        move.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        installInviteView.wantsLayer = true
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.duration = 0.3
        
        if moveIn {
            fade.toValue = 1
            fade.fromValue = 0
        } else {
            fade.toValue = 0
            fade.fromValue = 1
        }
        
        fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            completion()
        }
        installInviteView.layer?.addAnimation(fade, forKey: "fader")
        installInviteView.layer?.addAnimation(move, forKey: "mover")
        CATransaction.commit()
    }
    
    
    func showInstallInvite(forApk apk:Apk){
        installInviteView.frame.origin = NSMakePoint(120, 30)
        view.addSubview(installInviteView)
        
        transitionInstallInvite(true) { () -> Void in }
        
        inviteAppName.stringValue = apk.appName
        if let versionName = apk.versionName {
            inviteVersions.stringValue = versionName
        }

        if let versionCode = apk.versionCode {
            inviteVersions.stringValue = "\(inviteVersions.stringValue) (\(versionCode))"
        }
        
        if let packageName = apk.packageName {
            invitePackageName.stringValue = packageName
        }
        
        if let localIcon = apk.localIconPath {
            print("icon is: \(localIcon)")
            let i = NSImage(byReferencingFile: localIcon)
            inviteIcon.image = i
        }
        
    }
    
    func hideInstallInviteView(){
        transitionInstallInvite(false) { () -> Void in
            self.installInviteView.removeFromSuperview()
        }

    }
    
    func dropDragEntered(filePath: String) {
        print("vc:dropDragEntered")

        if let fileExt = NSURL(fileURLWithPath: filePath).pathExtension {
            switch fileExt {
                case "apk":
                    hideButtons()
                    let a = ApkHandler(filepath: filePath, device: self.device)
                    a.getInfoFromApk { (apk) -> Void in
                        self.setStatus("Drop to install")
                        self.showInstallInvite(forApk: apk)
                }
                case "zip":
                    if NSUserDefaults.standardUserDefaults().boolForKey(C.PREF_FLASHIMAGESINZIPFILES){
                        setStatus("Drop to flash image with Fastboot")
                    } else {
                        setStatus("Enable flashing in Prefs first")
                }
                case "obb":
                    setStatus("Drop to copy OBB")
            default:
                setStatus("Whaaaaat, what is this file?")
            }
        }
    }
    
    func dropDragExited() {
        print("vc:dropDragExited")
        stopProgressIndication()
        hideInstallInviteView()
        showButtons()
        setStatus(" ")
    }
    
    func dropDragPerformed(filePath: String) {
        if device.deviceOS != .Android {return}
        startProgressIndication()

        print("vc:dropDragPerformed")
        
        if let fileExt = NSURL(fileURLWithPath: filePath).pathExtension {
            switch fileExt {
                case "apk":
                    installApk(filePath)
                    hideInstallInviteView()
                    showButtons()
                case "zip":
                    if NSUserDefaults.standardUserDefaults().boolForKey(C.PREF_FLASHIMAGESINZIPFILES){
                        flashZip(filePath)
                    } else {
                        stopProgressIndication()
                        self.setStatus("Enable flashing in Prefs")
                }
                case "obb":
                    installObb(filePath)
                default:
                stopProgressIndication()
                setStatus("Wait, what?")
            }
        }
    }
    

    
    func dropUpdated(mouseAt: NSPoint) {
        // print("vc:dropUpdated")
    }
    
    func installObb(filePath:String){
        print("installObb")
        startProgressIndication()
        let obbHandler = ObbHandler(filePath: filePath, device: self.device)
        obbHandler.delegate = self
        obbHandler.pushToDevice()
    }
    
    func obbHandlerDidFinish() {
        setStatus("Finished copying OBB file")
        stopProgressIndication()
    }

    
    func obbHandlerDidStart(bytes:String) {
        setStatus("Copying \(bytes) OBB file", shouldFadeOut: false)
        startProgressIndication()
    }

    
    func flashZip(filePath:String){
        print("flashZip")
        startProgressIndication()
        let handler = ZipHandler(filepath: filePath, device: self.device)
        handler.delegate = self
        handler.flash()
    }
    
    func zipHandlerDidFinish() {
        setStatus("Finished flashing image")
        stopProgressIndication()
    }
    
    func zipHandlerDidStart() {
        setStatus("Flashing image")
        startProgressIndication()
    }
    
    
    func installApk(apkPath:String){
        let apkHandler = ApkHandler(filepath: apkPath, device: self.device)
        apkHandler.delegate = self
        
        var apk:Apk!
        apkHandler.getInfoFromApk { (apkInfo) -> Void in
            apk = apkInfo
        }
        
        self.startProgressIndication()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(C.PREF_LAUNCHINSTALLEDAPP) {
            apkHandler.installAndLaunch({ () -> Void in
               print("installed and launched")
               self.stopProgressIndication()
               self.showUninstallButton(apk)
            })
        } else {
            apkHandler.install({ () -> Void in
                print("installed but not launched")
                self.stopProgressIndication()
                self.showUninstallButton(apk)
            })
        }
    }
    
    func showUninstallButton(apk:Apk){
        
        uninstallButton.title = "Uninstall \(apk.appName)"
        apkToUninstall = apk
        uninstallButton.hidden = false
        uninstallButton.fadeIn()
        uninstallButton.moveUpForUninstallButton(0.5)
        moreButton.moveUpForUninstallButton(0.6)
        videoButton.moveUpForUninstallButton(0.6)
    }
    
    func hideUninstallButton(){
        uninstallButton.fadeOut({ () -> Void in })
        uninstallButton.moveDownForUninstallButton(0.5)
        moreButton.moveDownForUninstallButton(0.6)
        videoButton.moveDownForUninstallButton(0.6)
    }
    
    @IBAction func uninstallPackageClicked(sender: AnyObject) {
        startProgressIndication()
        setStatus("Removing \(apkToUninstall.appName)...")
        let handler = ApkHandler(device: self.device)
        
        self.moreButton.moveDownForUninstallButton()
        self.videoButton.moveDownForUninstallButton()
        self.hideUninstallButton()
        
        if let packageName = apkToUninstall.packageName {
            handler.uninstallPackageWithName(packageName) { () -> Void in
                self.stopProgressIndication()
                self.setStatus("\(self.apkToUninstall.appName) removed")
            }
            }
    }
    
    
    func apkHandlerDidFinish() {
        print("apkHandlerDidFinish")
    }
    
    func apkHandlerDidGetInfo(apk: Apk) {
        print("apkHandlerDidGetInfo")
    }
    
    func apkHandlerDidStart() {
        print("apkHandlerDidStart")
    }
    
    func apkHandlerDidUpdate(update: String) {
        setStatus(update)
        print("apkHandlerDidUpdate: \(update)")
    }
    
    
    
    
}
