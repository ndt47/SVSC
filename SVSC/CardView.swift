//
//  CardView.swift
//  SVSCBadgePrinter
//
//  Created by Nathan Taylor on 3/4/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa

class CardView : NSView {
    var member: Member? = nil
    
    static let dpi: CGFloat = 100.0
    let logo = NSImage(named: "SVSC Patch")
    
    private let redColor = NSColor(red: 211.0/255.0, green: 2.0/255.0, blue: 44.0/255.0, alpha: 1.0)
    private let mobColor = NSColor(red: 135.0/255.0, green: 182.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    private let yellowColor = NSColor(red: 229.0/255.0, green: 140.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    private let tealColor = NSColor(red: 0.0/255.0, green: 99.0/255.0, blue: 71.0/255.0, alpha: 1.0)
    private let blueColor = NSColor(red: 0.0/255.0, green: 117.0/255.0, blue: 170.0/255.0, alpha: 1.0)
    
    private let svscFont = NSFont(name: "Cochin-Bold", size: 18.0)
    private let titleFont = NSFont(name: "Cochin-Bold", size: 18.0)
    private let holsterFont = NSFont(name: "Helvetica-Bold", size: 16.0)
    private let fullNameFont = NSFont(name: "Helvetica", size: 10.0)
    private let sponsorNameFont = NSFont(name: "Helvetica", size: 10.0)
    private let nameFont = NSFont(name: "Cochin-Bold", size: 48.0)
    private let memberFont = NSFont(name: "Cochin", size: 14.0)

    init(member: Member) {
        self.member = member
        super.init(frame: CGRectMake(0, 0, 2 * CardView.dpi, 3.5 * CardView.dpi))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(dirtyRect: NSRect) {
        guard let member = self.member else {
            return
        }
        guard let membership = member.membership else {
            return
        }
        
        let bounds = self.bounds
        let dpi = CardView.dpi
        var contentRect = NSInsetRect(bounds, dpi * 0.05, dpi * 0.05)
        
        var topBorderRect = NSZeroRect
        NSDivideRect(contentRect, &topBorderRect, &contentRect, dpi * 0.5, .MinY)
        
        var leftBorderRect = NSZeroRect
        var rightBorderRect = NSZeroRect
        NSDivideRect(contentRect, &leftBorderRect, &contentRect, dpi * 0.13, .MinX)
        NSDivideRect(contentRect, &rightBorderRect, &contentRect, dpi * 0.13, .MaxX)
        
        var bottomBorderRect = NSZeroRect
        NSDivideRect(contentRect, &bottomBorderRect, &contentRect, dpi * 0.25, .MaxY)
        
        var fullNameRect = NSZeroRect
        NSDivideRect(contentRect, &fullNameRect, &contentRect, dpi * 0.375, .MaxY)
        
        var holsterRect = NSZeroRect
        NSDivideRect(contentRect, &holsterRect, &contentRect, dpi * 0.375, .MaxY)
        
        var memberRect = NSZeroRect
        NSDivideRect(contentRect, &memberRect, &contentRect, dpi * 0.35, .MaxY)
        
        var nameRect = NSZeroRect
        NSDivideRect(contentRect, &nameRect, &contentRect, dpi * 0.75, .MaxY)

        yellowColor.setFill()
        NSBezierPath.fillRect(topBorderRect)
        NSBezierPath.fillRect(rightBorderRect)
        
        tealColor.setFill()
        NSBezierPath.fillRect(leftBorderRect)
        NSBezierPath.fillRect(memberRect)
        
        blueColor.setFill()
        NSBezierPath.fillRect(holsterRect)
        NSBezierPath.fillRect(bottomBorderRect)
        
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .Center
        
        NSString(string: "S\nV\nS\nC").drawWithRect(leftBorderRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : svscFont!, NSForegroundColorAttributeName : NSColor.whiteColor(),
            NSParagraphStyleAttributeName : pStyle])
        
        NSColor.whiteColor().set()
        if let member_id = membership.member_id {
            var header = ""
            
            switch membership.level.type {
            case .Regular, .Regular_Service, .Life, .Disabled_Veteran, .SVPD, .Seaside, .Youth:
                header = "Member"
                break
            case .Applicant, .Probationary, .Youth_Probationary:
                header = "Probationary"
                break
            default:
                header = ""
            }
            NSString(string: header).drawWithRect(topBorderRect, options: NSStringDrawingOptions(rawValue:0), attributes: [NSFontAttributeName : titleFont!, NSForegroundColorAttributeName : NSColor.whiteColor(),
                NSParagraphStyleAttributeName : pStyle])

            var prefix = "Regular"
            switch membership.level.type {
            case .Seaside:
                prefix = "Seaside"
                break
            case .SVPD:
                prefix = "SVPD"
                break
            case .Youth, .Youth_Probationary:
                prefix = "Youth"
                break
            case .Life:
                prefix = "Life"
                break
            case .Disabled_Veteran:
                prefix = "Veteran"
                break
            case .Senior:
                prefix = "Senior"
                break
            case .Regular, .Regular_Service:
                prefix = "Regular"
                break
            default:
                break
            }
            NSString(string: "\(prefix) / \(member_id)").drawWithRect(memberRect, options: NSStringDrawingOptions(rawValue:0), attributes: [NSFontAttributeName : memberFont!, NSForegroundColorAttributeName : NSColor.whiteColor(),
                NSParagraphStyleAttributeName : pStyle])
        }
        if let holster = membership.holster {
            switch holster {
            case .Yes:
                NSString(string: "Holster".uppercaseString) .drawWithRect(holsterRect, options: NSStringDrawingOptions(rawValue:0), attributes: [NSFontAttributeName : holsterFont!, NSForegroundColorAttributeName : NSColor.whiteColor(),
                    NSParagraphStyleAttributeName : pStyle])
                break
            default:
                break
            }
        }
        
        NSColor.blackColor().set()
        var nameString = "\(member.contact.first_name.uppercaseString) \(member.contact.last_name.uppercaseString)"
        if let sponsorName = member.sponsor?.name {
            nameString += "\nSponsor: \(sponsorName)"
        }
        NSString(string: nameString).drawWithRect(fullNameRect, options: NSStringDrawingOptions(rawValue:0), attributes: [NSFontAttributeName : sponsorNameFont!, NSForegroundColorAttributeName : NSColor.blackColor(),
            NSParagraphStyleAttributeName : pStyle])
        
        var name = member.contact.first_name
        if let nickname = member.contact.preferred_name {
            name = nickname
        }
        NSString(string: name.capitalizedString).drawWithRect(nameRect, options: NSStringDrawingOptions(rawValue:0), attributes: [NSFontAttributeName : nameFont!, NSForegroundColorAttributeName : NSColor.blackColor(),
            NSParagraphStyleAttributeName : pStyle])
        
        
    }
}