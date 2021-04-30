//
//  Socket.swift
//  BSDSocketWrapper
//
//  Created by Admin on 30.04.2021.
//

import Foundation

struct Socket {
    init() {
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
    func bind(){
        
    }
    
    func shutDown(){
        
    }
    
    func close(){
        
    }
}

//Client
extension Socket{
    func connect(){
        
    }
}

//Server
extension Socket{
    func listen(){
        
    }
    
    func accept(){
        
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
