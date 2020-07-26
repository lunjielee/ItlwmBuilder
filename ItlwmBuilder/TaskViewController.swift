//
//  TaskViewController.swift
//  itlwmbuilder
//
//  Created by Lunjie Li on 2020-07-26.
//  Copyright © 2020 Lunjie Li. All rights reserved.
//

import Cocoa

class TaskViewController: NSViewController {
    
    @IBOutlet var pathLocation: NSPathControl!
    @IBOutlet var outputText: NSTextView!
    @IBOutlet var buildButton: NSButton!
    @IBOutlet var progressBar: NSProgressIndicator!
    @IBOutlet var stopButton: NSButton!
    @IBOutlet weak var versionList: NSPopUpButton!
    let versionArray = ["itlwm", "itlwmx"]
    @IBOutlet weak var withHeliPortChecked: NSButton!
    
    override func viewDidLoad() {
        stopButton.isEnabled = false
        progressBar.isHidden = true
        super.viewDidLoad()
        if (NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: "com.apple.dt.Xcode") != nil) {
            buildButton.isHidden = false
        } else {
            showCloseAlert()
            buildButton.isHidden = true
            pathLocation.isHidden = true
        }
        versionList.removeAllItems()
        versionList.addItems(withTitles: versionArray)
    }
    
    @objc dynamic var isRunning = false
    var outputPipe:Pipe!
    var buildTask:Process!
    
    @IBAction func startTask(_ sender: Any) {
        stopButton.isEnabled = true
        progressBar.isHidden = false
        outputText.string = ""
        if let repositoryURL = pathLocation.url {
            let cloneLocation = "/tmp"
            let finalLocation = repositoryURL.path
            var arguments:[String] = []
            arguments.append(cloneLocation)
            arguments.append(finalLocation)
            buildButton.isEnabled = false
            progressBar.startAnimation(self)
            if versionList.titleOfSelectedItem == "itlwm" {
                if withHeliPortChecked.state == NSControl.StateValue.on {
                    runitlwmScript(arguments)
                } else {
                    runitlwmWithoutHeliPortScript(arguments)
                }
            }
            if versionList.titleOfSelectedItem == "itlwmx" {
                if withHeliPortChecked.state == NSControl.StateValue.on {
                    runitlwmxScript(arguments)
                } else {
                    runitlwmxWithoutHeliPortScript(arguments)
                }
            }
        }
    }
    
    
    
    
    @IBAction func stopTask(_ sender: Any) {
        stopButton.isEnabled = false
        progressBar.isHidden = true
        if isRunning {
            self.progressBar.doubleValue = 0.0
            buildTask.terminate()
        }
    }
    
    func runitlwmScript(_ arguments:[String]) {
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async {
            guard let path = Bundle.main.path(forResource: "itlwm",ofType:"command") else {
                print("Unable to locate itlwm.command")
                return
            }
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            self.buildTask.terminationHandler = {
                task in
                DispatchQueue.main.async(execute: {
                    self.stopButton.isEnabled = false
                    self.buildButton.isEnabled = true
                    self.progressBar.isHidden = true
                    self.progressBar.stopAnimation(self)
                    self.progressBar.doubleValue = 0.0
                    self.isRunning = false
                })
            }
            self.captureStandardOutputAndRouteToTextViewReleaseWithKext(self.buildTask)
            self.buildTask.launch()
            self.buildTask.waitUntilExit()
        }
    }
    
    func runitlwmWithoutHeliPortScript(_ arguments:[String]) {
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async {
            guard let path = Bundle.main.path(forResource: "noheliport",ofType:"command") else {
                print("noheliport.command")
                return
            }
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            self.buildTask.terminationHandler = {
                task in
                DispatchQueue.main.async(execute: {
                    self.stopButton.isEnabled = false
                    self.buildButton.isEnabled = true
                    self.progressBar.isHidden = true
                    self.progressBar.stopAnimation(self)
                    self.progressBar.doubleValue = 0.0
                    self.isRunning = false
                })
            }
            self.captureStandardOutputAndRouteToTextViewonReleaseWithoutKext(self.buildTask)
            self.buildTask.launch()
            self.buildTask.waitUntilExit()
        }
    }
    
    func runitlwmxScript(_ arguments:[String]) {
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async {
            guard let path = Bundle.main.path(forResource: "itlwmx",ofType:"command") else {
                print("Unable to locate itlwmx.command")
                return
            }
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            self.buildTask.terminationHandler = {
                task in
                DispatchQueue.main.async(execute: {
                    self.stopButton.isEnabled = false
                    self.buildButton.isEnabled = true
                    self.progressBar.isHidden = true
                    self.progressBar.stopAnimation(self)
                    self.progressBar.doubleValue = 0.0
                    self.isRunning = false
                })
            }
            self.captureStandardOutputAndRouteToTextViewDebugWithKext(self.buildTask)
            self.buildTask.launch()
            self.buildTask.waitUntilExit()
        }
    }
    
    func runitlwmxWithoutHeliPortScript(_ arguments:[String]) {
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async {
            guard let path = Bundle.main.path(forResource: "noheliportx",ofType:"command") else {
                print("Unable to locate noheliportx.command")
                return
            }
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            self.buildTask.terminationHandler = {
                task in
                DispatchQueue.main.async(execute: {
                    self.stopButton.isEnabled = false
                    self.buildButton.isEnabled = true
                    self.progressBar.isHidden = true
                    self.progressBar.stopAnimation(self)
                    self.progressBar.doubleValue = 0.0
                    self.isRunning = false
                })
            }
            self.captureStandardOutputAndRouteToTextViewonDebugWithoutKext(self.buildTask)
            self.buildTask.launch()
            self.buildTask.waitUntilExit()
        }
    }
    
    func captureStandardOutputAndRouteToTextViewonReleaseWithoutKext(_ task:Process) {
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText.string
                let nextOutput = previousOutput + "\n" + outputString
                self.outputText.string = nextOutput
                let range = NSRange(location:nextOutput.count,length:0)
                self.outputText.scrollRangeToVisible(range)
                self.progressBar.increment(by: 8.3)
            })
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }
    
    func captureStandardOutputAndRouteToTextViewonDebugWithoutKext(_ task:Process) {
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText.string
                let nextOutput = previousOutput + "\n" + outputString
                self.outputText.string = nextOutput
                let range = NSRange(location:nextOutput.count,length:0)
                self.outputText.scrollRangeToVisible(range)
                self.progressBar.increment(by: 7.6)
            })
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }
    
    func captureStandardOutputAndRouteToTextViewReleaseWithKext(_ task:Process) {
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText.string
                let nextOutput = previousOutput + "\n" + outputString
                self.outputText.string = nextOutput
                let range = NSRange(location:nextOutput.count,length:0)
                self.outputText.scrollRangeToVisible(range)
                self.progressBar.increment(by: 1.9)
            })
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }
    
    func captureStandardOutputAndRouteToTextViewDebugWithKext(_ task:Process) {
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText.string
                let nextOutput = previousOutput + "\n" + outputString
                self.outputText.string = nextOutput
                let range = NSRange(location:nextOutput.count,length:0)
                self.outputText.scrollRangeToVisible(range)
                self.progressBar.increment(by: 1.9)
            })
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }
    
    func showCloseAlert() {
        let alert = NSAlert()
        alert.messageText = "Xcode Application is not installed!"
        alert.informativeText = "In order to use OCBuilder you must have the full Xcode application installed. Please install the full Xcode application from https://apps.apple.com/us/app/xcode/id497799835?mt=12."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

