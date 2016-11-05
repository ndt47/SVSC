//
//  PrintMailingLabelsViewController.swift
//  SVSC
//
//  Created by Nathan Taylor on 5/1/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa

class MailingLabel : NSView {
    var member: Member? {
        didSet {
            updateTextStorateForMember(member)
        }
    }
    
    var textView = NSTextView(frame: NSZeroRect)
    
    init(_ member: Member?) {
        self.member = member
        super.init(frame: NSZeroRect)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textView)
        self.addConstraint(NSLayoutConstraint(item: textView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: textView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: textView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate let statemap = [
    "alabama" : "AL",
    "alaska" : "AK",
    "arizona" : "AZ",
    "arkansas" : "AR",
    "california" : "CA",
    "colorado" : "CO",
    "connecticut" : "CT",
    "deleware" : "DE",
    "florida" : "FL",
    "georgia" : "GA",
    "hawaii" : "HI",
    "idaho" : "ID",
    "illinois" : "IL",
    "indiana" : "IN",
    "iowa" : "IA",
    "kansas" : "KS",
    "kentucky" : "KY",
    "louisiana" : "LA",
    "maine" : "ME",
    "maryland" : "MD",
    "massachusetts" : "MA",
    "michigan" : "MI",
    "minnesota" : "MN",
    "mississippi" : "MS",
    "missouri" : "MO",
    "montana" : "MT",
    "nebraska" : "NE",
    "nevada" : "NV",
    "new hampshire" : "NH",
    "new jersey" : "NJ",
    "new mexico" : "NM",
    "new york" : "NY",
    "north carolina" : "NC",
    "north dakota" : "ND",
    "ohio" : "OH",
    "oklahoma" : "OK",
    "oregon" : "OR",
    "pennsylvania" : "PA",
    "rhode island" : "RI",
    "south carolina" : "SC",
    "south dakota" : "SD",
    "tennessee" : "TN",
    "texas" : "TX",
    "utah" : "UT",
    "vermont" : "VT",
    "virginia" : "VA",
    "washington" : "WA",
    "west virginia" : "WV",
    "wisconsin" : "WI",
    "wyoming" : "WY" ]
    
    fileprivate func stateAbbreviation(_ state: String) -> String {
        if let abb = statemap[state.lowercased()] {
            return abb
        }
        return state.uppercased()
    }
    
    fileprivate func updateTextStorateForMember(_ member: Member?) -> Void {
        guard let m = member else {
            return
        }
    
        if let storage = textView.textStorage {
            storage.deleteCharacters(in: NSMakeRange(0, storage.length))
            
            let nameAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : NSColor.black,
                                                        NSFontAttributeName : NSFont(name: "Helvetica-Bold", size: 16.0) ?? NSFont.systemFont(ofSize: 16.0)]
            
            let addressAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : NSColor.black,
                                                           NSFontAttributeName : NSFont(name: "Helvetica", size: 13.0) ?? NSFont.systemFont(ofSize: 13.0)]
            
            
            let name = "\(m.contact.first_name.capitalized) \(m.contact.last_name.capitalized)\n"
            
            storage.append(NSAttributedString(string: name, attributes: nameAttributes))
            
            if let a1 = m.contact.address1, let city = m.contact.city, let state = m.contact.state, let zip = m.contact.zip {
                var address = "\(a1.capitalized)\n"
                if let a2 = m.contact.address2 {
                    address += "\(a2.capitalized)\n"
                }
                address += "\(city.capitalized), \(stateAbbreviation(state)), \(zip)"
                
                storage.append(NSAttributedString(string: address, attributes: addressAttributes))
            }
        }
    }
    
}
