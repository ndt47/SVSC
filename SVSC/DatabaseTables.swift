//
//  DatabaseTables.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/8/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation
import SQLite

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
    let birth_date = Expression<Date?>("birth_date")
    let email = Expression<String>("email")
    let alt_email = Expression<String?>("alt_email")
    let home_phone = Expression<String?>("home_phone")
    let work_phone = Expression<String?>("work_phone")
    let mobile_phone = Expression<String?>("mobile_phone")
    let gender = Expression<String?>("gender")
    
    func create(_ db: Connection) throws -> Void {
        do {
            try _ = db.run( table.create { t -> Void in
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
                t.column(email, unique: true)
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
    func insert(_ db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(or: OnConflict.replace, id <- item.id, first_name <- item.first_name, middle_name <- item.middle_name, last_name <- item.last_name, preferred_name <- item.preferred_name, address1 <- item.address1, address2 <- item.address2, city <- item.city, state <- item.state, zip <- item.zip, birth_date <- item.birth_date, email <- item.email, alt_email <- item.alt_email, home_phone <- item.home_phone, work_phone <- item.work_phone, mobile_phone <- item.mobile_phone, gender <- item.gender?.rawValue)
        do {
            let row = try db.run( insert )
            guard row > 0 else {
                throw DataBaseError.insertError
            }
            return row
        } catch _ {}
        return 0
    }
    func delete(_ db: Connection, item: T) throws -> Void {
        
    }
    func findAll(_ db: Connection) throws -> [T]? {
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
    let date = Expression<Date?>("date")
    
    func create(_ db: Connection) throws -> Void {
        do {
            try _ = db.run( table.create { t -> Void in
                t.column(contact_id)
                t.column(text)
                t.column(date)
                })
        } catch _ {}
    }
    func insert(_ db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(or: OnConflict.replace, contact_id <- item.contact_id, text <- item.text, date <- item.date)
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.insertError
            }
            return row
        }
        catch _ {}
        return 0
    }
    func delete(_ db: Connection, item: T) throws -> Void {
        
    }
    func findAll(_ db: Connection) throws -> [T]? {
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
    
    func create(_ db: Connection) throws -> Void {
        do {
            try _ = db.run( table.create { t -> Void in
                t.column(contact_id, primaryKey: true)
                t.column(name)
                t.column(id)
                t.column(email)
                })
        } catch _ {}
    }
    func insert(_ db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(or: OnConflict.replace, contact_id <- item.contact_id, name <- item.name, id <- item.id, email <- item.email)
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.insertError
            }
            return row
        }
        catch _ {}
        return 0
    }
    func delete(_ db: Connection, item: T) throws -> Void {
        
    }
    func findAll(_ db: Connection) throws -> [T]? {
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
    let exp_date = Expression<Date?>("nra_membership_exp_date")
    
    func create(_ db: Connection) throws -> Void {
        do {
            try _ = db.run( table.create { t -> Void in
                t.column(contact_id)
                t.column(id)
                t.column(exp_date)
                })
        } catch _ {}
    }
    func insert(_ db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(or: OnConflict.replace, contact_id <- item.contact_id, id <- item.id, exp_date <- item.exp_date)
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.insertError
            }
            return row
        }
        catch _ {}
        return 0
    }
    func delete(_ db: Connection, item: T) throws -> Void {
        
    }
    func findAll(_ db: Connection) throws -> [T]? {
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
    let change_date = Expression<Date?>("change_date")
    
    let gate_card = Expression<Int?>("gate_card")
    let gate_status = Expression<String?>("gate_status")
    let gate_id = Expression<Int?>("gate_id")
    let holster = Expression<String?>("holster")
    
    let application_date = Expression<Date?>("application_date")
    let membership_date = Expression<Date?>("membership_date")
    let orientation_date = Expression<Date?>("orienation_date")
    
    let perm_id_dist_date = Expression<Date?>("perm_id_dist_date")
    let perm_id_dist_method = Expression<String?>("perm_id_dist_method")
    
    let prob_id_dist_date = Expression<Date?>("prob_id_dist_date")
    let meeting1 = Expression<Date?>("meeting1")
    let meeting2 = Expression<Date?>("meeting2")
    let meeting3 = Expression<Date?>("meeting3")
    let prob_exp_date = Expression<Date?>("prob_exp_date")
    
    func create(_ db: Connection) throws -> Void {
        do {
            try _ = db.run( table.create { t -> Void in
                t.column(contact_id, primaryKey: true)
                t.column(member_id)
                t.column(level)
                t.column(status)
                t.column(change_date)
                
                t.column(gate_card)
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
    func insert(_ db: Connection, item: T) throws -> Int64 {
        
        let insert = table.insert(or: OnConflict.replace,
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
                throw DataBaseError.insertError
            }
            return row
        }
        catch let e {
            print("MEMBERSHIP FAIL: \(e) \(self)")
        }
        return 0
    }
    func delete(_ db: Connection, item: T) throws -> Void {
        
    }
    func findAll(_ db: Connection) throws -> [T]? {
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
    
    func create(_ db: Connection) throws -> Void {
        do {
            try _ = db.run( table.create { t -> Void in
                t.column(id, primaryKey: true)
                t.column(type)
                t.column(url)
                })
        } catch _ {}
    }
    func insert(_ db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(or: OnConflict.replace, id <- item.id, type <- item.type.rawValue, url <- item.url)
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.insertError
            }
            return row
        }
        catch _ {}
        return 0
    }
    func delete(_ db: Connection, item: T) throws -> Void {
        
    }
    func findAll(_ db: Connection) throws -> [T]? {
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

class GroupsTable : DatabaseTable {
    typealias T = GroupParticipation
    
    static let TABLE_NAME = "groups"
    let table = Table(TABLE_NAME)
    
    let id = Expression<Int>("id")
    let contact_id = Expression<Int>("contact_id")
    let name = Expression<String>("name")
    
    func create(_ db: Connection) throws {
        do {
            try _ = db.run( table.create(block: { (t) -> Void in
                t.column(contact_id)
                t.column(id)
                t.column(name)
            }))
        } catch _ {}
    }
    
    func insert(_ db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(or: OnConflict.replace, contact_id <- item.contact_id, id <- item.id, name <- item.name)
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.insertError
            }
            return row
        } catch _ {}
        return 0
    }
    
    func delete(_ db: Connection, item: T) throws {
        
    }
    
    func findAll(_ db: Connection) throws -> [T]? {
        if let items = try? db.prepare(table) {
            var results = [T]()
            
            for item in items {
                let r = T(contact_id: item[contact_id], id: item[id], name: item[name])
                results.append(r)
            }
            return results
        }
        return nil
    }
}

class GateAccessTable : DatabaseTable {
    typealias T = GateAccess
    
    static let TABLE_NAME = "gate_access"
    let table = Table(TABLE_NAME)
    
    let id = Expression<Int>("id")
    let name = Expression<String?>("name")
    let gate = Expression<String>("gate")
    let side = Expression<Int>("side")
    let date = Expression<Date>("date")
    
    func create(_ db: Connection) throws {
        do {
            try _ = db.run( table.create(block: { (t) -> Void in
                t.column(id)
                t.column(name)
                t.column(gate)
                t.column(side)
                t.column(date)
            }))
        } catch _ {}
    }
    
    func insert(_ db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(or: OnConflict.replace, 
            id <- item.id,
            name <- item.name,
            gate <- item.gate.rawValue,
            side <- item.side.rawValue,
            date <- item.date
        )
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.insertError
            }
            return row
        } catch _ {}
        return 0
    }
    
    func delete(_ db: Connection, item: T) throws {
        
    }
    
    func findAll(_ db: Connection) throws -> [T]? {
        if let items = try? db.prepare(table) {
            var results = [T]()
            
            for item in items {
                let r = T(
                    id: item[id],
                    name: item[name],
                    gate: Gate(rawValue: item[gate])!,
                    side: GateSide(rawValue: item[side])!,
                    date: item[date])
                results.append(r)
            }
            return results
        }
        return nil
    }
}

class EventTable : DatabaseTable {
    typealias T = ClubEvent
    
    static let TABLE_NAME = "events"
    let table = Table(TABLE_NAME)
    
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let location = Expression<String>("location")
    let start_date = Expression<Date>("start")
    let end_date = Expression<Date>("end")
    let registration_enabled = Expression<Bool>("registration_enabled")
    let registration_limit = Expression<Int?>("registration_limit")
    let registration_count = Expression<Int?>("registration_count")
    let checked_in_count = Expression<Int>("checked_in_count")
    let url = Expression<String>("url")

    func create(_ db: Connection) throws {
        do {
            try _ = db.run( table.create(block: { (t) -> Void in
                t.column(id)
                t.column(name)
                t.column(location)
                t.column(start_date)
                t.column(end_date)
                t.column(registration_enabled)
                t.column(registration_limit)
                t.column(registration_count)
                t.column(checked_in_count)
                t.column(url)
            }))
        } catch _ {}
    }
    
    func insert(_ db: Connection, item: T) throws -> Int64 {
        if let registrations = item.registrations {
            let regTable = EventRegistrationTable()
            
            for registration in registrations {
                do {
                    try _ = regTable.insert(db, item: registration)
                }
                catch let e {
                    print("Failed to insert \(registration), error \(e)")
                    continue
                }
            }
        }
        
        let insert = table.insert(or: OnConflict.replace,
                                  id <- item.id,
                                  name <- item.name,
                                  location <- item.location,
                                  start_date <- item.start_date,
                                  end_date <- item.end_date,
                                  registration_enabled <- item.registration_enabled,
                                  registration_limit <- item.registration_limit,
                                  registration_count <- item.registration_count,
                                  checked_in_count <- item.checked_in_attendees_count,
                                  url <- item.url
        )
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.insertError
            }
            return row
        } catch _ {}
        return 0
    }
    
    func delete(_ db: Connection, item: T) throws {
        
    }
    
    func findAll(_ db: Connection) throws -> [T]? {
        if let items = try? db.prepare(table) {
            var results = [T]()
            
            for item in items {
                let r = T(
                    id: item[id],
                    name: item[name],
                    location: item[location],
                    start_date: item[start_date],
                    end_date: item[end_date],
                    registration_enabled: item[registration_enabled],
                    registration_limit: item[registration_limit],
                    registrations: [],
                    registration_count: item[registration_count],
                    checked_in_attendees_count: item[checked_in_count],
                    url: item[url])
                results.append(r)
            }
            return results
        }
        return nil
    }

}

