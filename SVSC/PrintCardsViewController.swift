//
//  PrintCardsViewController.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/7/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa

class PrintCardsViewController : NSViewController {
    @IBOutlet weak var cardsView: PrintCardsView?
    
    var members: [Member]? {
        get {
            if let cv = cardsView {
                return cv.members
            }
            return nil
        }
        set {
            if let m = newValue, let cv = cardsView {
                cv.members = m
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let cv = cardsView {
            cv.becomeFirstResponder()
        }
    }
}
