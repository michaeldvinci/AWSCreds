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
//import Yams
//import EonilFSEvents

//@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("icon-small"))
        }
        
        do {
            try setupMenus()
        }
        catch {
            print("fail")
        }
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
    
    @objc func openFolderSelection() -> URL?
    {
        let dialog = NSOpenPanel();
        
        //dialog.title                   = "Choose kubeconfig file";
        dialog.message                 = "Choose AWS credentials file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = true;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                NSLog(path)
            }
            return result
        } else {
            // User clicked on "Cancel"
            return nil
        }
    }
    
    @objc func toggleState(_ sender: NSMenuItem) {
        let ctxMenu = sender.menu!.items
        for ctxM in ctxMenu {
            if ctxM != sender {
                ctxM.state = NSControl.StateValue.off
            }
        }
        if sender.state == NSControl.StateValue.off {
            sender.state = NSControl.StateValue.on
            do {
                try grabExport(name: sender.title)
            } catch {
                NSLog ("Could not switch profile: \(error)")
            }
        }
    }
    
    @objc func logClick(_ sender: NSMenuItem) {
        NSLog("Clicked on " + sender.title)
    }
    
    func grabExport(name: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("export AWS_PROFILE='\(name)'", forType: .string)
    }
    
    func selectAwsCredsFile() throws {
        NSLog("will select AWS credentials file...")
        var kubeconfigFileUrl: URL?
        if testFileAsConfig == nil {
            kubeconfigFileUrl = openFolderSelection()
        } else {
            kubeconfigFileUrl = testFileAsConfig
        }
        if kubeconfigFileUrl == nil {
            NSLog("Error: Could not get selected file!")
            return
        }
    }
    
    @objc func setupMenus() throws {
        // 1
        let menu = NSMenu()
        menu.removeAllItems()
        profiles = []
        let funcPath = openFolderSelection()
        let stringPath = funcPath?.absoluteString.replacingOccurrences(of: "file://", with: "")
        let parser = try INIParser(stringPath!)
        
        menu.removeAllItems()
        let centerParagraphStyle = NSMutableParagraphStyle.init()
        centerParagraphStyle.alignment = .center
        
        let switchProfileSubmenu = NSMenu()
                
        for section in parser.sections {
            profiles.append(section.0)
        }
        profiles.sort()
        
        for profile in profiles {
            let profileMenuItem = NSMenuItem(title: profile, action: #selector(toggleState), keyEquivalent: "")
            profileMenuItem.target = self
            switchProfileSubmenu.addItem(profileMenuItem)
        }
        
//        for profile in profiles {
//            if profile.contains("[") {
//                count = count + 1
//                let profileClean = profile.replacingOccurrences(of: "[",with: "").replacingOccurrences(of: "]",with: "")
//                let profileMenuItem = NSMenuItem(title: profileClean, action: #selector(toggleState), keyEquivalent: "")
//                profileMenuItem.target = self
//                switchProfileSubmenu.addItem(profileMenuItem)
//            }
//        }
        
        let titleVar = "AWS Profiles"
        
        if switchProfileSubmenu.items.count < 1 {
            let noProMenuItem = NSMenuItem(title: "No more profiles", action: nil, keyEquivalent: "")
            switchProfileSubmenu.addItem(noProMenuItem)
        }
        
        let currentProfileTextItem = NSMenuItem(title: "", action: #selector(logClick(_:)), keyEquivalent: "")
        currentProfileTextItem.target = self
        let currentProfileText = NSAttributedString.init(string: titleVar, attributes: [NSAttributedString.Key.paragraphStyle: centerParagraphStyle])
        currentProfileTextItem.attributedTitle = currentProfileText
        menu.addItem(currentProfileTextItem)
        
        // Seperator
        menu.addItem(NSMenuItem.separator())
        
        // Switch Profile
        let switchProfileMenuItem = NSMenuItem(title: "Switch Profile", action: nil, keyEquivalent: "c")
        switchProfileMenuItem.target = self
        menu.addItem(switchProfileMenuItem)
        // Switch Profile Submenu
        menu.setSubmenu(switchProfileSubmenu, for: switchProfileMenuItem)
        
        // Choose Creds File
        let chooseCredsMenuItem = NSMenuItem(title: "Import Creds", action: #selector(setupMenus), keyEquivalent: "i")
        chooseCredsMenuItem.target = self
        menu.addItem(chooseCredsMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }
}