class EventRegistrationTable : DatabaseTable {
    typealias T = ClubEventRegistration
    
    static let TABLE_NAME = "event_registrations"
    let table = Table(TABLE_NAME)
    
    let event_id = Expression<Int>("event_id")
    let type_id = Expression<Int?>("registartion_type_id")
    let contact_id = Expression<Int>("contact_id")
    let checked_in = Expression<Bool>("checked_in")
    let paid = Expression<Bool>("paid")
    let date = Expression<Date>("date")
    
    func create(_ db: Connection) throws {
        do {
            try _ = db.run( table.create(block: { (t) -> Void in
                t.column(event_id)
                t.column(type_id)
                t.column(contact_id)
                t.column(checked_in)
                t.column(paid)
                t.column(date)
            }))
        } catch _ {}
    }
    
    func insert(_ db: Connection, item: T) throws -> Int64 {
        let insert = table.insert(or: OnConflict.replace,
                                  event_id <- item.event_id,
                                  type_id <- item.registration_type_id,
                                  contact_id <- item.contact_id,
                                  checked_in <- item.checked_in,
                                  paid <- item.paid,
                                  date <- item.date
        )
        do {
            let row = try db.run(insert)
            guard row > 0 else {
                throw DataBaseError.insertError
            }
            return row
        } catch _ {}
        return 0
    }
    
    func delete(_ db: Connection, item: T) throws {
        
    }
    
    func findAll(_ db: Connection) throws -> [T]? {
        if let items = try? db.prepare(table) {
            var results = [T]()
            
            for item in items {
                let r = T(
                    event_id: item[event_id],
                    registration_type_id: item[type_id],
                    contact_id: item[contact_id],
                    checked_in: item[checked_in],
                    paid: item[paid],
                    date: item[date])
                results.append(r)
            }
            return results
        }
        return nil
    }
    
}
