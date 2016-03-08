//
//  PrintCardsWindowController.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/7/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa

class PrintCardsWindowController : NSWindowController {
    
    var members: [Member]? {
        get {
            if let cvc = contentViewController as? PrintCardsViewController {
                return cvc.members
            }
            return nil
        }
        set {
            if let cvc = contentViewController as? PrintCardsViewController {
                cvc.members = newValue
            }
        }
    }
}
