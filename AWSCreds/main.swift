//
//  main.swift
//  AWSCreds
//
//  Created by Mike Vinci on 8/23/22.
//

import Cocoa
import Foundation

// 1
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// 2
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
