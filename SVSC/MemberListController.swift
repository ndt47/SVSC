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
        
        let data = self.data(using: String.Encoding.utf8)
        
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
}

class MemberListController: NSViewController, URLSessionDelegate, URLSessionDataDelegate, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet weak var cardView: CardView?
    
    var members = [Member]()
//    private let cardManager = CardManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.reloadData()
        
//        let tv = self.tableView!
//        weak var wSelf = self
//        cardManager?.readProxCards({ (card) -> Void in
//            var idx = 0
//            var foundMember: Member? = nil
//
//            if let this = wSelf {
//                for member in this.members {
//                    if member.membership?.gate_card == card {
//                        foundMember = member
//                        break
//                    }
//                    idx++
//                }
//            }
//            
//            Swift.print("Gate card: \(card)")
//            if let fm = foundMember {
//                tv.selectRowIndexes(NSIndexSet(index: idx), byExtendingSelection: false)
//                tv.scrollRowToVisible(idx)
//                NSNotificationCenter.defaultCenter().postNotificationName("SelectedMembersDidChange", object: nil, userInfo: ["selectedMembers" : [fm]])
//                let sound = NSSound(named: "R03 09 - ALERT01 - Synths Massive_A")
//                sound?.play()
//            }
//
//        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemberListController.membersListDidChange(_:)), name: NSNotification.Name(rawValue: "MembersQueryDidChange"), object: nil)
    }
    
    func generateBadges() {
        let dpi = 300
        
        // 8.5 x 11 @ 300 dpi
        var pageRect = CGRect(x: 0.0, y: 0.0, width: 8.5 * CGFloat(dpi), height: 11.0 * CGFloat(dpi))
        
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        guard let temp = tempDir.appendingPathComponent("badges.pdf") else {
            return
        }

        guard let ctx = CGContext(temp as CFURL, mediaBox: &pageRect, nil) else {
            return
        }
        
        // 7.0 x 10 @ 300 dpi
        let contentRect = pageRect.insetBy(dx: 0.75 * CGFloat(dpi), dy: 0.5 * CGFloat(dpi))
        
        ctx.beginPDFPage(nil)

        let badgeWidth: CGFloat = 3.5 * CGFloat(dpi)
        let badgeHeight: CGFloat = 2.0 * CGFloat(dpi)
        let _ = CGRect(x: contentRect.minX, y: contentRect.minY, width: badgeWidth, height: badgeHeight)
        
        ctx.rotate(by: CGFloat(M_PI_2))
        ctx.endPDFPage()
        
        ctx.closePDF()
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let member = members[row]
        if let column = tableColumn  {
            return member.value(forKey: column.identifier)
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let newDescriptors = tableView.sortDescriptors
     
        if let sortedMembers = NSArray(array: members).sortedArray(using: newDescriptors) as? [Member] {
            members = sortedMembers
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        return proposedSelectionIndexes
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        return false
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SelectedMembersDidChange"), object: nil, userInfo: ["selectedMembers" : self.selectedMembers])
    }
    
    func membersListDidChange(_ note: Notification) -> Void {
        guard let info = (note as NSNotification).userInfo else {
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
                (indexes as NSIndexSet).enumerate({ (i, _) -> Void in
                    selectedMembers.append(self.members[i])
                })
            }
            return selectedMembers
        }
    }

    @IBAction func showBadgesWindow(_ sender: AnyObject?) -> Void {
        Swift.print("show badges window")
    }
    
    @IBAction func printBadges(_ sender: AnyObject?) -> Void {
        let printInfo = NSPrintInfo.shared()
        let dpi = PrintCardsView.dpi
        
        printInfo.paperSize = NSSize(width: dpi * 8.5, height: dpi * 11)
        printInfo.orientation = .landscape
        printInfo.leftMargin = dpi * 0.75
        printInfo.rightMargin = dpi * 0.75
        printInfo.topMargin = dpi * 0.5
        printInfo.bottomMargin = dpi * 0.5
        printInfo.isVerticallyCentered = true
        printInfo.isHorizontallyCentered = true

        let view = PrintCardsView(members: self.selectedMembers)
        let printOp = NSPrintOperation(view: view, printInfo: printInfo)
        printOp.run()
    }
    
    @IBAction func refresh(_ sender: AnyObject?) -> Void {
        let group = DispatchGroup()
        
        for member in selectedMembers {
            group.enter()
            member.update(group.leave)
        }
        group.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            self.tableView?.reloadData()
        }))
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "showBadgesWindow":
            return selectedMembers.count > 0
        default:
            return true
        }
    }
}

