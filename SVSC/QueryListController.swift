//
//  QueryListController.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/5/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa
import SQLite

class OutlineItem : NSObject {
    var name: String
    var children: [OutlineItem]? = nil
    
    func isGroupItem() -> Bool {
        return false
    }
    
    init(name: String, children: [OutlineItem]?) {
        self.name = name
        self.children = children
        super.init()
    }
}

class CustomMembersQueryItem : OutlineItem, NSCoding {
    let sql: String
    
    init(name: String, sql: String) {
        self.sql = sql
        super.init(name: name, children: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        sql = aDecoder.decodeObject(forKey: "sql") as! String
        super.init(name: aDecoder.decodeObject(forKey: "name") as! String, children: nil)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(sql, forKey: "sql")
    }
}

class StaticMembersQueryItem : OutlineItem {
    let query: ((_ db: Database) -> [Member])
    
    init(name: String, query: @escaping ((_ db: Database) -> [Member])) {
        self.query = query
        super.init(name: name, children: nil)
    }
}

class GroupMembersQueryItem : StaticMembersQueryItem {
    let group: GroupParticipation
    init(group: GroupParticipation, db: Database) {
        self.group = group
        super.init(name: group.name, query: { (db) -> [Member] in
            let members = db.members
            let groups = db.groups
            let contacts = db.contacts
            let groupQuery = groups.table.select(groups.contact_id).filter(groups.id == group.id)
            var group_contacts = [Int]()
            if let rows = try? db.db!.prepare(groupQuery) {
                for row in rows {
                    group_contacts.append(row[groups.contact_id])
                }
                let query = contacts.table
                    .join(members.table, on: contacts.table[contacts.id] == members.table[members.contact_id])
                    .filter(group_contacts.contains(contacts.id))
                    .order(contacts.table[contacts.last_name].asc, contacts.table[contacts.first_name].asc)
                return db.membersForQuery(query)
            }
            return []
        })
    }
}

class QueryListController : NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    @IBOutlet weak var sourceList: NSOutlineView?

    fileprivate var items: [OutlineItem] = [OutlineItem]()

    fileprivate let db = Database.sharedDatabase

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let db_conn = db.db else {
            return
        }

        items.append(OutlineItem(name: "MEMBERS", children: [
            StaticMembersQueryItem(name: "All", query: { (db) -> [Member] in
                return db.allMembers()
            }),
            StaticMembersQueryItem(name: "Regular", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 768881 || db.members.table[db.members.level] == 768879)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Probationary", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 766369 || db.members.table[db.members.level] == 772000)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Youth", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 772000 || db.members.table[db.members.level] == 768878)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Applicant", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 766001)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Life", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 765404)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Senior", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 768880)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Veteran", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 765464)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Seaside", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 772041)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Scotts Valley PD", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 768806)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Pending Level Change", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.status] == MembershipStatus.PendingUpgrade.rawValue)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Graduating", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.meeting3] != nil)
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }),
        ]))
        items.append(OutlineItem(name: "EVENTS", children: []))
        
        var groupChildren = [OutlineItem]()
        if let group_rows = try? db_conn.prepare(db.groups.table.select(db.groups.id.distinct, db.groups.name).order(db.groups.name.asc)) {
            for row in group_rows {
                let group = GroupParticipation(
                    contact_id: 0,
                    name: row[db.groups.name],
                    id: row[db.groups.id.distinct]
                )
                groupChildren.append(GroupMembersQueryItem(group: group, db: db))
            }
            groupChildren.append(StaticMembersQueryItem(name: "Holster Rated", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.members.contact_id == db.contacts.id)
                    .filter(db.members.table[db.members.holster] == "Yes")
                    .order(db.contacts.table[db.contacts.last_name].asc, db.contacts.table[db.contacts.first_name].asc)
                return db.membersForQuery(query)
            }))
        }
        items.append(OutlineItem(name: "GROUPS", children: groupChildren))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        sourceList?.reloadData()

        NotificationCenter.default.post(name: Notification.Name(rawValue: "MembersQueryDidChange"), object: self, userInfo: ["members" : db.allMembers()])
    }
 
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 24.0
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? OutlineItem {
            guard let items = item.children else {
                return 0
            }
            return items.count
        }
        return self.items.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? OutlineItem else {
            return false
        }
        guard let children = item.children else {
            return false
        }
        return children.count > 0 ? true : false
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return self.items.contains(item as! OutlineItem)
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        guard let item = item as? OutlineItem else {
            return self.items[index]
        }
        guard let children = item.children else {
            return OutlineItem(name: "ERROR", children: nil)
        }
        return children[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let i = item as? OutlineItem {
            return i.name
        }
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = self.sourceList else {
            return
        }
        if let item = outlineView.item(atRow: outlineView.selectedRow) as? StaticMembersQueryItem {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "MembersQueryDidChange"), object: self, userInfo: ["members" : item.query(db)])
        }
        else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "MembersQueryDidChange"), object: self, userInfo: ["members" : db.allMembers()])
        }
    }
    
}
