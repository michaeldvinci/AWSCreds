//
//  Globals.swift
//  KubeContext
//
//  Created by Turken, Hasan on 20.10.18.
//  Copyright © 2018 Turken, Hasan. All rights reserved.
//

import Foundation
import os
import Cocoa

let bundleID = Bundle.main.bundleIdentifier!
let proProductId = bundleID + ".pro"

//let logger = OSLog(subsystem: bundleID, category: "kube")
var uiTesting = false
var testFileToImport: URL?
var testFileAsConfig: URL?

//var profile: Profile!
var statusBarButton: NSStatusBarButton!

var profiles = [String]()


