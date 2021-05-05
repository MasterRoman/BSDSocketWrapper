//
//  SocketAddress.swift
//  BSDSocketWrapper
//
//  Created by Admin on 05.05.2021.
//

import Foundation

enum SockAddress{
    case IPv4(address : sockaddr_in)
    case IPv6(address : sockaddr_in6)
    case empty
    
}

extension SockAddress{
    init(from addrInfo : addrinfo) {
        switch addrInfo.ai_family {
        case AF_INET:
            let address = addrInfo.ai_addr.withMemoryRebound(to: sockaddr_in.self , capacity: Int(AddressFamily.IPv4.getSize()), {(
                pointer:UnsafeMutablePointer<sockaddr_in>) in
                return pointer.pointee
            })
            self = .IPv4(address: address)
        case AF_INET6:
            let address = addrInfo.ai_addr.withMemoryRebound(to: sockaddr_in6.self , capacity: Int(AddressFamily.IPv6.getSize()), {
                (pointer: UnsafeMutablePointer<sockaddr_in6>) in
                return pointer.pointee
            })
            self = .IPv6(address:address)
            
        default:
            self = .empty
        }
    }
}
