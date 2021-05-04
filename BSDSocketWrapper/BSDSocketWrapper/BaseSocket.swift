//
//  BaseSocket.swift
//  BSDSocketWrapper
//
//  Created by Admin on 04.05.2021.
//

import Foundation

protocol BaseSocket {
    var socket : Socket {get}
}

extension BaseSocket{
    private func send(buffer : UnsafeBufferPointer<UInt8>) throws {
        let bytesToSend = buffer.count
        var sentBytes = 0
        
        while sentBytes < bytesToSend {
            sentBytes += try socket.send(pointer: buffer.baseAddress! + sentBytes, count: buffer.count - sentBytes)
        }
    }
    
    func send(message : String) throws{
        var tempMessage = message
        try tempMessage.withUTF8({
            try send(buffer: $0)
        })
    }
}

extension BaseSocket{
  
    

}
