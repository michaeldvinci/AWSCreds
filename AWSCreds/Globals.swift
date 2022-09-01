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

var uiTesting = false
var testFileToImport: URL?
var testFileAsConfig: URL?
var funcPath: URL?

var aws: Aws!
var statusBarButton: NSStatusBarButton!

var allProfile: [String:[[String:String]]] = [:]
var profiles: [Aws] = []

var currentProfile = "default"
//let decoder = INIDecoder()

var stringPath: String?
var fileContent: String = ""
