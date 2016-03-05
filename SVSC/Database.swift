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
    case InsertError
    
}

protocol DatabaseTable {
    typealias T
    
    func create(db: Connection) throws -> Void
    func insert(db: Connection, item: T) throws -> Int64
    func delete(db: Connection, item: T) throws -> Void
    func findAll(db: Connection) throws -> [T]?
}

class ContactsTable : DatabaseTable {
    typealias T = Contact
    
    static let TABLE_NAME = "contacts"
    let table = Table(TABLE_NAME)
    let id = Expression<Int>("id")
    let first_name = Expression<String>("first_name")
    let middle_name = Expression<String?>("middle_name")
    let last_name = Expression<String>("last_name")
    let preferred_name = Expression<String?>("preferred_name")
    let address1 = Expression<String?>("address1")
    let address2 = Expression<String?>("address2")
    let city = Expression<String?>("city")
    let state = Expression<String?>("state")
    let zip = Expression<String?>("zip")
    let birth_date = Expression<NSDate?>("birth_date")
    let email = Expression<String>("email")
    let alt_email = Expression<String?>("alt_email")
    let home_phone = Expression<String?>("home_phone")
    let work_phone = Expression<String?>("work_phone")
    let mobile_phone = Expression<String?>("mobile_phone")
    let gender = Expression<String?>("gender")
    
    func create(db: Connection) throws -> Void {
        do {
            try db.run( table.create { t -> Void in
                t.column(id, primaryKey: true)
                t.column(first_name)
                t.column(middle_name)
                t.column(last_name)
                t.column(preferred_name)
                t.column(address1)
                t.column(address2)
                t.column(city)
                t.column(state)
                t.column(zip)
                t.column(birth_date)
                t.column(email)
                t.column(alt_email)
                t.column(home_phone)
                t.column(work_phone)
                t.column(mobile_phone)
                t.column(gender)
            })
        } catch let e {
            print("FAIL \(e)")
            throw e
        }
    }
    func insert(db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(id <- item.id, first_name <- item.first_name, middle_name <- item.middle_name, last_name <- item.last_name, preferred_name <- item.preferred_name, address1 <- item.address1, address2 <- item.address2, city <- item.city, state <- item.state, zip <- item.zip, birth_date <- item.birth_date, email <- item.email, alt_email <- item.alt_email, home_phone <- item.home_phone, work_phone <- item.work_phone, mobile_phone <- item.mobile_phone, gender <- item.gender?.rawValue)
        do {
            let row = try db.run( insert )
            guard row > 0 else {
                throw DataBaseError.InsertError
            }
            return row
        } catch _ {}
        return 0
    }
    func delete(db: Connection, item: T) throws -> Void {

    }
    func findAll(db: Connection) throws -> [T]? {
        if let items = try? db.prepare(table) {
            var results = [T]()

            for item in items {
                var gender: Gender? = nil
                if let ig = item[self.gender] {
                    gender = Gender(rawValue: ig)
                }
                let r = T(id: item[id], first_name: item[first_name], middle_name: item[middle_name], last_name: item[last_name], preferred_name: item[preferred_name], address1: item[address1], address2: item[address2], city: item[city], state: item[state], zip: item[zip], birth_date: item[birth_date], email: item[email], alt_email: item[alt_email], home_phone: item[home_phone], work_phone: item[work_phone], mobile_phone: item[mobile_phone], gender: gender )
                
                results.append(r)
            }
            return results
        }
        return nil
    }
}

class NotesTable : DatabaseTable {
    typealias T = Note
    
    static let TABLE_NAME = "notes"
    let table = Table(TABLE_NAME)

    let contact_id = Expression<Int>("contact_id")
    let text = Expression<String>("text")
    let date = Expression<NSDate?>("date")

