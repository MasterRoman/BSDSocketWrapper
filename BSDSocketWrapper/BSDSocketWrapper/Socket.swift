//
//  Socket.swift
//  BSDSocketWrapper
//
//  Created by Admin on 30.04.2021.
//

import Foundation

struct Socket {
    let endPoint : Int32
    init(with endPoint:Int32) {
        self.endPoint = endPoint
    }
    
    init(addrInfo : addrinfo) throws {
        let endPoint = Darwin.socket(addrInfo.ai_family, addrInfo.ai_socktype, addrInfo.ai_protocol)
        guard endPoint != -1 else {
            throw SocketError.creationFailed(errorCode: errno)
        }
        self.init(with: endPoint)
    }
}

extension Socket{
    enum SocketError : Error,CustomStringConvertible{
        public var description: String {
            func returnError(from code:errno_t) -> String{
                return String(utf8String: strerror(code)) ?? "unknown"
            }
            switch self {
            case .creationFailed(let errorCode):
                return "" + returnError(from: errorCode)
            case .bindFailed(let errorCode):
                return "" + returnError(from: errorCode)
            case .connectFailed(let errorCode):
                return "" + returnError(from: errorCode)
            case .listenFailed(let errorCode):
                return "" + returnError(from: errorCode)
            case .acceptFailed(let errorCode):
                return "" + returnError(from: errorCode)
            case .shutDownFailed(let errorCode):
                return "" + returnError(from: errorCode)
            case .closeFailed(let errorCode):
                return "" + returnError(from: errorCode)
                
            case .sendFailed(let errorCode):
                return "" + returnError(from: errorCode)
            case .receiveFailed(let errorCode):
                return "" + returnError(from: errorCode)
                
            }
        }
        case creationFailed(errorCode : errno_t)
        case bindFailed(errorCode : errno_t)
        case connectFailed(errorCode : errno_t)
        case listenFailed(errorCode : errno_t)
        case acceptFailed(errorCode : errno_t)
        case shutDownFailed(errorCode : errno_t)
        case closeFailed(errorCode : errno_t)
        
        case sendFailed(errorCode : errno_t)
        case receiveFailed(errorCode : errno_t)
    }
}

//General
extension Socket{
    func bind(to address:UnsafePointer<sockaddr>,sockLength:socklen_t) throws{
        guard Darwin.bind(endPoint, address, sockLength) != -1 else {
            throw SocketError.bindFailed(errorCode: errno)
        }
    }
    
    
    func close() throws{
        guard Darwin.close(endPoint) != -1 else {
            throw SocketError.closeFailed(errorCode: errno)
        }
        
    }
}

extension Socket{
    
    enum ShutDownState : Int32
    {
        case shutReceive = 0 //SHUT_RD
        case shutSend    = 1 //SHUT_WR
        case shutBoth    = 2 //SHUT_RDWR
        
    }
    
    func shutDown(with state:ShutDownState) throws{
        guard Darwin.shutdown(endPoint,state.rawValue) != -1 else {
            throw SocketError.shutDownFailed(errorCode: errno)
        }
    }
}

//Client
extension Socket{
    func connect(to address:UnsafePointer<sockaddr>,sockLength:socklen_t) throws{
        guard Darwin.connect(endPoint, address, sockLength) != -1 else {
            throw SocketError.connectFailed(errorCode: errno)
        }
        
    }
}

//Server
extension Socket{
    func listen(with backlog:Int32) throws{
        guard Darwin.listen(endPoint, backlog) != -1 else
        {
            throw SocketError.listenFailed(errorCode: errno)
        }
    }
    
    func accept() throws -> (Socket,SockAddress){
        var sockAddress = sockaddr()
        let addrStorage = sockaddr_storage()
        var sockLength : socklen_t = socklen_t(MemoryLayout.size(ofValue: addrStorage))
        let clientSocket = Darwin.accept(endPoint, &sockAddress, &sockLength)
        guard clientSocket != -1 else {
            throw SocketError.acceptFailed(errorCode: errno)
        }
        let sockAddr = SockAddress(from: sockAddress)
        return (Socket(with: clientSocket),sockAddr)
    }
}


//TCP
extension Socket{
    func send(pointer: UnsafePointer<UInt8>, count: Int, flags: Int32 = 0) throws -> Int {
        return try send(buffer: UnsafeBufferPointer(start: pointer, count: count), flags: flags)
    }
    
    func send(buffer : UnsafeBufferPointer<UInt8>,flags : Int32 = 0) throws -> Int{
        let sendedBytes = Darwin.send(endPoint, buffer.baseAddress, buffer.count, flags)
        guard sendedBytes != -1 else
        {
            throw SocketError.sendFailed(errorCode: errno)
        }
        return sendedBytes
    }
    
    func receive(buffer: UnsafeMutableBufferPointer<UInt8>, flags: Int32 = 0) throws -> Int{
        let receivedBytes = Darwin.recv(endPoint, buffer.baseAddress, buffer.count, flags)
        guard receivedBytes != -1 else
        {
            throw SocketError.receiveFailed(errorCode: errno)
        }
        return receivedBytes
    }
}


//UDP
extension Socket{
    func send(to address:UnsafePointer<sockaddr>,pointer: UnsafePointer<UInt8>, count: Int, flags: Int32 = 0,sockLength:socklen_t) throws -> Int {
        return try send(to: address, buffer: UnsafeBufferPointer(start: pointer, count: count), flags: flags, sockLength: sockLength)
    }
    
    func send(to address:UnsafePointer<sockaddr>,buffer: UnsafeBufferPointer<UInt8>, flags: Int32 = 0,sockLength:socklen_t) throws -> Int{
        let sendedBytes = sendto(endPoint, buffer.baseAddress, buffer.count, flags, address, sockLength)
        guard sendedBytes != -1 else
        {
            throw SocketError.sendFailed(errorCode: errno)
        }
        return sendedBytes
        
    }
    
    func receive(from address:UnsafeMutablePointer<sockaddr>,buffer: UnsafeMutableBufferPointer<UInt8>, flags: Int32 = 0,sockLength:UnsafeMutablePointer<socklen_t>) throws -> Int{
        let receivedBytes = Darwin.recvfrom(endPoint, buffer.baseAddress, buffer.count, flags, address,sockLength)
        guard receivedBytes != -1 else
        {
            throw SocketError.receiveFailed(errorCode: errno)
        }
        return receivedBytes
    }
}
