//
//  DatabaseFromCSV.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/9/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import SQLite
import CSwiftV

extension Database {
    func importGateLogs(_ url: URL, gate: Gate) -> Void {
        guard let string = try? NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue) else {
            return
        }
        guard let db_conn = self.db else {
            return
        }
        let csv = CSwiftV(with: string as String, separator: ", ")
        
        if let rows = csv.keyedRows {
            var idMap = [String: Set<Int>]()
            var allIDs = Set<Int>()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy'T'hh:mm:ss a"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.autoupdatingCurrent

            for row in rows {
                guard let user = row["User No"], let id = Int(user, radix: 10), let event = row["Event"] else {
                    continue
                }
                
                var gateSide: GateSide? = nil
                switch event {
                    case "Entered Primary Side":
                        gateSide = GateSide.enter
                        break
                    case "Entered Secondary Side":
                        gateSide = GateSide.exit
                        break
                    case "User Denied Access":
                        gateSide = GateSide.denied;
                        break
                    default:
                        break
                }
                guard let side = gateSide else {
                    continue
                }
                
                guard let d = row["Date"], let t = row["Time"] else {
                    continue
                }
                
                guard let date = formatter.date(from: "\(d)T\(t)") else {
                    continue
                }
                
                let name = row["Name"]
                if let n = name {
                    allIDs.insert(id)
                    for m in n.lowercased().components(separatedBy: " ") {
                        if var set = idMap[m] {
                            set.insert(id)
                        }
                        else {
                            var set = Set<Int>()
                            set.insert(id)
                            idMap[m] = set
                        }
                    }
                }
                
                let record = GateAccess(
                    id: id,
                    name: name,
                    gate: gate,
                    side: side,
                    date: date
                )
                do {
                    try gate_access.insert(db_conn, item: record)
                }
                catch _ {}
            }
            
            guard let nameRows = try? db_conn.prepare(contacts.table
                .select(contacts.id, contacts.first_name, contacts.last_name, contacts.preferred_name)) else {
                    return
            }
            
            for row in nameRows {
                let contact_id = row[contacts.id]
                var remaining = Set<Int>(allIDs)
                
                let last = row[contacts.last_name].lowercased()
                for l in last.components(separatedBy: " ") {
                    if let set = idMap[l] {
                        remaining.formIntersection(set)
                    }
                }

                if let preferred = row[contacts.preferred_name]?.lowercased() {
                    var remPref = Set<Int>(remaining)
                    for p in preferred.components(separatedBy: " ") {
                        if let set = idMap[p] {
                            remPref.formIntersection(set)
                        }
                    }
                    if (remPref.count > 0) {
                        remaining.formIntersection(remPref)
                    }
                }
                
                if remaining.count > 1 {
                    var remFirst = Set<Int>(remaining)
                    let first = row[contacts.first_name].lowercased()
                    for f in first.components(separatedBy: " ") {
                        if let set = idMap[f] {
                            remFirst.formIntersection(set)
                        }
                    }
                    if remFirst.count > 0 {
                        remaining.formIntersection(remFirst)
                    }
                }
                
                if remaining.count == 1 {
                    let gate_id = remaining.first!
                    do {
                        try db_conn.run(members.table.filter(members.contact_id == contact_id).update(members.gate_id <- gate_id))
                    }
                    catch _ {}
                }
            }

        }
        
        
    }
}
