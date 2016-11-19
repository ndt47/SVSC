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
    
    fileprivate static func createDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        return dateFormatter
    }
    
    fileprivate let dpi: CGFloat = 72.0
    let dateFormatter: DateFormatter = CardView.createDateFormatter()
    let logo = NSImage(named: "SVSC Patch")
    
    fileprivate let redColor = NSColor(red: 211.0/255.0, green: 2.0/255.0, blue: 44.0/255.0, alpha: 1.0)
    fileprivate let mobColor = NSColor.black//NSColor(red: 135.0/255.0, green: 182.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    fileprivate let yellowColor = NSColor(red: 229.0/255.0, green: 140.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    fileprivate let tealColor = NSColor(red: 0.0/255.0, green: 99.0/255.0, blue: 71.0/255.0, alpha: 1.0)
    fileprivate let blueColor = NSColor(red: 0.0/255.0, green: 117.0/255.0, blue: 170.0/255.0, alpha: 1.0)
    
    fileprivate let svscFont = NSFont(name: "HoeflerText-Black", size: 13.0)
    fileprivate let titleFont = NSFont(name: "HoeflerText-Black", size: 18.0)
    fileprivate let holsterFont = NSFont(name: "Helvetica-Bold", size: 14.0)
    fileprivate let fullNameFont = NSFont(name: "Helvetica", size: 9.0)
    fileprivate let sponsorNameFont = NSFont(name: "Helvetica", size: 9.0)
    fileprivate let nameFont = NSFont(name: "HoeflerText-Black", size: 24.0)
    fileprivate let memberFont = NSFont(name: "Times-Bold", size: 14.0)
    fileprivate let probyFont = NSFont(name: "Helvetica", size: 9.0)
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
        super.init(frame: CGRect(x: 0, y: 0, width: 2 * dpi, height: 3.5 * dpi))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let defaults = UserDefaults.standard
        let printRSO = defaults.bool(forKey: "showRangeSafetyOfficer")
        let printMOB = defaults.bool(forKey: "showMemberOfBoard")
        
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
        
        NSColor.white.set()
        NSBezierPath.fill(bounds)
        
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
                    mob = printMOB
                    break
                case 320364:
                    switch membership.level.type {
                    case .Regular, .Senior, .Life:
                        rso = printRSO
                        break
                    default:
                        rso = false
                        break
                    }
                    break
                default:
                    break
                }
            }
        }
        
        var contentRect = NSInsetRect(bounds, dpi * 0.01, dpi * 0.01)
        
        var topBorderRect = NSZeroRect
        NSDivideRect(contentRect, &topBorderRect, &contentRect, dpi * 0.5, .maxY)
        
        var leftBorderRect = NSZeroRect
        var rightBorderRect = NSZeroRect
        NSDivideRect(contentRect, &leftBorderRect, &contentRect, dpi * 0.13, .minX)
        NSDivideRect(contentRect, &rightBorderRect, &contentRect, dpi * 0.13, .maxX)
        
        var bottomBorderRect = NSZeroRect
        NSDivideRect(contentRect, &bottomBorderRect, &contentRect, dpi * 0.13, .minY)
        
        var fullNameRect = NSZeroRect
        NSDivideRect(contentRect, &fullNameRect, &contentRect, dpi * 0.375, .minY)
        
        var holsterRect = NSZeroRect
        NSDivideRect(contentRect, &holsterRect, &contentRect, dpi * 0.375, .minY)
        
        var memberRect = NSZeroRect
        NSDivideRect(contentRect, &memberRect, &contentRect, dpi * 0.35, .minY)
        
        var nameRect = NSZeroRect
        NSDivideRect(contentRect, &nameRect, &contentRect, dpi * 0.6, .minY)
        
        var logoRect = NSZeroRect
        var photoRect = NSZeroRect
        NSDivideRect(contentRect, &logoRect, &photoRect, contentRect.size.width / 2.0, .maxX)
        
        logoRect = logoRect.insetBy(dx: 4.0, dy: 4.0)
        photoRect = photoRect.insetBy(dx: 8.0, dy: 8.0)

        if mob {
            if let member_id = membership.member_id , member_id == 1367 {
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
        NSBezierPath.fill(topBorderRect)
        yellowColor.setFill()
        NSBezierPath.fill(rightBorderRect)
        
        tealColor.setFill()
        NSBezierPath.fill(leftBorderRect)
        NSBezierPath.fill(memberRect)
        
        blueColor.setFill()
        NSBezierPath.fill(holsterRect)
        NSBezierPath.fill(bottomBorderRect)
        
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .center
        pStyle.lineBreakMode = .byClipping
        pStyle.allowsDefaultTighteningForTruncation = true
        
        leftBorderRect.size.height = bounds.size.height
        leftBorderRect.origin.y = 0.0
        "S\nV\nS\nC".drawVerticallyCenteredInRect(leftBorderRect, attributes: [NSFontAttributeName : svscFont!, NSForegroundColorAttributeName : NSColor.white,
            NSParagraphStyleAttributeName : pStyle])
        
        logo?.drawCenteredInRect(logoRect)
        
        NSColor.white.set()
        var needSponsor = false
        var drawPhoto = true
        if let member_id = membership.member_id , member_id > 0 {
            var headerFont = titleFont!
            var header = ""
            let prefix = membership.level.type.className()
            
            switch membership.level.type {
            case .Regular, .Life, .Disabled_Veteran, .SVPD, .Seaside, .Youth, .Senior:
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
            
            header.drawVerticallyCenteredInRect(topBorderRect, attributes: [NSFontAttributeName : headerFont, NSForegroundColorAttributeName : NSColor.white,
                NSParagraphStyleAttributeName : pStyle])

            "\(prefix!) / \(member_id)".drawVerticallyCenteredInRect(memberRect, attributes: [NSFontAttributeName : memberFont!, NSForegroundColorAttributeName : NSColor.white,
                NSParagraphStyleAttributeName : pStyle])
            
            if drawPhoto {
                if let path = Bundle.main.path(forResource: "\(member_id)", ofType: "jpg", inDirectory: "photos") {
                    if let photo = NSImage(byReferencingFile: path) {
                        photo.drawCenteredInRect(photoRect)
                    }
                }
            }
            else {
                if let od = membership.orientation_date, let ped = membership.prob_exp_date {
                    "Orientation:\n\(dateFormatter.string(from: od as Date))\n\nExpiration:\n\(dateFormatter.string(from: ped as Date))".drawVerticallyCenteredInRect(photoRect, attributes: [NSFontAttributeName : probyFont!, NSForegroundColorAttributeName : NSColor.black,
                        NSParagraphStyleAttributeName : pStyle])
                }
            }
        }
        if let holster = membership.holster {
            switch holster {
            case .Yes:
                "HOLSTER".drawVerticallyCenteredInRect(holsterRect, attributes: [NSFontAttributeName : holsterFont!, NSForegroundColorAttributeName : NSColor.white,
                    NSParagraphStyleAttributeName : pStyle])
                break
            default:
                break
            }
        }
        
        NSColor.black.set()
        var nameString = "\(member.contact.first_name.uppercased()) \(member.contact.last_name.uppercased())"
        if let sponsorName = member.sponsor?.name , needSponsor {
            nameString += "\nSponsor: \(sponsorName.uppercased())"
        }
        nameString.drawVerticallyCenteredInRect(fullNameRect, attributes: [NSFontAttributeName : sponsorNameFont!, NSForegroundColorAttributeName : NSColor.black,
            NSParagraphStyleAttributeName : pStyle])
        
        var nameFont = self.nameFont!
        var name = member.contact.first_name
        if let nickname = member.contact.preferred_name , nickname.characters.count > 1 {
            name = nickname
        }
        if name.characters.count > 8 {
            nameFont = NSFont(name: nameFont.fontName, size: 20.0)!
        }
        name.capitalized.drawVerticallyCenteredInRect(nameRect, attributes: [NSFontAttributeName : nameFont, NSForegroundColorAttributeName : NSColor.black,
            NSParagraphStyleAttributeName : pStyle])
        
    }
}


extension String {
    func drawVerticallyCenteredInRect(_ rect: NSRect, attributes: [String : AnyObject]?) {
        let string = NSString(string: self)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        
        let context = NSStringDrawingContext()
        context.minimumScaleFactor = 0.75
        
        let bounds = string.boundingRect(with: rect.size, options: options, attributes: attributes, context: context)
        
        if (context.actualScaleFactor < 1.0) {
            print("Scaled \(context.actualScaleFactor)")
        }
        
        let deltaY = (rect.size.height - bounds.size.height) / 2.0
        var drawRect = rect
        drawRect.origin.y -= deltaY
        
        string.draw(with: drawRect, options: options, attributes: attributes, context: context)
        
        if (context.actualScaleFactor < 1.0) {
            print("Scaled \(context.actualScaleFactor)")
        }
    }
}

extension NSImage {
    func drawCenteredInRect(_ rect: NSRect) {
        
        let size = self.size;
        let aspect = size.width/size.height
        
        let newHeight = rect.size.width / aspect
        let deltaY = (rect.size.height - newHeight) / 2.0
        
        let centeredRect = NSMakeRect(rect.origin.x, rect.origin.y + deltaY, rect.size.width, newHeight)
        draw(in: centeredRect)
    }
}
