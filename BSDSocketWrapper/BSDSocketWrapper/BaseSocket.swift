//
//  BaseSocket.swift
//  BSDSocketWrapper
//
//  Created by Admin on 04.05.2021.
//

import Foundation

protocol BaseSocket {
    var socket : Socket {get}
    var address : SockAddress {get}
    
    init(socket : Socket,address : SockAddress) throws
}

extension BaseSocket{
    init(addrInfo: addrinfo) throws{
        let socket = try Socket(addrInfo: addrInfo)
        let address = SockAddress(from: addrInfo)
        try self.init(socket: socket, address: address)
    }
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
    func receive(completionHandler:(String) -> ()) throws{
        var output = String()
        
        let bufferSize = 1024
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        pointer.initialize(repeating: 0, count: bufferSize)
        
        let buffer = UnsafeMutableBufferPointer(start: pointer, count: bufferSize)
        
        var recivedBytes = 0
        repeat {
            recivedBytes = try socket.receive(buffer: buffer)
            guard recivedBytes != 0 else {
                break
            }
            let string = String(cString: buffer.baseAddress!)
            output.append(string)
        } while true
     
           
        completionHandler(output)
        pointer.deinitialize(count: bufferSize)
        pointer.deallocate()
    
    }
    
    
}

extension BaseSocket{
    
    func shutdown(with state: Socket.ShutDownState) throws{
        try socket.shutDown(with: state)
    }
    
    func close() throws{
        try socket.close()
    }
}

extension BaseSocket{
    func bind() throws{
        try address.getAddress(params: { address,length in
            try socket.bind(to:address, sockLength: length)
        })
        
    }
    
}
