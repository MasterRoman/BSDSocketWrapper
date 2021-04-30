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
    
    enum ShutDownState
    {
        case shutReceive
        case shutSend
        case shutBoth
        
        func getState()->Int32{
            switch self {
            case .shutReceive:
                return SHUT_RD
            case .shutSend:
                return SHUT_WR
            case .shutBoth:
                return SHUT_RDWR
            }
        }
    }
    
    func shutDown(with state:ShutDownState) throws{
        let state = state.getState()
        guard Darwin.shutdown(endPoint,state) != -1 else {
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
    
    func accept() throws -> Socket{
        var sockAddress = sockaddr()
        var sockLength : socklen_t = 0
        let clientSocket = Darwin.accept(endPoint, &sockAddress, &sockLength)
        guard clientSocket != -1 else {
            throw SocketError.acceptFailed(errorCode: errno)
        }
        
        return Socket(with: clientSocket)
    }
}


//TCP
extension Socket{
    func send(){
        
    }
    
    func receive(){
        
    }
}


//UDP
extension Socket{
    func sendTo(){
        
    }
    
    func receiveTo(){
        
    }
}
