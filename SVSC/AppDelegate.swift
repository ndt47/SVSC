//
//  AppDelegate.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/5/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    fileprivate var password = "w1ll1amg1bs0n"
    fileprivate var username = "secretary@scottsvalleysportsmen.com"
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let waManager = WildApricotManager.sharedManager
        
        waManager.authenticate(username, password: password)
        waManager.downloadAllContacts { (json) -> Void in
            if let response = json {
                let db = Database.sharedDatabase
                db.importMembers(contacts: response)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "MembersQueryDidChange"), object: self, userInfo: ["members" : db.allMembers()])
            }
        }
        waManager.downloadEvents { (events) -> Void in
            let db = Database.sharedDatabase
            db.importEvents(events: events)
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

