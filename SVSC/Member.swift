//
//  Member.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/8/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation
import SQLite

class Member : NSObject {
    weak var db: Database?
    
    fileprivate var haveCached = [String: Bool]()
    fileprivate var cachedValue = [String: AnyObject]()
    
    let contact: Contact
    
    fileprivate var membership_set_ = false
    fileprivate var membership_: Membership? {
        didSet {
            membership_set_ = true
        }
    }
    var membership: Membership? {
        get {
            if membership_set_ {
                return membership_
            }
            guard let db = self.db else {
                return nil
            }
            guard let db_conn = db.db else {
                return nil
            }
            let members = db.members
            let levels = db.levels
            let query = members.table
                .join(levels.table, on: members.table[members.level] == levels.table[levels.id])
                .filter(members.contact_id == contact.id)
            
            if let row = try! db_conn.pluck(query) {
                let level = MembershipLevel(
                    id: row[levels.table[levels.id]],
                    type: MembershipType(rawValue: row[levels.type])!,
                    url: row[levels.url]
                )
                var mem_status: MembershipStatus? = nil
                if let ms = row[members.status] {
                    mem_status = MembershipStatus(rawValue: ms)
                }
                var gate_status: GateStatus? = nil
                if let gs = row[members.gate_status] {
                    gate_status = GateStatus(rawValue: gs)
                }
                var holster_rating: HolsterRating? = nil
                if let hr = row[members.holster] {
                    holster_rating = HolsterRating(rawValue: hr)
                }
                var dist_method: DistributionMethod? = nil
                if let dm = row[members.perm_id_dist_method] {
                    dist_method = DistributionMethod(rawValue: dm)
                }
                
                membership_ = Membership(
                    contact_id: contact.id,
                    member_id: row[members.member_id],
                    level: level,
                    status: mem_status,
                    change_date: row[members.change_date],
                    gate_card: row[members.gate_card],
                    gate_status: gate_status,
                    holster: holster_rating,
                    application_date: row[members.application_date],
                    membership_date: row[members.membership_date],
                    orientation_date: row[members.orientation_date],
                    perm_id_dist_date: row[members.perm_id_dist_date],
                    perm_id_dist_method: dist_method,
                    prob_id_dist_date: row[members.prob_id_dist_date],
                    meeting1: row[members.meeting1],
                    meeting2: row[members.meeting2],
                    meeting3: row[members.meeting3],
                    prob_exp_date: row[members.prob_exp_date]
                )
            }
            return membership_
        }
    }
    fileprivate var sponsor_set_ = false
    fileprivate var sponsor_: Sponsor? {
        didSet {
            sponsor_set_ = true
        }
    }
    var sponsor: Sponsor? {
        get {
            if sponsor_set_ {
                return sponsor_
            }
            guard let db = self.db else {
                return nil
            }
            guard let db_conn = db.db else {
                return nil
            }
            let sponsors = db.sponsors
            let query = sponsors.table.filter(sponsors.contact_id == contact.id)
            if let row = try! db_conn.pluck(query) {
                let contacts = db.contacts
                let members = db.members
                if let id = row[sponsors.id] {
                    let query = contacts.table
                        .join(members.table, on: contacts.table[contacts.id] == members.table[members.contact_id])
                        .select(contacts.preferred_name, contacts.first_name, contacts.last_name, contacts.email)
                        .filter(members.table[members.member_id] == id)
                        .limit(1)
                    if let r = try! db_conn.pluck(query) {
                        var first = r[contacts.first_name]
                        if let nick = r[contacts.preferred_name] {
                            first = nick
                        }
                        sponsor_ = Sponsor(
                            contact_id: contact.id,
                            id: id,
                            name: "\(first) \(r[contacts.last_name])",
                            email: r[contacts.email]
                        )
                    }
                }
                if let email = row[sponsors.email] {
                    let query = contacts.table.join(members.table, on: contacts.table[contacts.id] == members.table[members.contact_id]).select(contacts.preferred_name, contacts.first_name, contacts.last_name, members.member_id).filter(contacts.table[contacts.email].lowercaseString.like(email.lowercased())).limit(1)
                    if let r = try! db_conn.pluck(query) {
                        if let id = r[members.member_id] {
                            var first = r[contacts.first_name]
                            if let nick = r[contacts.preferred_name] {
                                first = nick
                            }
                            sponsor_ = Sponsor(
                                contact_id: contact.id,
                                id: id,
                                name: "\(first) \(r[contacts.last_name])",
                                email: email
                            )
                        }
                    }
                }
                if let name = row[sponsors.name] {
                    let components = name.uppercased().components(separatedBy: " ")
                    if let first = components.first, let last = components.last {
                        let query = contacts.table.join(members.table, on: contacts.table[contacts.id] == members.table[members.contact_id]).select(contacts.preferred_name, contacts.first_name, contacts.last_name, contacts.email, members.member_id).filter((contacts.table[contacts.first_name].uppercaseString.like(first) || contacts.table[contacts.preferred_name].uppercaseString.like(first)) && contacts.table[contacts.last_name].uppercaseString.like(last)).limit(1)
                        if let r = try! db_conn.pluck(query) {
                            if let id = r[members.member_id] {
                                var first = r[contacts.first_name]
                                if let nick = r[contacts.preferred_name] {
                                    first = nick
                                }
                                sponsor_ = Sponsor(
                                    contact_id: contact.id,
                                    id: id,
                                    name: "\(first) \(r[contacts.last_name])",
                                    email: r[contacts.email]
                                )
                            }
                        }
                    }
                }
            }
            return sponsor_
        }
    }
    fileprivate var nra_set_ = false
    fileprivate var nra_: NRAMembership? {
        didSet {
            nra_set_ = true
        }
    }
    var nra: NRAMembership? {
        get {
            if nra_set_ {
                return nra_
            }
            guard let db = self.db else {
                return nil
            }
            guard let db_conn = db.db else {
                return nil
            }
            let nra = db.nra
            let query = nra.table.filter(nra.contact_id == contact.id)
            if let row = try! db_conn.pluck(query) {
                nra_ = NRAMembership(contact_id: contact.id, id: row[nra.id], exp_date: row[nra.exp_date])
            }
            return nra_
        }
    }
    
