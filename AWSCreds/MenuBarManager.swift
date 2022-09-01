//
//  MenuBarManager.swift
//  AWSCreds
//
//  Created by Mike Vinci on 9/1/22.
//

import Foundation
import Cocoa
import INIParser
import PerfectINI

class MenuBarManager: NSObject, NSMenuDelegate {
    var manageController: NSWindowController?
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var window: NSWindow!
    
    struct Profile: Codable {
        var name: String
        var accessKey: String
        var secretKey: String
        var token: String?
        var region: String?
        var output: String?
    }
    var profiles: [Profile] = []
    
    override init() {
        super.init()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        if aws == nil {
            print("willOpen new")
            ConstructInitMenu(menu: menu)
        } else {
            print("willOpen else")
            SetupMainMenu(menu: menu)
        }
    }
    
    @objc func toggleState(_ sender: NSMenuItem) {
        let profMenu = sender.menu!.items
        for profM in profMenu {
            if profM != sender {
                profM.state = NSControl.StateValue.off
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
    
    @objc func importConfig(_ sender: NSMenuItem) {
        NSLog("will import file...")
        if aws == nil {
            alertUserWithWarning(message: "Not able to import config file, aws not initialized!")
            return
        }
        var configToImportFileUrl: URL?
        if testFileToImport == nil {
            configToImportFileUrl = openFolderSelection()
        } else {
            configToImportFileUrl = testFileToImport
        }
        if configToImportFileUrl == nil {
            return
        }
        do {
            try aws.importConfig(configToImportFileUrl: configToImportFileUrl!)
        } catch {
            alertUserWithWarning(message: "Not able to import config file \(error)")
        }
    }
    
    func ConstructInitMenu(menu: NSMenu){

        menu.removeAllItems()
        let selectConfigMenuItem = NSMenuItem(title: "Select AWS creds file", action:  #selector(selectCredsFile(_:)), keyEquivalent: "c")
        selectConfigMenuItem.target = self
        menu.addItem(selectConfigMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    @objc func selectCredsFile(_ sender: NSMenuItem) {
        do {
            try selectAwsCredsFile()
        } catch {
            alertUserWithWarning(message: "Could not parse selected kubeconfig file\n \(error)")
        }
    }
    
    func grabExport(name: String) throws {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("export AWS_PROFILE='\(name)'", forType: .string)
    }
    
    func debugProfiles(profiles: [Profile]) {
        for profile in profiles {
            print("name: " + profile.name)
            print("aws_access_key_id: " + profile.accessKey)
            print("aws_secret_access_key: " + profile.secretKey)
            print("token: " + (profile.token ?? "none"))
            print("region: " + (profile.region ?? "none"))
            print("output: " + (profile.output ?? "none"))
            print("-------------------------------------")
        }
    }
    
    func SetupMainMenu(menu: NSMenu) {
        menu.removeAllItems()
        profiles = []
        funcPath = aws.creds!
        let switchProfileSubmenu = NSMenu()
        menu.removeAllItems()

        if funcPath != nil {
            stringPath = funcPath!.absoluteString.replacingOccurrences(of: "file://", with: "")
//            backupIni(file: stringPath!, filemgr: FileManager.default)
            do {
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
                    let encoder = INIEncoder()
                    profiles.append(profile)
                }
                profiles = profiles.sorted  { $0.name < $1.name }
            } catch {
                print(error)
            }
//            debugProfiles(profiles: profiles)

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

        menu.addItem(NSMenuItem.separator())

        let switchProfileMenuItem = NSMenuItem(title: "Switch Profile", action: nil, keyEquivalent: "c")
        switchProfileMenuItem.target = self
        menu.addItem(switchProfileMenuItem)
        menu.setSubmenu(switchProfileSubmenu, for: switchProfileMenuItem)

        let chooseCredsMenuItem = NSMenuItem(title: "Import Creds", action: #selector(selectCredsFile(_:)), keyEquivalent: "i")
        chooseCredsMenuItem.target = self
        menu.addItem(chooseCredsMenuItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }
        
    func alertUserWithWarning(message: String) {
        let alert = NSAlert()
        alert.icon = NSImage.init(named: NSImage.cautionName)
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
