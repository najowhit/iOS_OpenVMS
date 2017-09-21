//
//  SwiftOBD.swift
//  OVMS
//
//  Created by Nathan White on 9/21/17.
//  Copyright © 2017 Nathan White. All rights reserved.
//

import Foundation
import SwiftSocket

class SwiftOBD: NSData {
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    let maxReadLength = 1024 * 10
    
    func setupNetworkCommunication(address: String, port: Int32) {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, address as CFString, UInt32(port), &readStream, &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .commonModes)
        outputStream.schedule(in: .current, forMode: .commonModes)
        
        inputStream.open()
        outputStream.open()
    }
    
    func sendCommand(command: String){
        //data is equivalent in value to buf = [UInt8](command.utf8) 
        let data = command.data(using: .ascii)!
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
        
    }
    
}

extension SwiftOBD: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("new response received")
        case Stream.Event.endEncountered:
            print("new response received")
        case Stream.Event.errorOccurred:
            print("error occurred")
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
            readAvailableBytes(stream: aStream as! InputStream)
        default:
            print("some other event...")
            break
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError{
                    break
                }
            }
         
        // message object goes here
        
        }
    }
    


}
