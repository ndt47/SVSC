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

class QueryItem : OutlineItem, NSCoding {
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

class QueryListController : NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var items: [OutlineItem] = [OutlineItem]()
    
    let waManager = WildApricotManager()
    
    @IBOutlet weak var sourceList: NSOutlineView?
    @IBOutlet weak var resultController: MemberListController?

    private var password = "w1ll1amg1bs0n"
    private var username = "nathantaylor@me.com"

    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        items.append(OutlineItem(name: "ALL", children: nil))
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidAppear() {
        let authAlert = NSAlert()
        sourceList?.reloadData()
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
        guard let children = (item as! OutlineItem).children else {
            return false
        }
        return children.count > 0 ? true : false
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        return self.items.contains(item as! OutlineItem)
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        guard let children = (item as! OutlineItem).children else {
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
}