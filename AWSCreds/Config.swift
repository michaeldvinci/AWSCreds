//
//  Config.swift
//  AWSCreds
//
//  Created by Mike Vinci on 8/31/22.
//

import Foundation
import Cocoa

struct Config: Codable {
    var Profiles: [ProfileElement]
    
    private enum CodingKeys : String, CodingKey {
        case Profiles = "profiles"
    }
    
    init() {
        self.Profiles = []
    }
}

struct ProfileElement: Codable {
    var Name: String
    var AccessKey: String
    var SecretKey: String
    var Token: String?
    var Region: String?
    var Output: String?
    
    private enum CodingKeys : String, CodingKey {
        case Name = "name"
        case AccessKey = "access-key"
        case SecretKey = "secret-key"
        case Token = "token"
        case Region = "region"
        case Output = "output"
        
    }
    
    init() {
        self.Name = ""
        self.AccessKey = ""
        self.SecretKey = ""
        self.Token = ""
        self.Region = "us-west-2"
        self.Output = ""
    }
}

