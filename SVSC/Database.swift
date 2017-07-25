//
//  Database.swift
//  SVSCBadgePrinter
//
//  Created by Nathan Taylor on 2/21/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation
import SQLite

enum DataBaseError : Error {
    case notOpen
    case invalidVersion
    case insertError
    
}

protocol DatabaseTable {
    associatedtype T
    
    func create(_ db: Connection) throws -> Void
    func insert(_ db: Connection, item: T) throws -> Int64
    func delete(_ db: Connection, item: T) throws -> Void
    func findAll(_ db: Connection) throws -> [T]?
}


class Database {
    
    static var sharedDatabase = Database(path: "members.db")
    
    let db: Connection?
    let contacts = ContactsTable()
    let levels = LevelsTable()
    let members = MembershipTable()
    let nra = NRAMembershipTable()
    let notes = NotesTable()
    let sponsors = SponsorTable()
    let groups =  GroupsTable()
    let gate_access = GateAccessTable()
    let events = EventTable()
    let registrations = EventRegistrationTable()
    
    init(path: String) {
        db = try? Connection(path)
        db?.trace { print($0) }
        
        do {
            try self.updateSchema()
        }
        catch _ {}
    }
    
    func updateSchema() throws -> Void {
        guard let db = self.db else {
            throw DataBaseError.notOpen
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
                try _ = db.run(members.table.addColumn(members.gate_id, defaultValue: nil))
                try _ = db.run(members.table.createIndex(members.level))
                try _ = db.run(members.table.createIndex(members.gate_card))
                try _ = db.run(members.table.createIndex(members.gate_id))
                try _ = gate_access.create(db)
                
                db.userVersion = 2
                fallthrough
            case 2:
                try events.create(db)
                try registrations.create(db)
                
                db.userVersion = 3
                break
            default:
                throw DataBaseError.invalidVersion
            }
            
        }
        catch let e {
            print("updateSchema failed \(e)")
        }
    }

    func membersForQuery(_ query: QueryType) -> [Member] {
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

}

extension Connection {
    public var userVersion: Int {
        get { return Int(try! scalar("PRAGMA user_version") as! Int64) }
        set { try! _ = run("PRAGMA user_version = \(newValue)") }
    }
}


extension Date {
    static func fromAnyObject(_ anyObject: AnyObject?) -> Date? {
        if let d = anyObject as? Double {
            return Date(timeIntervalSince1970: d)
        }
        else if let s = anyObject as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.autoupdatingCurrent
            return formatter.date(from: s)
        }
        return nil
    }
}

extension Int {
    static func fromAnyObject(_ anyObject: AnyObject?) -> Int? {
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