    func create(db: Connection) throws -> Void {
        do {
            try db.run( table.create { t -> Void in
                t.column(contact_id)
                t.column(text)
                t.column(date)
                })
        } catch _ {}
    }
    func insert(db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(contact_id <- item.contact_id, text <- item.text, date <- item.date)
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.InsertError
            }
            return row
        }
        catch _ {}
        return 0
    }
    func delete(db: Connection, item: T) throws -> Void {
        
    }
    func findAll(db: Connection) throws -> [T]? {
        if let items = try? db.prepare(table) {
            var results = [T]()
            
            for item in items {
                let r = T(contact_id: item[contact_id], text: item[text], date: item[date])
                results.append(r)
            }
            return results
        }
        return nil
    }
}

class SponsorTable : DatabaseTable {
    typealias T = Sponsor

    static let TABLE_NAME = "sponsors"
    let table = Table(TABLE_NAME)

    let contact_id = Expression<Int>("contact_id")
    let name = Expression<String?>("sponsor_name")
    let id = Expression<Int?>("sponsor_id")
    let email = Expression<String?>("sponsor_email")

    func create(db: Connection) throws -> Void {
        do {
            try db.run( table.create { t -> Void in
                t.column(contact_id, primaryKey: true)
                t.column(name)
                t.column(id)
                t.column(email)
                })
        } catch _ {}
    }
    func insert(db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(contact_id <- item.contact_id, name <- item.name, id <- item.id, email <- item.email)
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.InsertError
            }
            return row
        }
        catch _ {}
        return 0
    }
    func delete(db: Connection, item: T) throws -> Void {
        
    }
    func findAll(db: Connection) throws -> [T]? {
        if let items = try? db.prepare(table) {
            var results = [T]()
            
            for item in items {
                let r = T(contact_id: item[contact_id], name: item[name], id: item[id], email: item[email])
                results.append(r)
            }
            return results
        }
        return nil
    }
}

class NRAMembershipTable : DatabaseTable {
    typealias T = NRAMembership
    
    static let TABLE_NAME = "nra"
    let table = Table(TABLE_NAME)

    let contact_id = Expression<Int>("contact_id")
    let id = Expression<String>("nra_membership_id")
    let exp_date = Expression<NSDate?>("nra_membership_exp_date")
    
    func create(db: Connection) throws -> Void {
        do {
            try db.run( table.create { t -> Void in
                t.column(contact_id)
                t.column(id)
                t.column(exp_date)
                })
        } catch _ {}
    }
    func insert(db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(contact_id <- item.contact_id, id <- item.id, exp_date <- item.exp_date)
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.InsertError
            }
            return row
        }
        catch _ {}
        return 0
    }
    func delete(db: Connection, item: T) throws -> Void {
        
    }
    func findAll(db: Connection) throws -> [T]? {
        if let items = try? db.prepare(table) {
            var results = [T]()
            
            for item in items {
                let r = T(contact_id: item[contact_id], id: item[id], exp_date: item[exp_date])
                results.append(r)
            }
            return results
        }
        return nil
    }
}

class MembershipTable : DatabaseTable {
    typealias T = Membership
    
    static let TABLE_NAME = "membership"
    let table = Table(TABLE_NAME)

    let contact_id = Expression<Int>("contact_id")
    let member_id = Expression<Int?>("member_id")
    let level = Expression<Int>("level")
    let status = Expression<String?>("status")
    let change_date = Expression<NSDate?>("change_date")
    
    let gate_card = Expression<String?>("gate_card")
    let gate_status = Expression<String?>("gate_status")
    let holster = Expression<String?>("holster")
    
    let application_date = Expression<NSDate?>("application_date")
    let membership_date = Expression<NSDate?>("membership_date")
    let orientation_date = Expression<NSDate?>("orienation_date")
    
    let perm_id_dist_date = Expression<NSDate?>("perm_id_dist_date")
    let perm_id_dist_method = Expression<String?>("perm_id_dist_method")

    let prob_id_dist_date = Expression<NSDate?>("prob_id_dist_date")
    let meeting1 = Expression<NSDate?>("meeting1")
    let meeting2 = Expression<NSDate?>("meeting2")
    let meeting3 = Expression<NSDate?>("meeting3")
    let prob_exp_date = Expression<NSDate?>("prob_exp_date")
    
