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
    
    private static func createDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .ShortStyle
        return dateFormatter
    }
    
    private let dpi: CGFloat = 72.0
    let dateFormatter: NSDateFormatter = CardView.createDateFormatter()
    let logo = NSImage(named: "SVSC Patch")
    
    private let redColor = NSColor(red: 211.0/255.0, green: 2.0/255.0, blue: 44.0/255.0, alpha: 1.0)
    private let mobColor = NSColor.blackColor()//NSColor(red: 135.0/255.0, green: 182.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    private let yellowColor = NSColor(red: 229.0/255.0, green: 140.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    private let tealColor = NSColor(red: 0.0/255.0, green: 99.0/255.0, blue: 71.0/255.0, alpha: 1.0)
    private let blueColor = NSColor(red: 0.0/255.0, green: 117.0/255.0, blue: 170.0/255.0, alpha: 1.0)
    
    private let svscFont = NSFont(name: "HoeflerText-Black", size: 13.0)
    private let titleFont = NSFont(name: "HoeflerText-Black", size: 18.0)
    private let holsterFont = NSFont(name: "Helvetica-Bold", size: 14.0)
    private let fullNameFont = NSFont(name: "Helvetica", size: 9.0)
    private let sponsorNameFont = NSFont(name: "Helvetica", size: 9.0)
    private let nameFont = NSFont(name: "HoeflerText-Black", size: 24.0)
    private let memberFont = NSFont(name: "Times-Bold", size: 14.0)
    private let probyFont = NSFont(name: "Helvetica", size: 9.0)
    @IBOutlet weak var title: NSTextField?
    @IBOutlet weak var nickname: NSTextField?
    @IBOutlet weak var svsc: NSTextField?
    @IBOutlet weak var holster: NSTextField?
    @IBOutlet weak var memberID : NSTextField?
    @IBOutlet weak var fullName: NSTextField?
    @IBOutlet weak var orientation: NSTextField?
    @IBOutlet weak var expiration: NSTextField?
    @IBOutlet weak var photo: NSImageView?
    @IBOutlet weak var shield: NSImageView?

    
    init(member: Member) {
        self.member = member
        super.init(frame: CGRectMake(0, 0, 2 * dpi, 3.5 * dpi))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
        let boardMembers = [
            2083 : "Secretary",
            1367 : "Range Master",
            1184 : "President",
            1444 : "Vice-President",
            1222 : "Treasurer",
            1243 : "Board Member",
            1660 : "Board Member",
        ]
        let bounds = self.bounds
        
        NSColor.whiteColor().set()
        NSBezierPath.fillRect(bounds)
        
        var mob = false
        var rso = false
        
        guard let member = self.member else {
            return
        }
        guard let membership = member.membership else {
            return
        }
        
        if let groups = member.groups {
            for group in groups {
                switch group.id {
                case 295206:
                    mob = true
                    break
                case 320364:
                    rso = true
                    break
                default:
                    break
                }
            }
        }
        
        var contentRect = NSInsetRect(bounds, dpi * 0.01, dpi * 0.01)
        
        var topBorderRect = NSZeroRect
        NSDivideRect(contentRect, &topBorderRect, &contentRect, dpi * 0.5, .MaxY)
        
        var leftBorderRect = NSZeroRect
        var rightBorderRect = NSZeroRect
        NSDivideRect(contentRect, &leftBorderRect, &contentRect, dpi * 0.13, .MinX)
        NSDivideRect(contentRect, &rightBorderRect, &contentRect, dpi * 0.13, .MaxX)
        
        var bottomBorderRect = NSZeroRect
        NSDivideRect(contentRect, &bottomBorderRect, &contentRect, dpi * 0.13, .MinY)
        
        var fullNameRect = NSZeroRect
        NSDivideRect(contentRect, &fullNameRect, &contentRect, dpi * 0.375, .MinY)
        
        var holsterRect = NSZeroRect
        NSDivideRect(contentRect, &holsterRect, &contentRect, dpi * 0.375, .MinY)
        
        var memberRect = NSZeroRect
        NSDivideRect(contentRect, &memberRect, &contentRect, dpi * 0.35, .MinY)
        
        var nameRect = NSZeroRect
        NSDivideRect(contentRect, &nameRect, &contentRect, dpi * 0.6, .MinY)
        
        var logoRect = NSZeroRect
        var photoRect = NSZeroRect
        NSDivideRect(contentRect, &logoRect, &photoRect, contentRect.size.width / 2.0, .MaxX)
        
        logoRect.insetInPlace(dx: 4.0, dy: 4.0)
        photoRect.insetInPlace(dx: 8.0, dy: 8.0)

        if mob {
            if let member_id = membership.member_id where member_id == 1367 {
                redColor.setFill()
            }
            else {
                mobColor.setFill()
            }
        }
        else if rso {
            redColor.setFill()
        }
        else {
            yellowColor.setFill()
        }
        NSBezierPath.fillRect(topBorderRect)
        yellowColor.setFill()
        NSBezierPath.fillRect(rightBorderRect)
        
        tealColor.setFill()
        NSBezierPath.fillRect(leftBorderRect)
        NSBezierPath.fillRect(memberRect)
        
        blueColor.setFill()
        NSBezierPath.fillRect(holsterRect)
        NSBezierPath.fillRect(bottomBorderRect)
        
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .Center
        pStyle.lineBreakMode = .ByClipping
        pStyle.allowsDefaultTighteningForTruncation = true
        
        leftBorderRect.size.height = bounds.size.height
        leftBorderRect.origin.y = 0.0
        "S\nV\nS\nC".drawVerticallyCenteredInRect(leftBorderRect, attributes: [NSFontAttributeName : svscFont!, NSForegroundColorAttributeName : NSColor.whiteColor(),
            NSParagraphStyleAttributeName : pStyle])
        
        logo?.drawCenteredInRect(logoRect)
        
        NSColor.whiteColor().set()
        var needSponsor = false
        var drawPhoto = true
        if let member_id = membership.member_id where member_id > 0 {
            var headerFont = titleFont!
            var header = ""
            let prefix = membership.level.type.className()
            
            switch membership.level.type {
            case .Regular, .Regular_Service, .Life, .Disabled_Veteran, .SVPD, .Seaside, .Youth, .Senior:
                header = "Member"
                break
            case .Applicant, .Probationary, .Youth_Probationary:
                header = "Probationary"
                needSponsor = true
                drawPhoto = false
                break
            default:
                header = ""
            }

            if mob {
                if let bmp = boardMembers[member_id] {
                    header = bmp
                }
                headerFont = NSFont(name: headerFont.fontName, size: 14.0)!
            }
            else if rso {
                header = "Range Safety Officer"
                headerFont = NSFont(name: headerFont.fontName, size: 13.0)!
            }
            
            header.drawVerticallyCenteredInRect(topBorderRect, attributes: [NSFontAttributeName : headerFont, NSForegroundColorAttributeName : NSColor.whiteColor(),
                NSParagraphStyleAttributeName : pStyle])

            "\(prefix!) / \(member_id)".drawVerticallyCenteredInRect(memberRect, attributes: [NSFontAttributeName : memberFont!, NSForegroundColorAttributeName : NSColor.whiteColor(),
                NSParagraphStyleAttributeName : pStyle])
            
            if drawPhoto {
                if let path = NSBundle.mainBundle().pathForResource("\(member_id)", ofType: "jpg", inDirectory: "photos") {
                    if let photo = NSImage(byReferencingFile: path) {
                        photo.drawCenteredInRect(photoRect)
                    }
                }
            }
            else {
                if let od = membership.orientation_date, let ped = membership.prob_exp_date {
                    "Orientation:\n\(dateFormatter.stringFromDate(od))\n\nExpiration:\n\(dateFormatter.stringFromDate(ped))".drawVerticallyCenteredInRect(photoRect, attributes: [NSFontAttributeName : probyFont!, NSForegroundColorAttributeName : NSColor.blackColor(),
                        NSParagraphStyleAttributeName : pStyle])
                }
            }
        }
        if let holster = membership.holster {
            switch holster {
            case .Yes:
                "HOLSTER".drawVerticallyCenteredInRect(holsterRect, attributes: [NSFontAttributeName : holsterFont!, NSForegroundColorAttributeName : NSColor.whiteColor(),
                    NSParagraphStyleAttributeName : pStyle])
                break
            default:
                break
            }
        }
        
        NSColor.blackColor().set()
        var nameString = "\(member.contact.first_name.uppercaseString) \(member.contact.last_name.uppercaseString)"
        if let sponsorName = member.sponsor?.name where needSponsor {
            nameString += "\nSponsor: \(sponsorName.uppercaseString)"
        }
        nameString.drawVerticallyCenteredInRect(fullNameRect, attributes: [NSFontAttributeName : sponsorNameFont!, NSForegroundColorAttributeName : NSColor.blackColor(),
            NSParagraphStyleAttributeName : pStyle])
        
        var nameFont = self.nameFont!
        var name = member.contact.first_name
        if let nickname = member.contact.preferred_name where nickname.characters.count > 1 {
            name = nickname
        }
        if name.characters.count > 8 {
            nameFont = NSFont(name: nameFont.fontName, size: 20.0)!
        }
        name.capitalizedString.drawVerticallyCenteredInRect(nameRect, attributes: [NSFontAttributeName : nameFont, NSForegroundColorAttributeName : NSColor.blackColor(),
            NSParagraphStyleAttributeName : pStyle])
        
    }
}


