//
//  MainWindowController.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/7/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa

class MainWindowController : NSWindowController {
    var splitViewController: NSSplitViewController? {
        get {
            return self.contentViewController as? NSSplitViewController
        }
    }
    
    var queryListController: QueryListController? {
        get {
            var value: QueryListController? = nil
            if let items = splitViewController?.splitViewItems where items.count == 3 {
                value = items[0].viewController as? QueryListController
            }
            return value
        }
    }
    
    var memberListController: MemberListController? {
        get {
            var value: MemberListController? = nil
            if let items = splitViewController?.splitViewItems where items.count == 3 {
                value = items[1].viewController as? MemberListController
            }
            return value
        }
    }

    var memberDetailController: MemberDetailController? {
        get {
            var value: MemberDetailController? = nil
            if let items = splitViewController?.splitViewItems where items.count == 3 {
                value = items[2].viewController as? MemberDetailController
            }
            return value
        }
    }

    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case "showBadgesWindow":
            return self.memberListController?.selectedMembers.count > 0
        default:
            return true
        }
    }

}
