//
//  MemberDetailController.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/5/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa

class MemberDetailController : NSViewController {
    
    @IBOutlet weak var cardView: CardView?
    @IBOutlet var notesView: NSTextView?

    var member: Member? {
        didSet {
            cardView?.member = member
            cardView?.setNeedsDisplay((cardView?.bounds)!)
            notesView?.string = member?.notes?.text ?? ""
            notesView?.setNeedsDisplay((notesView?.bounds)!)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    required init?(coder: NSCoder) {
        member = coder.decodeObject(forKey: "member") as? Member
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(MemberDetailController.selectedMembersDidChange(_:)), name: NSNotification.Name(rawValue: "SelectedMembersDidChange"), object: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(MemberDetailController.selectedMembersDidChange(_:)), name: NSNotification.Name(rawValue: "SelectedMembersDidChange"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(MemberDetailController.selectedMembersDidChange(_:)), name: NSNotification.Name(rawValue: "SelectedMembersDidChange"), object: nil)
    }
    
    func selectedMembersDidChange(_ note: Notification) -> Void {
        if let members = (note as NSNotification).userInfo?["selectedMembers"] as? [Member] , members.count > 0 {
            self.member = members[0]
        }
    }
    
    func memberDetails() -> NSAttributedString? {
        guard let text = member?.notes?.text else {
            return nil
        }
        return NSAttributedString(string: text)
    }
}
