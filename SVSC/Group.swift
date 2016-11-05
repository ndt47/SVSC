//
//  Group.swift
//  SVSCBadgePrinter
//
//  Created by Nathan Taylor on 2/21/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation

class Group {
    let group = DispatchGroup()
    var queue = DispatchQueue.main
    
    func enter(_ work: ((@escaping () -> Void) -> Void)) -> Void {
        group.enter()
        work { () -> Void in
            self.group.leave()
        }
    }
    
    func wait() -> Void {
        group.wait(timeout: DispatchTime.distantFuture)
    }
    
    func wait(_ seconds: Double) -> Void {
        group.wait(timeout: DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC))
    }
    
    func notify(_ block: @escaping ()->()) -> Void {
        group.notify(queue: queue, execute: block)
    }
    
    func notify(_ queue: DispatchQueue, block: @escaping ()->()) -> Void {
        group.notify(queue: queue, execute: block)
    }
    
}
