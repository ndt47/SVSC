//
//  Group.swift
//  SVSCBadgePrinter
//
//  Created by Nathan Taylor on 2/21/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation

class Group {
    let group = dispatch_group_create()
    var queue = dispatch_get_main_queue()
    
    func enter(work: ((() -> Void) -> Void)) -> Void {
        dispatch_group_enter(group)
        work { () -> Void in
            dispatch_group_leave(self.group)
        }
    }
    
    func wait() -> Void {
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
    }
    
    func wait(seconds: Double) -> Void {
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC))))
    }
    
    func notify(block: dispatch_block_t) -> Void {
        dispatch_group_notify(group, queue, block)
    }
    
    func notify(queue: dispatch_queue_t, block: dispatch_block_t) -> Void {
        dispatch_group_notify(group, queue, block)
    }
    
}
