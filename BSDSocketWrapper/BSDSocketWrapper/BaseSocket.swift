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
    
    func send(data : Data) throws{
        try data.withUnsafeBytes({ pointer in
            let typedPointer = pointer.bindMemory(to: UInt8.self)
            let buffer = UnsafeBufferPointer<UInt8>(start: typedPointer.baseAddress!, count: typedPointer.count)
            try send(buffer: buffer)
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


//for UDP
extension BaseSocket{
    private func sendTo(buffer : UnsafeBufferPointer<UInt8>) throws {
        let bytesToSend = buffer.count
        var sentBytes = 0
        while sentBytes < bytesToSend {
            try address.getAddress { (address, length) in
                sentBytes += try socket.send(to: address, pointer: buffer.baseAddress! + sentBytes, count: buffer.count - sentBytes, sockLength: length)
            }
            
        }
    }
    
    func sendTo(message : String) throws{
        var tempMessage = message
        try tempMessage.withUTF8({
            try sendTo(buffer: $0)
        })
    }
    
    func sendTo(data : Data) throws{
        try data.withUnsafeBytes({ pointer in
            let typedPointer = pointer.bindMemory(to: UInt8.self)
            let buffer = UnsafeBufferPointer<UInt8>(start: typedPointer.baseAddress!, count: typedPointer.count)
            try sendTo(buffer: buffer)
        })
    }
}

extension BaseSocket{
    func receiveFrom(completionHandler:(String) -> ()) throws{
        var output = String()
        
        let bufferSize = 1024
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        pointer.initialize(repeating: 0, count: bufferSize)
        
        let buffer = UnsafeMutableBufferPointer(start: pointer, count: bufferSize)
        
        try address.getMutableAddress { (address,length) in
            var recivedBytes = 0
            repeat {
                recivedBytes = try socket.receive(from: address, buffer: buffer, sockLength:length)
                guard recivedBytes != 0 else {
                    break
                }
                let string = String(cString: buffer.baseAddress!)
                output.append(string)
            } while true
            
        }
        
        
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