    func create(db: Connection) throws -> Void {
        do {
            try db.run( table.create { t -> Void in
                t.column(contact_id, primaryKey: true)
                t.column(member_id)
                t.column(level)
                t.column(status)
                t.column(change_date)
                
                t.column(gate_card, unique: true)
                t.column(gate_status)
                t.column(holster)
                
                t.column(application_date)
                t.column(membership_date)
                t.column(orientation_date)
                
                t.column(perm_id_dist_date)
                t.column(perm_id_dist_method)
                
                t.column(prob_id_dist_date)
                t.column(meeting1)
                t.column(meeting2)
                t.column(meeting3)
                t.column(prob_exp_date)
                })
        } catch _ {}
    }
    func insert(db: Connection, item: T) throws -> Int64 {
        
        let insert = table.insert(
            contact_id <- item.contact_id,
            member_id <- item.member_id,
            level <- item.level.id,
            status <- item.status?.rawValue,
            change_date <- item.change_date,
            gate_card <- item.gate_card,
            gate_status <- item.gate_status?.rawValue,
            holster <- item.holster?.rawValue,
            application_date <- item.application_date,
            membership_date <- item.membership_date,
            orientation_date <- item.orientation_date,
            perm_id_dist_date <- item.perm_id_dist_date,
            perm_id_dist_method <- item.perm_id_dist_method?.rawValue,
            prob_id_dist_date <- item.prob_id_dist_date,
            meeting1 <- item.meeting1,
            meeting2 <- item.meeting2,
            meeting3 <- item.meeting3,
            prob_exp_date <- item.prob_exp_date)
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.InsertError
            }
            return row
        }
        catch _ {}
        return 0
    }
    func delete(db: Connection, item: T) throws -> Void {
        
    }
    func findAll(db: Connection) throws -> [T]? {
        let levels = LevelsTable()
        
        let query = table.join(levels.table, on: levels.table[levels.id] == table[level])
        if let items = try? db.prepare(query) {
            var results = [T]()
            
            for item in items {
                var member_status: MembershipStatus? = nil
                if let s = item[status] {
                    member_status = MembershipStatus(rawValue: s)
                }
                var dist_method: DistributionMethod? = nil
                if let m = item[perm_id_dist_method] {
                    dist_method = DistributionMethod(rawValue: m)
                }
                var holster: HolsterRating? = nil
                if let h = item[self.holster] {
                    holster = HolsterRating(rawValue: h)
                }
                var gate_status: GateStatus? = nil
                if let gs = item[self.gate_status] {
                    gate_status = GateStatus(rawValue: gs)
                }
                
                let r = T(contact_id: item[contact_id], member_id: item[member_id], level: MembershipLevel(id: item[levels.id], type: MembershipType(rawValue: item[levels.type])!, url: item[levels.url]), status: member_status, change_date: item[change_date], gate_card: item[gate_card], gate_status: gate_status, holster: holster, application_date: item[application_date], membership_date: item[membership_date], orientation_date: item[orientation_date], perm_id_dist_date: item[perm_id_dist_date], perm_id_dist_method: dist_method, prob_id_dist_date: item[prob_id_dist_date], meeting1: item[meeting1], meeting2: item[meeting2], meeting3: item[meeting3], prob_exp_date: item[prob_exp_date])
                results.append(r)
            }
            return results
        }
        return nil
    }
}

class LevelsTable : DatabaseTable {
    typealias T = MembershipLevel

    static let TABLE_NAME = "levels"
    let table = Table(TABLE_NAME)
    
    let id = Expression<Int>("id")
    let type = Expression<String>("type")
    let url = Expression<String>("url")

    func create(db: Connection) throws -> Void {
        do {
            try db.run( table.create { t -> Void in
                t.column(id, primaryKey: true)
                t.column(type)
                t.column(url)
                })
        } catch _ {}
    }
    func insert(db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(id <- item.id, type <- item.type.rawValue, url <- item.url)
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.InsertError
            }
            return row
        }
        catch _ {}
        return 0
    }
    func delete(db: Connection, item: T) throws -> Void {
        
    }
    func findAll(db: Connection) throws -> [T]? {
        if let items = try? db.prepare(table) {
            var results = [T]()
            
            for item in items {
                let r = T(id: item[id], type: MembershipType(rawValue: item[type])!, url: item[url])
                results.append(r)
            }
            return results
        }
        return nil
    }
}

