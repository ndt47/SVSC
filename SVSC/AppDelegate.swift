//
//  AppDelegate.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/5/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindowController: NSWindowController?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        mainWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("Main Window Controller") as? NSWindowController
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

