//
//  Globals.swift
//  AWSCreds
//
//  Created by Mike Vinci on 8/23/22.
//

import Foundation
import os
import Cocoa
import INIParser
import PerfectINI

let bundleID = Bundle.main.bundleIdentifier!

let accessKey = "aws_access_key_id"
let secretKey = "aws_secret_access_key"

//let logger = OSLog(subsystem: bundleID, category: "kube")
var uiTesting = false
var testFileToImport: URL?
var testFileAsConfig: URL?

//var profile: Profile!
var statusBarButton: NSStatusBarButton!

//var profiles = [String]()
var allProfile: [String:[[String:String]]] = [:]

var currentProfile = "default"
//let decoder = INIDecoder()

var stringPath: String?
