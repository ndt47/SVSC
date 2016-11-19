//
//  MainWindowController.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/7/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MainWindowController : NSWindowController {
    
    var splitViewController: NSSplitViewController? {
        get {
            return self.contentViewController as? NSSplitViewController
        }
    }
    
    var queryListController: QueryListController? {
        get {
            var value: QueryListController? = nil
            if let items = splitViewController?.splitViewItems , items.count == 3 {
                value = items[0].viewController as? QueryListController
            }
            return value
        }
    }
    
    var memberListController: MemberListController? {
        get {
            var value: MemberListController? = nil
            if let items = splitViewController?.splitViewItems , items.count == 3 {
                value = items[1].viewController as? MemberListController
            }
            return value
        }
    }

    var memberDetailController: MemberDetailController? {
        get {
            var value: MemberDetailController? = nil
            if let items = splitViewController?.splitViewItems , items.count == 3 {
                value = items[2].viewController as? MemberDetailController
            }
            return value
        }
    }

    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case "showBadgesWindow":
            guard let dest = segue.destinationController as? PrintCardsWindowController else {
                return
            }

            if let members = self.memberListController?.selectedMembers {
                dest.members = members
            }
            break
        default:
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "showBadgesWindow":
            return self.memberListController?.selectedMembers.count > 0
        default:
            return true
        }
    }

    fileprivate var password = "w1ll1amg1bs0n"
    fileprivate var username = "nathantaylor@me.com"
    
    @IBAction func loadMembers(_ sender: AnyObject) -> Void {
        let waManager = WildApricotManager.sharedManager
        
        waManager.authenticate(username, password: password)
        waManager.downloadAllContacts { (json) -> Void in
            if let response = json {
                let db = Database.sharedDatabase
                db.importMembers(contacts: response)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "MembersQueryDidChange"), object: self, userInfo: ["members" : db.allMembers()])
            }
        }
//        waManager.downloadEvents { (events) -> Void in
//            print("EVENTS \(events)")
//        }
    }

    @IBAction func importGateLogs(_ sender: AnyObject?) -> Void {
        if let url = NSOpenPanel().selectUrl {
            print("\(url)")
            Database.sharedDatabase.importGateLogs(url, gate: Gate.Lower)
        }
    }
}

extension NSOpenPanel {
    var selectUrl: URL? {
        let fileOpenPanel = self
        fileOpenPanel.title = "Select File"
        fileOpenPanel.allowsMultipleSelection = false
        fileOpenPanel.canChooseDirectories = false
        fileOpenPanel.canChooseFiles = true
        fileOpenPanel.canCreateDirectories = false
        fileOpenPanel.runModal()
        return fileOpenPanel.urls.first
    }
}

