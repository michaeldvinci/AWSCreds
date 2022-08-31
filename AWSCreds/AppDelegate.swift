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
//import Yams
//import EonilFSEvents

//@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var statusItem: NSStatusItem!
    
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
            currentProfile = sender.title
            do {
                try grabExport(name: sender.title)
                print("currentProfile: " + currentProfile)
            } catch {
                NSLog ("Could not switch profile: \(error)")
            }
        }
    }
    
    @objc func logClick(_ sender: NSMenuItem) {
        NSLog("Clicked on " + sender.title)
    }
    
    func parseINI(iniText: String) {
        
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
        let switchProfileSubmenu = NSMenu()
        menu.removeAllItems()
        
        if funcPath != nil {
            stringPath = funcPath?.absoluteString.replacingOccurrences(of: "file://", with: "")
            let parser = try INIParser(stringPath!)
            for section in parser.sections {
                let profile = Profile(
                    name: section.0,
                    accessKey: (section.1["aws_access_key_id"] ?? ""),
                    secretKey: (section.1["aws_secret_access_key"] ?? ""),
                    token: (section.1["token"] ?? ""),
                    region: "us-west-2",
                    output: (section.1["output"] ?? "")
                )
                profiles.append(profile)
            }
            profiles = profiles.sorted  { $0.name < $1.name }

            for profile in profiles {
                print("name: " + profile.name)
                print("aws_access_key_id: " + profile.accessKey)
                print("aws_secret_access_key: " + profile.secretKey)
                print("token: " + (profile.token ?? "none"))
                print("region: " + (profile.region ?? "none"))
                print("output: " + (profile.output ?? "none"))
                print("-------------------------------------")
            }
            
        } else {
            let noProMenuItem = NSMenuItem(title: "No more profiles", action: nil, keyEquivalent: "")
            switchProfileSubmenu.addItem(noProMenuItem)
        }
                        
        let centerParagraphStyle = NSMutableParagraphStyle.init()
        centerParagraphStyle.alignment = .center
        
        for profile in profiles {
            let profileMenuItem = NSMenuItem(title: profile.name, action: #selector(toggleState), keyEquivalent: "")
            profileMenuItem.target = self
            switchProfileSubmenu.addItem(profileMenuItem)
        }
        
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
