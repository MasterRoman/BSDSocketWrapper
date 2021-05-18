//
//  BaseSocket.swift
//  BSDSocketWrapper
//
//  Created by Admin on 04.05.2021.
//

import Foundation

protocol BaseSocket {
    var socket : Socket {get}
    var address : SockAddress {get set}
    
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
        try sendLength(message)
        var tempMessage = message
        try tempMessage.withUTF8({
            try send(buffer: $0)
        })
    }
    
    func send(data : Data) throws{
        try sendLength(data)
        try data.withUnsafeBytes({ pointer in
            let typedPointer = pointer.bindMemory(to: UInt8.self)
            let buffer = UnsafeBufferPointer<UInt8>(start: typedPointer.baseAddress!, count: typedPointer.count)
            try send(buffer: buffer)
        })
    }
    
    private func sendLength<T>(_ parameter : T) throws where T : Collection {
        var dataLength = parameter.count
        
        try withUnsafeBytes(of: &dataLength, {pointer in
            let buffer = pointer.bindMemory(to: UInt8.self)
            try send(buffer: buffer)
        })
      
      
    }
    
}

extension BaseSocket{
    
    private func receiveLength() throws -> Int{
        let bufferSize = 8
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        pointer.initialize(repeating: 0, count: bufferSize)
        
        let buffer = UnsafeMutableBufferPointer(start: pointer, count: bufferSize)
        defer {
            pointer.deinitialize(count: bufferSize)
            pointer.deallocate()
        }
        
        let recivedBytes = try socket.receive(buffer: buffer)
        guard recivedBytes != 0 else {
            return 0
        }
        
        var length = Int()
        var curInt = 0
        for (index,byte) in buffer.enumerated() {
            curInt = Int(byte) << (index * 4)
            length += curInt
        }

        return length
    }
    
    func receive(completionHandler:(String) -> ()) throws{
        var output = String()
        
        let bufferSize = 1024
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        pointer.initialize(repeating: 0, count: bufferSize)
        
        let buffer = UnsafeMutableBufferPointer(start: pointer, count: bufferSize)
        defer {
            completionHandler(output)
            pointer.deinitialize(count: bufferSize)
            pointer.deallocate()
        }
        
        
        var receivedBytes = 0
        var receivedCount = 0
        let lengthOfData = try receiveLength()
        
        repeat {
            receivedBytes = try socket.receive(buffer: buffer)
            guard receivedBytes != 0 else {
                break
            }
            receivedCount += receivedBytes
            let string = String(cString: buffer.baseAddress!)
            output.append(string)
        } while receivedCount < lengthOfData
        
        
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
    mutating func receiveFrom(with timeout : Int,completionHandler:(String) -> ()) throws{
        var output = String()
        
        let bufferSize = 1024
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        pointer.initialize(repeating: 0, count: bufferSize)
        
        defer {
            
            completionHandler(output)
            pointer.deinitialize(count: bufferSize)
            pointer.deallocate()
        }
        
        let buffer = UnsafeMutableBufferPointer(start: pointer, count: bufferSize)
        
        
        var recivedBytes = 0
        try address.getMutableAddress { (address,length) in
            defer {
                self.address = SockAddress(from: address.pointee)
            }
            repeat {
                recivedBytes = try socket.receive(from: address, buffer: buffer, sockLength:length, timeout: timeout)
                guard recivedBytes != 0 else {
                    break
                }
                let string = String(cString: buffer.baseAddress!)
                output.append(string)
            } while true
            
        }
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
