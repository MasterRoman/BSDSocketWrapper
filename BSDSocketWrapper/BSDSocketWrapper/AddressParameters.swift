//
//  AddressParameters.swift
//  BSDSocketWrapper
//
//  Created by Admin on 03.05.2021.
//

import Foundation

public enum AddressFamily : Int32{
    
    case unspecified = 0  //AF_UNSPEC
    case IPv4 = 2 //AF_INET
    case IPv6 = 30 //AF_INET6
    
    func getSize()->UInt32{
        switch self {
        case .IPv4:
            return socklen_t(MemoryLayout<sockaddr_in>.size)
        case .IPv6:
            return socklen_t(MemoryLayout<sockaddr_in6>.size)
        case .unspecified:
            return 0
        }
    }
}

public enum SockType : Int32 {
    case stream = 1    //SOCK_STREAM
    case datagram = 2  //SOCK_DGRAM
}

public enum Flags : Int32{
    case passive = 1 //AI_PASSIVE get address to use bind()
    case `default` = 1536 //AI_DEFAULT
}

