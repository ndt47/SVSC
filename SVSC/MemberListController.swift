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
    
    var resultSet: [Member]?
    private let cardManager = CardManager()
    
    let db = try? Database(path: "members.db")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let db = self.db else {
            print("failed to open database")
            return
        }
        
        resultSet = db.allMembers()
        tableView?.reloadData()
        
        cardManager?.readProxCards({ (card) -> Void in
            let sound = NSSound(named: "R03 09 - ALERT01 - Synths Massive_A")
            sound?.play()
            print("Gate card: \(card)")
        })
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
        guard let rows = resultSet else {
            return 0
        }
        return rows.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        guard let rows = resultSet else {
            return nil
        }
        let member = rows[row]
        if let column = tableColumn  {
            switch column.identifier {
            case "first_name":
                return member.contact.first_name.capitalizedString
            case "last_name":
                return member.contact.last_name.capitalizedString
            case "preferred_name":
                return member.contact.preferred_name?.capitalizedString
            case "email":
                return member.contact.email.lowercaseString
            case "member_id":
                return member.membership?.member_id
            case "member_level":
                return member.membership?.level.type.rawValue
            case "gate_card":
                return member.membership?.gate_card
            case "gate_status":
                return member.membership?.gate_status?.rawValue
            default:
                return nil
            }
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let _ = resultSet else {
            return
        }
    }
    
}