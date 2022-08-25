//
//  Globals.swift
//  AWSCreds
//
//  Created by Mike Vinci on 8/23/22.
//

import Foundation
import os
import Cocoa

let bundleID = Bundle.main.bundleIdentifier!

//let logger = OSLog(subsystem: bundleID, category: "kube")
var uiTesting = false
var testFileToImport: URL?
var testFileAsConfig: URL?

//var profile: Profile!
var statusBarButton: NSStatusBarButton!

var profiles = [String]()


