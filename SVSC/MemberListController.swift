//
//  MemberListController.swift
//  SVSCBadgePrinter
//
//  Created by Nathan Taylor on 2/20/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa
import SQLite

extension String {
    func base64()->String{
        
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        
        return data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
}

class MemberListController: NSViewController, NSURLSessionDelegate, NSURLSessionDataDelegate, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet weak var cardView: CardView?
    
    var members = [Member]()
    private let cardManager = CardManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.reloadData()
        
        let tv = self.tableView!
        weak var wSelf = self
        cardManager?.readProxCards({ (card) -> Void in
            var idx = 0
            var foundMember: Member? = nil

            if let this = wSelf {
                for member in this.members {
                    if member.membership?.gate_card == card {
                        foundMember = member
                        break
                    }
                    idx++
                }
            }
            
            Swift.print("Gate card: \(card)")
            if let fm = foundMember {
                tv.selectRowIndexes(NSIndexSet(index: idx), byExtendingSelection: false)
                tv.scrollRowToVisible(idx)
                NSNotificationCenter.defaultCenter().postNotificationName("SelectedMembersDidChange", object: nil, userInfo: ["selectedMembers" : [fm]])
                let sound = NSSound(named: "R03 09 - ALERT01 - Synths Massive_A")
                sound?.play()
            }

        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "membersListDidChange:", name: "MembersQueryDidChange", object: nil)
    }
    
    func generateBadges() {
        let dpi = 300
        
        // 8.5 x 11 @ 300 dpi
        var pageRect = CGRectMake(0.0, 0.0, 8.5 * CGFloat(dpi), 11.0 * CGFloat(dpi))
        
        let ctx = CGPDFContextCreateWithURL(nil, &pageRect, nil)
        
        // 7.0 x 10 @ 300 dpi
        let contentRect = CGRectInset(pageRect, 0.75 * CGFloat(dpi), 0.5 * CGFloat(dpi))
        
        CGPDFContextBeginPage(ctx, nil)

        let badgeWidth: CGFloat = 3.5 * CGFloat(dpi)
        let badgeHeight: CGFloat = 2.0 * CGFloat(dpi)
        let _ = CGRectMake(CGRectGetMinX(contentRect), CGRectGetMinY(contentRect), badgeWidth, badgeHeight)
        
        CGContextRotateCTM(ctx, CGFloat(M_PI_2))
        CGPDFContextEndPage(ctx)
        
        CGPDFContextClose(ctx)
        
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return members.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let member = members[row]
        if let column = tableColumn  {
            return member.valueForKey(column.identifier)
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let newDescriptors = tableView.sortDescriptors
     
        if let sortedMembers = NSArray(array: members).sortedArrayUsingDescriptors(newDescriptors) as? [Member] {
            members = sortedMembers
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet {
        return proposedSelectionIndexes
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableView(tableView: NSTableView, shouldSelectTableColumn tableColumn: NSTableColumn?) -> Bool {
        return false
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName("SelectedMembersDidChange", object: nil, userInfo: ["selectedMembers" : self.selectedMembers])
    }
    
    func membersListDidChange(note: NSNotification) -> Void {
        guard let info = note.userInfo else {
            return
        }
        if let newMembers = info["members"] as? [Member] {
            self.members = newMembers
            tableView?.reloadData()
        }
    }
    
    var selectedMembers: [Member] {
        get {
            var selectedMembers = [Member]()
            if let tv = self.tableView {
                let indexes = tv.selectedRowIndexes
                indexes.enumerateIndexesUsingBlock({ (i, _) -> Void in
                    selectedMembers.append(self.members[i])
                })
            }
            return selectedMembers
        }
    }

    @IBAction func showBadgesWindow(sender: AnyObject?) -> Void {
        Swift.print("show badges window")
    }
    
    @IBAction func printBadges(sender: AnyObject?) -> Void {
        let printInfo = NSPrintInfo.sharedPrintInfo()
        let dpi = PrintCardsView.dpi
        
        printInfo.paperSize = NSSize(width: dpi * 8.5, height: dpi * 11)
        printInfo.orientation = .Landscape
        printInfo.leftMargin = dpi * 0.75
        printInfo.rightMargin = dpi * 0.75
        printInfo.topMargin = dpi * 0.5
        printInfo.bottomMargin = dpi * 0.5
        printInfo.verticallyCentered = true
        printInfo.horizontallyCentered = true

        let view = PrintCardsView(members: self.selectedMembers)
        let printOp = NSPrintOperation(view: view, printInfo: printInfo)
        printOp.runOperation()
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case "showBadgesWindow":
            if let vc = segue.destinationController as? PrintCardsWindowController {
                vc.members = selectedMembers
            }
            break
        default:
            break
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case "showBadgesWindow":
            return selectedMembers.count > 0
        default:
            return true
        }
    }
}

