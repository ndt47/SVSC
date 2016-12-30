//
//  EventViewController.swift
//  SVSC
//
//  Created by Nathan Taylor on 12/23/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation
import Cocoa
import CryptoTokenKit
import SQLite

class EventViewController : NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var nameView: NSTextField?
    @IBOutlet var dateView: NSTextField?
    @IBOutlet var fromView: NSTextField?
    @IBOutlet var toView: NSTextField?
    @IBOutlet var registerMemberIDView: NSTextField?
    @IBOutlet var registerFirstNameView: NSTextField?
    @IBOutlet var registerLastNameView: NSTextField?
    @IBOutlet var registerTypePopup: NSPopUpButton?
    @IBOutlet var registerButton: NSButton?
    @IBOutlet var registrantTableView: NSTableView?
    @IBOutlet var countLabel: NSTextField?
    
    @IBAction func checkin(_ sender: Any?) -> Void {
        let db = Database.sharedDatabase
        let first = registerFirstNameView?.stringValue
        let last = registerLastNameView?.stringValue
        let type = RegistrationType(rawValue: registerTypePopup?.selectedItem?.tag ?? 0) ?? .guest
        let now = Date()
        var new: Registrant?
        var query: QueryType? = nil
        
        if let text = registerMemberIDView?.stringValue, let id = Int(text, radix: 10) {
            query = db.contacts.table
                .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                .filter(db.members.table[db.members.member_id] == id)
                .limit(1)


        }
        else {
            guard let fn = first else {
                return
            }
            guard let ln = last else {
                return
            }
            
            switch type {
            case .guest:
                new = Registrant(first: fn, last: ln)
            case .probationary, .member:
                query = db.contacts.table
                    .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
                    .filter(db.contacts.table[db.contacts.first_name].like(fn) && db.contacts.table[db.contacts.last_name].like(ln))
                    .limit(1)
            }
            
        }
        
        if let q = query {
            let members = db.membersForQuery(q)
            if let m = members.first {
                new = Registrant(member: m)
            }
        }
        if new == nil, let fn = first, let ln = last {
            new = Registrant(first: fn, last: ln)
        }
        
        if let n = new {
            if n.registrationDate == nil {
                n.registrationDate = now
            }
            n.checkinDate = now
            registrantTableView?.beginUpdates()
            registrants.insert(n, at: 0)
            registrantTableView?.insertRows(at: IndexSet([0]), withAnimation: .slideDown)
            registrantTableView?.endUpdates()
        }
    }
    
    enum RegistrationType : Int, CustomStringConvertible {
        case guest = 0
        case member = 1
        case probationary = 2
        
        static func from(membershipType: MembershipType) -> RegistrationType {
            switch membershipType {
            case .Probationary, .Youth_Probationary:
                return .probationary
            default:
                return .member
            }
        }
        
        var description: String {
            switch self {
            case .guest:
                return "Guest"
            case .probationary:
                return "Probationary"
            case .member:
                return "Member"
            }
        }
    }
    
    class Registrant {
        struct Guest {
            let firstName: String
            let lastName: String
        }
        
        let member : Member?
        let guest : Guest?
        
        var registrationDate: Date?
        var checkinDate: Date?
    
        init(member: Member) {
            self.member = member
            self.guest = nil
        }
        
        init(first: String, last: String) {
            self.member = nil
            self.guest = Guest(firstName: first, lastName: last)
        }
        
        func value(forKey key: String) -> Any? {
            switch key {
            case "registration_date":
                return registrationDate
            case "checkin_date":
                return checkinDate
            case "date":
                return checkinDate ?? registrationDate
            case "checked_in":
                return checkinDate != nil ? true : false
            default:
                if let m = member {
                    switch key {
                    case "registration_type":
                        if let type = member?.membership?.level.type {
                            return RegistrationType.from(membershipType: type).description
                        }
                        else {
                            return RegistrationType.guest.description
                        }
                    default:
                        return m.value(forKey: key)
                    }
                }
                else {
                    // Guest
                    switch key {
                    case "first_name":
                        return guest?.firstName.capitalized
                    case "last_name":
                        return guest?.lastName.capitalized
                    case "registration_type":
                        return RegistrationType.guest.description
                    default:
                        return nil
                    }
                }
            }
        }
    }
    var registrants = [Registrant]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registrantTableView?.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(MemberListController.membersListDidChange(_:)), name: NSNotification.Name(rawValue: "MembersQueryDidChange"), object: nil)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        mgr?.addObserver(self, forKeyPath: "slotNames", options: [.new, .initial], context: nil)
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        mgr?.removeObserver(self, forKeyPath: "slotNames")
        for slot in slots {
            slot.removeObserver(self, forKeyPath: "state")
        }
        slots.removeAll()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let kp = keyPath else {
            return
        }
        if let o = object as? TKSmartCardSlotManager, let m = mgr, o === m {
            switch kp {
            case "slotNames":
                let names = o.slotNames
                if names.count > 1 {
                    let name = names[1]
                    o.getSlot(withName: name, reply: { (slot) in
                        if let s = slot {
                            self.addSlot(s)
                        }
                    })
                }
            default:
                break
            }
        }
        else if let o = object as? TKSmartCardSlot, slots.contains(o) {
            switch kp {
            case "state":
                if let n = change?[.newKey] as? Int, let state = TKSmartCardSlot.State(rawValue: n) {
                    switch state {
                    case .missing:
                        print("missing")
                        self.removeSlot(o)
                    case .empty:
                        print("empty")
                    case .probing:
                        print("probing")
                    case .muteCard:
                        print("muteCard")
                    case .validCard:
                        print("validCard")
                        if let atr = o.atr {
                            print("Card \(atr.cardNumber)")
                            DispatchQueue.main.async {
                                self.addRegistrant(fromGateCard: atr.cardNumber)
                            }
                        }
                    }
                }
                else {
                    print("\(kp) \(change!)")
                }
            default:
                break
            }
        }
    }
    
    func addRegistrant(fromGateCard card: Int) {
        let db = Database.sharedDatabase
        let query = db.contacts.table
            .join(db.members.table, on: db.contacts.table[db.contacts.id] == db.members.table[db.members.contact_id])
            .filter(db.members.table[db.members.gate_card] == card)
            .order(db.members.table[db.members.member_id].asc)
            .limit(1)
        let members = db.membersForQuery(query)
        guard members.count > 0 else {
            // No matches
            Swift.print("No member found for Gate Card(\(card))")
            return
        }

        let fm = members[0]
        guard let membership = fm.membership else {
            return
        }
        Swift.print("Found Member(\(membership.member_id)) for Gate Card(\(card))")

        self.registerMemberIDView?.stringValue = String(describing: membership.member_id)
        self.registerFirstNameView?.stringValue = fm.contact.first_name.capitalized
        self.registerLastNameView?.stringValue = fm.contact.last_name.capitalized
        self.registerTypePopup?.selectItem(withTag: RegistrationType.from(membershipType: membership.level.type).rawValue)
        let sound = NSSound(named: "R03 09 - ALERT01 - Synths Massive_A")
        sound?.play()
    }

    
    // MARK: NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return registrants.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let registrant = registrants[row]
        var value: Any? = nil
        if let column = tableColumn  {
            value = registrant.value(forKey: column.identifier)
        }
        return value
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let newDescriptors = tableView.sortDescriptors
        
        if let sortedRegistrants = NSArray(array: registrants).sortedArray(using: newDescriptors) as? [Registrant] {
            registrants = sortedRegistrants
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        return proposedSelectionIndexes
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        return false
    }

    //MARK: Private
    
    fileprivate let mgr = TKSmartCardSlotManager.default
    fileprivate var slots = [TKSmartCardSlot]()
    
    fileprivate func addSlot(_ slot: TKSmartCardSlot) {
        slot.addObserver(self, forKeyPath: "state", options: [.new, .initial], context: nil)
        slots.append(slot)
    }
    
    fileprivate func removeSlot(_ slot: TKSmartCardSlot) {
        if let index = slots.index(of: slot) {
            slot.removeObserver(self, forKeyPath: "state")
            slots.remove(at: index)
        }
    }
}

fileprivate extension Data {
    func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }
}

fileprivate extension TKSmartCardATR {
    var cardNumber: Int {
        get {
            let a = self.bytes.toArray(type: UInt8.self)
            let string = String(format: "%0.2X%0.2X%0.2X", a[5], a[6], a[7])
            return Int(string, radix: 10) ?? 0
        }
    }
}
