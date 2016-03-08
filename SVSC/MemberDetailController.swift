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

    var member: Member? {
        didSet {
            if let cv = cardView {
                cv.member = member
                cv.setNeedsDisplayInRect(cv.bounds)
            }
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
    }
    
    required init?(coder: NSCoder) {
        member = coder.decodeObjectForKey("member") as? Member
        super.init(coder: coder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedMembersDidChange:", name: "SelectedMembersDidChange", object: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedMembersDidChange:", name: "SelectedMembersDidChange", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedMembersDidChange:", name: "SelectedMembersDidChange", object: nil)
    }
    
    func selectedMembersDidChange(note: NSNotification) -> Void {
        if let members = note.userInfo?["selectedMembers"] as? [Member] where members.count > 0 {
            self.member = members[0]
        }
    }
}