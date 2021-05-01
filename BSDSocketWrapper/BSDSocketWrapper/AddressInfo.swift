//
//  AddressInfo.swift
//  BSDSocketWrapper
//
//  Created by Admin on 01.05.2021.
//

import Foundation

struct AddressInfo {
    private var addressInfoPointer : UnsafeMutablePointer<addrinfo>
    
    init(addrInfoPointer : UnsafeMutablePointer<addrinfo>) {
        self.addressInfoPointer = addrInfoPointer
    }
    
    init(host: String?, port: String?,family: Int32 = AF_UNSPEC, sockType: Int32 = SOCK_STREAM, flags: Int32 = AI_PASSIVE) throws {
        var addrInfoPointer: UnsafeMutablePointer<addrinfo>? = nil
        
        var hints = addrinfo();
        hints.ai_family = family
        hints.ai_socktype = sockType
        hints.ai_flags = flags
        
        let result: Int32
        
        switch (host, port) {
        case let (host?, port?):
            result = getaddrinfo(host, port, &hints, &addrInfoPointer)
        case let (host?, nil):
            result = getaddrinfo(host, nil, &hints, &addrInfoPointer)
        case let (nil, port?):
            result = getaddrinfo(nil, port, &hints, &addrInfoPointer)
        default:
            throw AddressError.incorrectInitialization
        }
        
        guard result != -1 else {
            throw AddressError.getAddrInfoFailed(errorCode: result)
        }
      
        self.addressInfoPointer = addrInfoPointer!
    }
}



extension AddressInfo{
    enum AddressError : Error,CustomStringConvertible{
        public var description: String {
            func returnError(from code:errno_t) -> String{
                return String(utf8String: strerror(code)) ?? "unknown"
            }
            switch self {
            
            case .getAddrInfoFailed(let errorCode):
                return "" + returnError(from: errorCode)
            case .incorrectInitialization:
                return "Either port or address must be set"
                
            }
        }
        
        case getAddrInfoFailed(errorCode : errno_t)
        case incorrectInitialization
    }
}