    fileprivate var notes_set_ = false
    fileprivate var notes_: Note? {
        didSet {
            notes_set_ = true
        }
    }
    var notes: Note? {
        get {
            if notes_set_ {
                return notes_
            }
            guard let db = self.db else {
                return nil
            }
            guard let db_conn = db.db else {
                return nil
            }
            let notes = db.notes
            let query = notes.table.filter(notes.contact_id == contact.id)
            if let row = try! db_conn.pluck(query) {
                notes_ = Note(contact_id: contact.id, text: row[notes.text], date: nil)
            }
            return notes_
        }
    }
    fileprivate var groups_set_ = false
    fileprivate var groups_: [GroupParticipation]? {
        didSet {
            groups_set_ = true
        }
    }

    var groups: [GroupParticipation]? {
        get {
            if groups_set_ {
                return groups_
            }
            guard let db = self.db else {
                return nil
            }
            guard let db_conn = db.db else {
                return nil
            }
            
            let groups = db.groups
            let query = groups.table.filter(groups.contact_id == contact.id)
            if let group_rows = try? db_conn.prepare(query) {
                var newGroups = [GroupParticipation]()
                for row in group_rows {
                    newGroups.append(GroupParticipation(contact_id: contact.id, id: row[groups.id], name: row[groups.name]))
                }
                groups_ = newGroups
            }
            return groups_
        }
        set {
            guard let db = self.db else {
                return
            }
            guard let db_conn = db.db else {
                return
            }
            do {
                let groups = db.groups
                if let g = newValue {
                    var valid_group_ids = [Int]()
                    for group in g {
                        valid_group_ids.append(group.id)
                        try _ = groups.insert(db_conn, item: group)
                    }
                    
                    let delete = groups.table.filter(valid_group_ids.contains(groups.id)).delete()
                    try _ = db_conn.run(delete)
                }
            }
            catch _ {}
            
            groups_ = newValue
        }
    }
    
    
    static func ==(lhs: Member, rhs: Member) -> Bool {
        if let a = lhs.membership, let b = rhs.membership {
            guard a.level == b.level else {
                return false
            }
            if let a_id = a.member_id, let b_id = b.member_id, a_id == b_id {
                return true
            }
        }
        return lhs.contact.first_name.capitalized == rhs.contact.first_name.capitalized && lhs.contact.last_name.capitalized == rhs.contact.last_name.capitalized
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Member else {
            return false
        }
        return self == other
    }
    
    override func value(forUndefinedKey key: String) -> Any? {
        switch key {
        case "first_name":
            return contact.first_name.capitalized
        case "last_name":
            return contact.last_name.capitalized
        case "preferred_name":
            return contact.preferred_name?.capitalized
        case "email":
            return contact.email.lowercased()
        case "member_id":
            return membership?.member_id
        case "member_level":
            return membership?.level.type.shortName()
        case "gate_card":
            return membership?.gate_card
        case "gate_status":
            return membership?.gate_status?.rawValue
        default:
            return nil
        }
    }
    
    init(db: Database?, contact: Contact) {
        self.db = db
        self.contact = contact
        super.init()
    }
    
    func update(_ completion:@escaping ()->Void) {
        let mgr = WildApricotManager.sharedManager
        
        mgr.authenticate("secretary@scottsvalleysportsmen.com", password: "w1ll1amg1bs0n")
        mgr.downloadContact(self.contact.id) { (json: [String: AnyObject]?) in
            guard let entry = json else {
                return
            }
            self.db?.importMember(entry)
            completion()
        }
    }
}

