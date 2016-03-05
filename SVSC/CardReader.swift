//
//  CardReader.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/5/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation

class CardManager {
    class Reader {
        static var count: Int = 0
        
        let name: String
        let index: Int
        let state: SCARD_READERSTATE_A
        
        init(index i: Int, str: UnsafeMutablePointer<Int8>) {
            ++Reader.count
            
            index = i
            name = String(NSString(bytes: str, length: Int(strlen(str)), encoding: NSASCIIStringEncoding))
            state = SCARD_READERSTATE_A(szReader: str, pvUserData: nil, dwCurrentState: UInt32(SCARD_STATE_EMPTY), dwEventState: 0, cbAtr: 0, rgbAtr: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        }
    }
    
    private var context: SCARDCONTEXT = 0;
    private var readers: [Reader]? = nil
    private var queue: dispatch_queue_t = dispatch_queue_create("com.scottsvalleysports.cardmanager", DISPATCH_QUEUE_SERIAL)
    
    init?() {
        let rv = SCardEstablishContext(UInt32(SCARD_SCOPE_USER), nil, nil, &context)
        guard rv == SCARD_S_SUCCESS else {
            print("SCardEstablishContext Failed: \(pcsc_stringify_error(rv))")
            return nil
        }
        guard context != 0 else {
            print("SCardEstablishContext Failed: nil context")
            return nil
        }
        findReaders(context)
    }
    
    
    deinit {
        SCardReleaseContext(context)
        context = 0
    }

    private func findReaders(context: SCARDCONTEXT) -> Void {
        dispatch_async(queue) { () -> Void in
            var rv: Int32 = 0
            
            rv = SCardGetStatusChange(context, INFINITE, nil, 0)
            guard rv == SCARD_S_SUCCESS else {
                print("SCardGetStatusChange Failed \(pcsc_stringify_error(rv))")
                SCardReleaseContext(context)
                return
            }
            
            let groups = UnsafeMutablePointer<Int8>()
            var length: UInt32 = 0
            
            rv = SCardListReaders(context, groups, nil, &length)
            guard rv == SCARD_S_SUCCESS else {
                print("SCardListReaders Failed \(pcsc_stringify_error(rv))")
                SCardReleaseContext(context)
                return
            }
            
            let raw = UnsafeMutablePointer<Int8>.alloc(Int(length))
            rv = SCardListReaders(context, groups, raw, &length)
            guard rv == SCARD_S_SUCCESS else {
                print("SCardListReaders Failed \(pcsc_stringify_error(rv))")
                SCardReleaseContext(context)
                return
            }
            
            var newReaders = [Reader]()
            for var i = 0; i < Int(length - 1); ++i {
                let str = raw.advancedBy(i)
                let reader = Reader(index: i, str: str)
                newReaders.append(reader)
                print("Reader \(Reader.count): \(reader.name)")
                i += Int(strlen(str))
            }
            self.readers = newReaders
        }
    }
    
    func readProxCards(foundCard: ((card: String) -> Void)! ) {
        dispatch_async(queue) { () -> Void in
            let context = self.context
            guard context > 0 else {
                print("Invalid context")
                return
            }
            guard let readers = self.readers else {
                print("No readers")
                return
            }
            
            let count = readers.count
            let readerStates = UnsafeMutablePointer<SCARD_READERSTATE_A>.alloc(count)
            var i = 0
            for reader in readers {
                readerStates[i++] = reader.state
            }

            var rv: Int32 = 0
            print("Watching for card presence");
            rv = SCardGetStatusChange(context, INFINITE, readerStates, UInt32(count));
            
            guard rv == SCARD_S_SUCCESS else {
                print("SCardGetStatusChange Failed \(pcsc_stringify_error(rv))")
                SCardReleaseContext(context)
                return
            }
            
            print("Card presented!")
            var cardString: String? = nil
            for var i = 0; i < readers.count; ++i {
                let state = readerStates[i]
                if state.cbAtr > 0 && state.rgbAtr.0 == 0x3B {
                    cardString = String(format:"%0.X%0.2X%0.2X", state.rgbAtr.5, state.rgbAtr.6, state.rgbAtr.7)
                }
            }
            
            if let card = cardString {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    foundCard(card: card)
                })
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC))), self.queue, { () -> Void in
                self.readProxCards(foundCard)
            })
        }
    }
}
