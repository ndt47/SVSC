//
//  DatabaseJSON.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/9/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import SQLite

extension Database {
    func importMembers(contacts entries: [[String: AnyObject]]) -> Void {
        for entry in entries {
            importMember(entry)
        }
    }
    
    func importMember(_ entry: [String: AnyObject]) {
        guard let db = self.db else {
            return
        }
        var membershipLevel: MembershipLevel?
        if let levelDict = entry["MembershipLevel"] as? [String: AnyObject] {
            var type: MembershipType? = nil
            if let name = levelDict["Name"] as? String {
                type = MembershipType(rawValue: name)
            }
            membershipLevel = MembershipLevel(
                id: Int.fromAnyObject(levelDict["Id"])!,
                type: type!,
                url: levelDict["Url"] as! String
            )
            
            do {
                try _ = levels.insert(db, item: membershipLevel!)
            }
            catch let e {
                print("Failed to insert level \(membershipLevel) \(e)")
            }
        }
        
        var fieldDict = [String: AnyObject]()
        for field: [String: AnyObject] in entry["FieldValues"] as! [[String: AnyObject]] {
            let key = field["FieldName"] as! String
            
            if let value = field["Value"] {
                fieldDict[key] = value
            }
        }
        
        var gender: Gender? = nil
        if let valDict = fieldDict["Gender"] as? [String: AnyObject] {
            if let label = valDict["label"] as? String {
                gender = Gender(rawValue: label)
            }
        }
        
        guard let test = fieldDict["Last name"] as? String else {
            return
        }
        guard test.characters.count > 0 else {
            return
        }
        
        let contact = Contact(
            id: fieldDict["User ID"]! as! Int,
            first_name: fieldDict["First name"]! as! String,
            middle_name: fieldDict["Middle Name"] as? String,
            last_name: fieldDict["Last name"]! as! String,
            preferred_name: fieldDict["Preferred or Nickname"] as? String,
            address1: fieldDict["Address Line 1"] as? String,
            address2: fieldDict["Address Line 2"] as? String,
            city: fieldDict["City"] as? String,
            state: fieldDict["State"] as? String,
            zip: fieldDict["Zip Code"] as? String,
            birth_date: Date.fromAnyObject(fieldDict["Date of Birth"]),
            email: fieldDict["E-Mail - Primary"]! as! String,
            alt_email: fieldDict["E-Mail - Alternate"] as? String,
            home_phone: fieldDict["Phone - Home"] as? String,
            work_phone: fieldDict["Phone - Work"] as? String,
            mobile_phone: fieldDict["Phone - Mobile"] as? String,
            gender: gender)
        
        let event_registrant = fieldDict["Event registrant"]
        if let er = event_registrant as? Int , er > 0 {
            // Should load the registrations for this user
        }
        
        var member_sponsor: Sponsor? = nil
        if let sponsor_name = fieldDict["Sponsor Name"] as? String, let sponsor_id = Int.fromAnyObject(fieldDict["Sponsor ID #"]) {
            member_sponsor = Sponsor(
                contact_id: contact.id,
                name: sponsor_name,
                id: sponsor_id,
                email: fieldDict["Sponsor Email"] as? String)
        }
        else if let sponsor_name = fieldDict["Sponsor Name"] as? String {
            member_sponsor = Sponsor(
                contact_id: contact.id,
                name: sponsor_name,
                id: nil,
                email: fieldDict["Sponsor Email"] as? String)
        }
        else if let sponsor_id = Int.fromAnyObject(fieldDict["Sponsor ID #"]) {
            member_sponsor = Sponsor(
                contact_id: contact.id,
                name: nil,
                id: sponsor_id,
                email: fieldDict["Sponsor Email"] as? String)
        }
        else if let sponsor_email = fieldDict["Sponsor Email"] as? String {
            member_sponsor = Sponsor(
                contact_id: contact.id,
                name: nil,
                id: nil,
                email: sponsor_email)
        }
        
        var member_nra: NRAMembership? = nil
        if let nramem = fieldDict["NRA Membership #"] as? String {
            member_nra = NRAMembership(
                contact_id: contact.id,
                id: nramem,
                exp_date: Date.fromAnyObject(fieldDict["NRA Expiration Date"])
            )
        }
        
        var member_note: Note? = nil
        if let text = fieldDict["Notes"] as? String {
            member_note = Note(
                contact_id: contact.id,
                text: text,
                date: nil
            )
        }
        
        var member_membership: Membership? = nil
        if let level = membershipLevel {
            var gateStatus: GateStatus? = nil
            if let valDict = fieldDict["Card Key Status"] as? [String: AnyObject] {
                if let label = valDict["Label"] as? String {
                    gateStatus = GateStatus(rawValue: label)
                }
            }
            var holsterRating: HolsterRating? = nil
            if let val = fieldDict["Holster Rating"] as? [[String: AnyObject]] {
                for entry in val {
                    if let label = entry["Label"] as? String {
                        holsterRating = HolsterRating(rawValue: label)
                        break
                    }
                }
            }
            var distMethod: DistributionMethod? = nil
            if let valDict = fieldDict["Perm ID Card Distributed"] as? [String: AnyObject] {
                if let label = valDict["L.qui.qabel"] as? String {
                    distMethod = DistributionMethod(rawValue: label)
                }
            }
            var memStatus: MembershipStatus? = nil
            if let valDict = fieldDict["Membership status"] as? [String: AnyObject] {
                if let label = valDict["Value"] as? String {
                    memStatus = MembershipStatus(rawValue: label)
                }
            }
            
            var gateCard: Int? = nil
            if let cardString = fieldDict["Card Key Number"] as? String {
                gateCard = Int(cardString, radix: 10)
                if gateCard == nil || gateCard == 0 {
                    print("FAILED TO INTERPRET CARD STRING \(cardString)")
                }
            }
            
            member_membership = Membership(
                contact_id: contact.id,
                member_id: Int.fromAnyObject(fieldDict["Member ID #"]),
                level: level,
                status: memStatus,
                change_date: Date.fromAnyObject(fieldDict["Level last changed"]),
                
                gate_card: gateCard,
                gate_status: gateStatus,
                holster: holsterRating,
                
                application_date: Date.fromAnyObject(fieldDict["Application Date"]),
                membership_date: Date.fromAnyObject(fieldDict["Application Date"]),
                orientation_date: Date.fromAnyObject(fieldDict["Orientation Date"]),
                
                perm_id_dist_date: Date.fromAnyObject(fieldDict["Application Date"]),
                perm_id_dist_method: distMethod,
                
                prob_id_dist_date: Date.fromAnyObject(fieldDict["Date Prob ID Card Distributed"]),
                meeting1: Date.fromAnyObject(fieldDict["Meeting 1"]),
                meeting2: Date.fromAnyObject(fieldDict["Meeting 2"]),
                meeting3: Date.fromAnyObject(fieldDict["Meeting 3"]),
                prob_exp_date: Date.fromAnyObject(fieldDict["Probation Expiry Date"])
            )
        }
        
        var member_groups = [GroupParticipation]()
        if let groups = fieldDict["Group participation"] as? [AnyObject] {
            for groupArr in (groups as! [[String : AnyObject]]) {
                let newGroup = GroupParticipation(
                    contact_id: contact.id,
                    id: groupArr["Id"] as! Int,
                    name: groupArr["Label"] as! String
                )
                member_groups.append(newGroup)
            }
        }
        
        
        do {
            try _ = contacts.insert(db, item: contact)
            
            if let membership = member_membership {
                try _ = members.insert(db, item: membership)
            }
            if let sponsor = member_sponsor {
                try _ = sponsors.insert(db, item: sponsor)
            }
            if let nramem = member_nra {
                try _ = nra.insert(db, item: nramem)
            }
            if let note = member_note {
                try _ = notes.insert(db, item: note)
            }
            for group in member_groups {
                try _ = groups.insert(db, item: group)
            }
        } catch _ {}
    }
}
