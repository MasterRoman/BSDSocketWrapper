//
//  AddressInfo.swift
//  BSDSocketWrapper
//
//  Created by Admin on 01.05.2021.
//

import Foundation

class AddressInfo {
    private var addressInfoPointer : UnsafeMutablePointer<addrinfo>
    
    init(addrInfoPointer : UnsafeMutablePointer<addrinfo>) {
        self.addressInfoPointer = addrInfoPointer
    }
    
    init(host: String?, port: String?,family: AddressFamily = .IPv4, sockType: SockType = .stream, flags: Flags = .passive) throws {

        var hints = addrinfo();
        hints.ai_family = family.rawValue
        hints.ai_socktype = sockType.rawValue
        hints.ai_flags = flags.rawValue
        
        var addrInfoPointer: UnsafeMutablePointer<addrinfo>? = nil
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
    
    deinit {
        freeaddrinfo(self.addressInfoPointer)
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

extension AddressInfo{
    func getAddressInfo<T>(params : (addrinfo) throws -> T) rethrows -> T where T : BaseSocket{
        return try params(self.addressInfoPointer.pointee)
    }
}
