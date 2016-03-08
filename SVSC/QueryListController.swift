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
        sql = aDecoder.decodeObjectForKey("sql") as! String
        super.init(name: aDecoder.decodeObjectForKey("name") as! String, children: nil)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(sql, forKey: "sql")
    }
}

class StaticMembersQueryItem : OutlineItem {
    let query: ((db: Database) -> [Member])
    
    init(name: String, query: ((db: Database) -> [Member])) {
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
                    .order(contacts.table[contacts.first_name])
                    .order(contacts.table[contacts.last_name])
                return db.membersForQuery(query)
            }
            return []
        })
    }
}

class QueryListController : NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    @IBOutlet weak var sourceList: NSOutlineView?

    private var items: [OutlineItem] = [OutlineItem]()
    private let waManager = WildApricotManager()

    private var password = "w1ll1amg1bs0n"
    private var username = "nathantaylor@me.com"
    
    private let db = try? Database(path: "members.db")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let db = self.db else {
            return
        }
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
                    .order(db.contacts.table[db.contacts.first_name])
                    .order(db.contacts.table[db.contacts.last_name])
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Probationary", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 766369 || db.members.table[db.members.level] == 772000)
                    .order(db.contacts.table[db.contacts.first_name])
                    .order(db.contacts.table[db.contacts.last_name])
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Youth", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 772000 || db.members.table[db.members.level] == 768878)
                    .order(db.contacts.table[db.contacts.first_name])
                    .order(db.contacts.table[db.contacts.last_name])
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Applicant", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 766001)
                    .order(db.contacts.table[db.contacts.first_name])
                    .order(db.contacts.table[db.contacts.last_name])
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Life", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 765404)
                    .order(db.contacts.table[db.contacts.first_name])
                    .order(db.contacts.table[db.contacts.last_name])
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Senior", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 768880)
                    .order(db.contacts.table[db.contacts.first_name])
                    .order(db.contacts.table[db.contacts.last_name])
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Veteran", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 765464)
                    .order(db.contacts.table[db.contacts.first_name])
                    .order(db.contacts.table[db.contacts.last_name])
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Seaside", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 772041)
                    .order(db.contacts.table[db.contacts.first_name])
                    .order(db.contacts.table[db.contacts.last_name])
                return db.membersForQuery(query)
            }),
            StaticMembersQueryItem(name: "Scotts Valley PD", query: { (db) -> [Member] in
                let query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.members.table[db.members.level] == 768806)
                    .order(db.contacts.table[db.contacts.first_name])
                    .order(db.contacts.table[db.contacts.last_name])
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
                    .filter(db.members.table[db.members.holster] == "Yes")
                    .order(db.contacts.table[db.contacts.first_name])
                    .order(db.contacts.table[db.contacts.last_name])
                return db.membersForQuery(query)
            }))

        }
        
        items.append(OutlineItem(name: "GROUPS", children: groupChildren))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        sourceList?.reloadData()

        NSNotificationCenter.defaultCenter().postNotificationName("MembersQueryDidChange", object: self, userInfo: ["members" : db!.allMembers()])
    }
 
    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        return 24.0
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let item = item as? OutlineItem {
            guard let items = item.children else {
                return 0
            }
            return items.count
        }
        return self.items.count
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        guard let item = item as? OutlineItem else {
            return false
        }
        guard let children = item.children else {
            return false
        }
        return children.count > 0 ? true : false
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        return self.items.contains(item as! OutlineItem)
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        
        guard let item = item as? OutlineItem else {
            return self.items[index]
        }
        guard let children = item.children else {
            return OutlineItem(name: "ERROR", children: nil)
        }
        return children[index]
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if let i = item as? OutlineItem {
            return i.name
        }
        return nil
    }

    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        return true
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        guard let outlineView = self.sourceList else {
            return
        }
        if let item = outlineView.itemAtRow(outlineView.selectedRow) as? StaticMembersQueryItem {
            NSNotificationCenter.defaultCenter().postNotificationName("MembersQueryDidChange", object: self, userInfo: ["members" : item.query(db: db!)])
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName("MembersQueryDidChange", object: self, userInfo: ["members" : db!.allMembers()])
        }
    }
    
    @IBAction func loadMembers(sender: AnyObject) -> Void {
        waManager.authenticate(username, password: password)
        waManager.downloadMembers { (json) -> Void in
            if let db = self.db, let response = json {
                db.importMembers(fromResponseDict: response)
                
                NSNotificationCenter.defaultCenter().postNotificationName("MembersQueryDidChange", object: self, userInfo: ["members" : db.allMembers()])
            }
        }
    }
}