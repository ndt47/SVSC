//
//  PrintCardsView.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/7/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Cocoa

class PrintCardsView : NSView {
    var members: [Member] {
        didSet {
            let subviews = self.subviews
            for view in subviews {
                view.removeFromSuperview()
            }
            var frame = self.frame
            frame.size = PrintCardsView.optimalSize(members)
            self.frame = frame
            
            createSubviews()
        }
    }
    
    static let dpi = CGFloat(72.0)
    static func optimalSize(members: [Member]) -> NSSize {
        let pageSize = NSMakeSize(5.0 * 2.0 * dpi, 2.0 * 3.5 * dpi)
        let count = members.count
        
        var size = pageSize
        size.width *= CGFloat((count + 9)/10)
        return size
    }
    
    
    private func createSubviews() {
        var idx = 0
        for member in members {
            let view = CardView(member: member)
            var frame = view.frame
            frame.origin.x = frame.size.width * CGFloat(idx/2)
            frame.origin.y = frame.size.height * CGFloat(idx%2)
            frame.size.height = 3.5 * PrintCardsView.dpi
            frame.size.width = 2.0 * PrintCardsView.dpi
            view.frame = frame
            self.addSubview(view)
            
            idx++
        }
    }
    
    init(members: [Member]) {
        self.members = members
        let frame = NSRect(origin: CGPoint(x: 0, y: 0), size: PrintCardsView.optimalSize(members))
        
        super.init(frame: frame)
        self.createSubviews()
    }
    
    override init(frame frameRect: NSRect) {
        self.members = []
        super.init(frame: NSRect(origin: CGPoint(x: 0, y: 0), size: PrintCardsView.optimalSize([])))
    }
    
    required init?(coder: NSCoder) {
        self.members = []
        super.init(coder: coder)
        self.frame = NSRect(origin: CGPoint(x: 0, y: 0), size: PrintCardsView.optimalSize(self.members))
    }
    
    override func knowsPageRange(range: NSRangePointer) -> Bool {
        let count = members.count
        let pageCount = (count + 9) / 10
        
        range.memory = NSRange(location: 1, length: pageCount)
        
        return true
    }
    
    override func rectForPage(page: Int) -> NSRect {
        let dpi = PrintCardsView.dpi
        let pageSize = NSMakeSize(5.0 * 2.0 * dpi, 2.0 * 3.5 * dpi)
        let pageRect = NSRect(
            origin: NSPoint(x: CGFloat(page - 1) * pageSize.width, y: 0),
            size: pageSize
        )
        return pageRect
    }
    
//    override func beginDocument() {
//        let printInfo = NSPrintInfo.sharedPrintInfo()
//        let dpi = PrintCardsView.dpi
//        
//        printInfo.paperSize = NSSize(width: dpi * 8.5, height: dpi * 11)
//        printInfo.orientation = .Landscape
//        printInfo.leftMargin = dpi * 0.75
//        printInfo.rightMargin = dpi * 0.75
//        printInfo.topMargin = dpi * 0.5
//        printInfo.bottomMargin = dpi * 0.5
//        printInfo.verticallyCentered = true
//        printInfo.horizontallyCentered = true
//        
//        super.beginDocument()
//    }
    
    @IBAction override func print(sender: AnyObject?) -> Void {
        let printInfo = NSPrintInfo.sharedPrintInfo()
        let dpi = PrintCardsView.dpi
        
        printInfo.paperSize = NSSize(width: dpi * 8.5, height: dpi * 11)
        printInfo.orientation = .Landscape
        printInfo.leftMargin = dpi * 0.75
        printInfo.rightMargin = dpi * 0.75
        printInfo.topMargin = dpi * 0.5
        printInfo.bottomMargin = dpi * 0.5
        printInfo.verticallyCentered = true
        printInfo.horizontallyCentered = true

        let printOp = NSPrintOperation(view: self, printInfo: printInfo)
        printOp.canSpawnSeparateThread = true
        printOp.runOperation()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        NSColor.whiteColor().set()
        NSBezierPath.fillRect(dirtyRect)
    }
    
    override var acceptsFirstResponder : Bool {
        get {
            return true
        }
    }
}

