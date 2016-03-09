//
//  Database.swift
//  SVSCBadgePrinter
//
//  Created by Nathan Taylor on 2/21/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation
import SQLite

enum DataBaseError : ErrorType {
    case NotOpen
    case InvalidVersion
    case InsertError
    
}

protocol DatabaseTable {
    typealias T
    
    func create(db: Connection) throws -> Void
    func insert(db: Connection, item: T) throws -> Int64
    func delete(db: Connection, item: T) throws -> Void
    func findAll(db: Connection) throws -> [T]?
}


class Database {
    
    let db: Connection?
    let contacts = ContactsTable()
    let levels = LevelsTable()
    let members = MembershipTable()
    let nra = NRAMembershipTable()
    let notes = NotesTable()
    let sponsors = SponsorTable()
    let groups =  GroupsTable()
    let gate_access = GateAccessTable()
    
    init(path: String) throws {
        db = try? Connection("members.db")
        db?.trace { print($0) }
        
        do {
            try self.updateSchema()
        }
        catch _ {}
    }
    
    func updateSchema() throws -> Void {
        guard let db = self.db else {
            throw DataBaseError.NotOpen
        }
        do {
            switch db.userVersion {
            case 0:
                try contacts.create(db)
                try levels.create(db)
                try members.create(db)
                try nra.create(db)
                try notes.create(db)
                try sponsors.create(db)
                try groups.create(db)
                
                db.userVersion = 1
                fallthrough
            case 1:
                try db.run(members.table.addColumn(members.gate_id, defaultValue: nil))
                try db.run(members.table.createIndex(members.level))
                try db.run(members.table.createIndex(members.gate_card))
                try db.run(members.table.createIndex(members.gate_id))
                try gate_access.create(db)
                
                db.userVersion = 2
                break
            default:
                throw DataBaseError.InvalidVersion
            }
            
        }
        catch _ {}
    }

    func membersForQuery(query: QueryType) -> [Member] {
        guard let db = self.db else {
            return []
        }
        
        var results: AnySequence<Row>? = nil
        do {
            results = try db.prepare(query)
        }
        catch let e {
            print("\(e)")
        }
        
        if let rows = results {
            var results = [Member]()
            for row in rows {
                var gender: Gender? = nil
                if let g = row[contacts.gender] {
                    gender = Gender(rawValue: g)
                }
                let contact = Contact(
                    id: row[contacts.id],
                    first_name: row[contacts.first_name],
                    middle_name: row[contacts.middle_name],
                    last_name: row[contacts.last_name],
                    preferred_name: row[contacts.preferred_name],
                    address1: row[contacts.address1],
                    address2: row[contacts.address2],
                    city: row[contacts.city],
                    state: row[contacts.state],
                    zip: row[contacts.zip],
                    birth_date: row[contacts.birth_date],
                    email: row[contacts.email],
                    alt_email: row[contacts.alt_email],
                    home_phone: row[contacts.home_phone],
                    work_phone: row[contacts.work_phone],
                    mobile_phone: row[contacts.mobile_phone],
                    gender: gender
                )
                
                results.append(Member(db: self, contact: contact))
            }
            return results
        }
        
        return []
    }
    
    func allMembers() -> [Member] {
        let query = contacts.table
            .join(members.table, on: contacts.table[contacts.id] == members.table[members.contact_id])
            .order(contacts.last_name.asc, contacts.first_name.asc)
        
        return self.membersForQuery(query)
    }

    func importMembers(fromResponseDict dict: [String: AnyObject]) -> Void {
        guard let db = self.db else {
            return
        }
        guard let entries = dict["Contacts"] as? [[String: AnyObject]] else {
            return
        }
    
        for entry in entries {
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
                    try levels.insert(db, item: membershipLevel!)
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
                continue
            }
            guard test.characters.count > 0 else {
                continue
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
                birth_date: NSDate.fromAnyObject(fieldDict["Date of Birth"]),
                email: fieldDict["E-Mail - Primary"]! as! String,
                alt_email: fieldDict["E-Mail - Alternate"] as? String,
                home_phone: fieldDict["Phone - Home"] as? String,
                work_phone: fieldDict["Phone - Work"] as? String,
                mobile_phone: fieldDict["Phone - Mobile"] as? String,
                gender: gender)
            
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
                    exp_date: NSDate.fromAnyObject(fieldDict["NRA Expiration Date"])
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

                member_membership = Membership(
                    contact_id: contact.id,
                    member_id: Int.fromAnyObject(fieldDict["Member ID #"]),
                    level: level,
                    status: memStatus,
                    change_date: NSDate.fromAnyObject(fieldDict["Level last changed"]),
                    
                    gate_card: fieldDict["Card Key Number"] as? String,
                    gate_status: gateStatus,
                    holster: holsterRating,
                    
                    application_date: NSDate.fromAnyObject(fieldDict["Application Date"]),
                    membership_date: NSDate.fromAnyObject(fieldDict["Application Date"]),
                    orientation_date: NSDate.fromAnyObject(fieldDict["Orientation Date"]),
                    
                    perm_id_dist_date: NSDate.fromAnyObject(fieldDict["Application Date"]),
                    perm_id_dist_method: distMethod,
                    
                    prob_id_dist_date: NSDate.fromAnyObject(fieldDict["Date Prob ID Card Distributed"]),
                    meeting1: NSDate.fromAnyObject(fieldDict["Meeting 1"]),
                    meeting2: NSDate.fromAnyObject(fieldDict["Meeting 2"]),
                    meeting3: NSDate.fromAnyObject(fieldDict["Meeting 3"]),
                    prob_exp_date: NSDate.fromAnyObject(fieldDict["Probation Expiry Date"])
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
                try contacts.insert(db, item: contact)
                
                if let membership = member_membership {
                    try members.insert(db, item: membership)
                }
                if let sponsor = member_sponsor {
                    try sponsors.insert(db, item: sponsor)
                }
                if let nramem = member_nra {
                    try nra.insert(db, item: nramem)
                }
                if let note = member_note {
                    try notes.insert(db, item: note)
                }
                for group in member_groups {
                    try groups.insert(db, item: group)
                }
            } catch _ {}
        }
        
    }
}

extension Connection {
    public var userVersion: Int {
        get { return Int(scalar("PRAGMA user_version") as! Int64) }
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}


extension NSDate {
    static func fromAnyObject(anyObject: AnyObject?) -> NSDate? {
        if let d = anyObject as? Double {
            return NSDate(timeIntervalSince1970: d)
        }
        else if let s = anyObject as? String {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            return formatter.dateFromString(s)
        }
        return nil
    }
}

extension Int {
    static func fromAnyObject(anyObject: AnyObject?) -> Int? {
        if let obj = anyObject {
            if let i = obj as? Int {
                return i
            }
            else if let s = obj as? String {
                return Int(s)
            }
        }
        return nil
    }
}
