//
//  AppDelegate.swift
//  AWSCreds
//
//  Created by Mike Vinci on 8/23/22.
//

import Cocoa
import Foundation
import os
import INIParser
import PerfectINI
//import EonilFSEvents

//@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let mbMgr = MenuBarManager()
    
    struct Profile: Codable {
        var name: String
        var accessKey: String
        var secretKey: String
        var token: String?
        var region: String?
        var output: String?
    }
    
    var profiles: [Profile] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("icon-small"))
        }
        
        let menu = NSMenu()
        menu.delegate = mbMgr
        statusItem.menu = menu
        
        aws = Aws()
//        do {
//            try setupMenus()
//        }
//        catch {
////            print(error)
//        }
    }
    
    @discardableResult
    func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    enum MyError: Error {
        case runtimeError(String)
    }
    
    //    func backupIni(file: String, filemgr: FileManager) {
    //        do {
    //            try filemgr.copyItem(atPath:  file, toPath: "./creds.bak")
    //        } catch {
    //            print("Error: \(error.localizedDescription)")
    //        }
    //    }
}