class Database {
    
    let db: Connection?
    let contacts: ContactsTable
    let levels: LevelsTable
    let members: MembershipTable
    let nra: NRAMembershipTable
    let notes: NotesTable
    let sponsors: SponsorTable
    
    init(path: String) throws {
        db = try? Connection("members.db")
        
        contacts = ContactsTable()
        levels = LevelsTable()
        members = MembershipTable()
        nra = NRAMembershipTable()
        notes = NotesTable()
        sponsors = SponsorTable()

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
            try contacts.create(db)
            try levels.create(db)
            try members.create(db)
            try nra.create(db)
            try notes.create(db)
            try sponsors.create(db)
        }
        catch _ {}
    }

    private func sponsorForRow(row: SQLite.Row) -> Sponsor? {
        let contact_id = row[sponsors.table[sponsors.contact_id]]
        
        guard let db = self.db else {
            return nil
        }

        if let id = row[sponsors.table[sponsors.id]] {
            let query = contacts.table.join(members.table, on: contacts.table[contacts.id] == members.table[members.contact_id]).select(contacts.first_name, contacts.last_name, contacts.email).filter(members.table[members.member_id] == id).limit(1)
            if let r = db.pluck(query) {
                return Sponsor(
                    contact_id: contact_id,
                    id: id,
                    name: "\(r[contacts.first_name]) \(r[contacts.last_name])",
                    email: r[contacts.email]
                )
            }
        }
        if let email = row[sponsors.table[sponsors.email]] {
            let query = contacts.table.join(members.table, on: contacts.table[contacts.id] == members.table[members.contact_id]).select(contacts.first_name, contacts.last_name, members.member_id).filter(contacts.table[contacts.email].lowercaseString.like(email.lowercaseString)).limit(1)
            if let r = db.pluck(query) {
                if let id = r[members.member_id] {
                    return Sponsor(
                        contact_id: contact_id,
                        id: id,
                        name: "\(r[contacts.first_name]) \(r[contacts.last_name])",
                        email: email
                    )
                }
            }
        }
        if let name = row[sponsors.table[sponsors.name]] {
            let components = name.uppercaseString.componentsSeparatedByString(" ")
            if let first = components.first, let last = components.last {
                let query = contacts.table.join(members.table, on: contacts.table[contacts.id] == members.table[members.contact_id]).select(contacts.first_name, contacts.last_name, contacts.email, members.member_id).filter((contacts.table[contacts.first_name].uppercaseString.like(first) || contacts.table[contacts.preferred_name].uppercaseString.like(first)) && contacts.table[contacts.last_name].uppercaseString.like(last)).limit(1)
                if let r = db.pluck(query) {
                    if let id = r[members.member_id] {
                        return Sponsor(
                            contact_id: contact_id,
                            id: id,
                            name: "\(r[contacts.first_name]) \(r[contacts.last_name])",
                            email: r[contacts.email]
                        )
                    }
                }
            }
        }
        return nil
    }
    
    private func membershipForRow(row: SQLite.Row) -> Membership? {
        guard row[members.level] > 0 else {
            return nil
        }
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
        
        return Membership(
            contact_id: row[members.table[members.contact_id]],
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
    
    private func nraMembershipForRow(row: SQLite.Row) -> NRAMembership? {
        let contact_id = row[nra.table[nra.contact_id]]
        guard contact_id > 0 else {
            return nil
        }
        let nra_id = row[nra.table[nra.id]]
        guard nra_id.characters.count > 0 else {
            return nil
        }
        return NRAMembership(
            contact_id: contact_id,
            id: nra_id,
            exp_date: row[nra.exp_date]
        )
    }
    
    private func notesForRow(row: SQLite.Row) -> Note? {
        let contact_id = row[notes.table[notes.contact_id]]
        guard contact_id > 0 else {
            return nil
        }
        let text = row[notes.text]
        guard text.characters.count > 0 else {
            return nil
        }
        
        return Note(
            contact_id: contact_id,
            text: text,
            date: nil
        )
    }

    func allMembers() -> [Member] {
        
        let query = contacts.table.join(members.table, on: contacts.table[contacts.id] == members.table[members.contact_id]).join(levels.table, on: members.table[members.level] == levels.table[levels.id]).join(nra.table, on: nra.table[nra.contact_id] == contacts.table[contacts.id]).join(sponsors.table, on: sponsors.table[sponsors.contact_id] == contacts.table[contacts.id]).join(notes.table, on: notes.table[notes.contact_id] == contacts.table[contacts.id]).select(contacts.table[*], members.table[*], levels.table[*], nra.table[*], sponsors.table[*], notes.table[*]).order(contacts.table[contacts.first_name]).order(contacts.table[contacts.last_name])
        
        guard let db = self.db else {
            return []
        }

        if let rows = try? db.prepare(query) {
            var results = [Member]()
            for row in rows {
                var gender: Gender? = nil
                if let g = row[contacts.gender] {
                    gender = Gender(rawValue: g)
                }
                let contact = Contact(
                    id: row[contacts.table[contacts.id]],
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
                
                let member = Member(
                    contact: contact,
                    membership: membershipForRow(row),
                    sponsor: sponsorForRow(row),
                    nra: nraMembershipForRow(row),
                    notes: notesForRow(row)
                )
                results.append(member)
            }
            return results
        }
        
        return []
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
            
            var member = Member(
                contact: contact,
                membership: nil,
                sponsor: nil,
                nra: nil,
                notes: nil
            )

            if let sponsor_name = fieldDict["Sponsor Name"] as? String, let sponsor_id = Int.fromAnyObject(fieldDict["Sponsor ID #"]) {
                member.sponsor = Sponsor(
                    contact_id: contact.id,
                    name: sponsor_name,
                    id: sponsor_id,
                    email: fieldDict["Sponsor Email"] as? String)
            }
            else if let sponsor_name = fieldDict["Sponsor Name"] as? String {
                member.sponsor = Sponsor(
                    contact_id: contact.id,
                    name: sponsor_name,
                    id: nil,
                    email: fieldDict["Sponsor Email"] as? String)
            }
            else if let sponsor_id = Int.fromAnyObject(fieldDict["Sponsor ID #"]) {
                member.sponsor = Sponsor(
                    contact_id: contact.id,
                    name: nil,
                    id: sponsor_id,
                    email: fieldDict["Sponsor Email"] as? String)
            }
            else if let sponsor_email = fieldDict["Sponsor Email"] as? String {
                member.sponsor = Sponsor(
                    contact_id: contact.id,
                    name: nil,
                    id: nil,
                    email: sponsor_email)
            }
            
            if let nramem = fieldDict["NRA Membership #"] as? String {
                member.nra = NRAMembership(
                    contact_id: contact.id,
                    id: nramem,
                    exp_date: NSDate.fromAnyObject(fieldDict["NRA Expiration Date"])
                )
            }
            if let text = fieldDict["Notes"] as? String {
                member.notes = Note(
                    contact_id: contact.id,
                    text: text,
                    date: nil
                )
            }
            
            if let level = membershipLevel {
                var gateStatus: GateStatus? = nil
                if let valDict = fieldDict["Card Key Status"] as? [String: AnyObject] {
                    if let label = valDict["Label"] as? String {
                        gateStatus = GateStatus(rawValue: label)
                    }
                }
                var holsterRating: HolsterRating? = nil
                if let valDict = fieldDict["Holster Rating"] as? [String: AnyObject] {
                    if let label = valDict["Label"] as? String {
                        holsterRating = HolsterRating(rawValue: label)
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

                member.membership = Membership(
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

            
            
            do {
                try contacts.insert(db, item: member.contact)
                if let membership = member.membership {
                    try members.insert(db, item: membership)
                }
                if let sponsor = member.sponsor {
                    try sponsors.insert(db, item: sponsor)
                }
                if let nramem = member.nra {
                    try nra.insert(db, item: nramem)
                }
                if let n = member.notes {
                    try notes.insert(db, item: n)
                }
            } catch _ {}
        }
        
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