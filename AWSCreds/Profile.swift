//
//  Profile.swift
//  AWSCreds
//
//  Created by Mike Vinci on 8/23/22.
//

import Foundation
import EonilFSEvents
import PerfectINI

public class Aws {
    let fileManager = FileManager.default
    var creds:URL?
    var watcher: EonilFSEventStream!
    
    let credsChangedCallback: (EonilFSEventsEvent) -> () = {_ in
        print("event: ")
    }
    
    func showContextName() throws {
        print("event: ")
    }
    
    public init() {
        let f = loadBookmarks()
        if f == nil {
            print("need to fix bookmarking")
        }
        if creds == nil || creds != f {
            creds = openFolderSelection()
            initWatcher()
        }
    }
    
    func loadCreds(url: URL) throws -> URL? {

//        let decoder = INIDecoder()
//        var config = try decoder.decode(Config.self, from: fileContent)

        return url
    }
    
    func setConfig(credsFile: URL?) throws {
        if credsFile == nil {
            return
        }
        let _ = try loadCreds(url: credsFile!)
        
        if creds == nil || creds != credsFile {
            creds = credsFile
            initWatcher()
        }
        backupConfig ()
//        storeFolderInBookmark(url: credsFile!)
//        saveBookmarksData()
    }
    
    func initWatcher(){
        if watcher != nil {
            watcher.stop()
            watcher.invalidate()
        }
        do {
            watcher = try EonilFSEventStream(pathsToWatch: [(creds?.path)!],
                                             sinceWhen: .now,
                                             latency: 0,
                                             flags: [.noDefer, .fileEvents],
                                             handler: credsChangedCallback)
            watcher!.setDispatchQueue(DispatchQueue.main)
            try watcher!.start()
        } catch {
            NSLog("Error while starting watcher: %s", error as NSError)
        }
    }
    
    func backupConfig () {
        let origCredsURL = getOrigCredsFileUrl()
        do {
            if fileManager.isReadableFile(atPath: (origCredsURL?.path)!) {
                try fileManager.removeItem(at: origCredsURL!)
            }
            try fileManager.copyItem(at: creds!, to: origCredsURL!)
        } catch {
            NSLog("Error: could not backup original kubeconfig file: \(error)")
        }
    }
    
    func getCredsFilePath () -> String {
        return (creds?.path)!
    }
    
    func loadConfig(url: URL) throws -> Config? {
        fileContent = try String(contentsOf: url, encoding: .utf8)
        
        let decoder = INIDecoder()
        let config = try decoder.decode(Config.self, from: Data(contentsOf: URL(fileURLWithPath: fileContent)))
        
        for (i, ctx) in config.Profiles.enumerated() {
            if #available(OSX 10.13, *) {
                print("i: \(i), ctx: \(ctx)")
            }
        }

        return config
    }
    
    func importConfig(configToImportFileUrl: URL) throws {
        let mainConfig = try loadConfig(url: aws.creds!)
        
//        let mergedConfig = try mergeKubeconfigIntoConfig(configToImportFileUrl: configToImportFileUrl, mainConfig: mainConfig!)
//
//        try saveConfig(config: mergedConfig)
    }
    
//    func saveConfig(config: Config) throws {
//        try saveConfigToFile(config: config, file: kubeconfig)
//    }
    
    func getConfig(url: URL) throws -> Config? {
        return try loadConfig(url: url)
    }
    
}

func getOrigCredsFileUrl() -> URL? {
    let fileManager = FileManager.default
    do {
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let origCredsURL = documentDirectory.appendingPathComponent("aws_creds.orig")
        return origCredsURL
    } catch {
        NSLog("Error: could not get url of original aws creds file: \(error)")
        return nil
    }
}