extension String {
    func drawVerticallyCenteredInRect(rect: NSRect, attributes: [String : AnyObject]?) {
        let string = NSString(string: self)
        let options = NSStringDrawingOptions.UsesLineFragmentOrigin
        
        let context = NSStringDrawingContext()
        context.minimumScaleFactor = 0.75
        
        let bounds = string.boundingRectWithSize(rect.size, options: options, attributes: attributes, context: context)
        
        if (context.actualScaleFactor < 1.0) {
            print("Scaled \(context.actualScaleFactor)")
        }
        
        let deltaY = (rect.size.height - bounds.size.height) / 2.0
        var drawRect = rect
        drawRect.origin.y -= deltaY
        
        string.drawWithRect(drawRect, options: options, attributes: attributes, context: context)
        
        if (context.actualScaleFactor < 1.0) {
            print("Scaled \(context.actualScaleFactor)")
        }
    }
}

extension NSImage {
    func drawCenteredInRect(rect: NSRect) {
        
        let size = self.size;
        let aspect = size.width/size.height
        
        let newHeight = rect.size.width / aspect
        let deltaY = (rect.size.height - newHeight) / 2.0
        
        let centeredRect = NSMakeRect(rect.origin.x, rect.origin.y + deltaY, rect.size.width, newHeight)
        drawInRect(centeredRect)
    }
}