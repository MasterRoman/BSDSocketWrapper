//
//  SocketAddress.swift
//  BSDSocketWrapper
//
//  Created by Admin on 05.05.2021.
//

import Foundation

enum SockAddress{
    case IPv4(address : sockaddr_in,length : socklen_t)
    case IPv6(address : sockaddr_in6,length : socklen_t)
    case empty
    
}

extension SockAddress{
    init(from addrInfo : addrinfo) {
        switch addrInfo.ai_family {
        case AF_INET:
            let address = addrInfo.ai_addr.withMemoryRebound(to: sockaddr_in.self , capacity: 1, {(
                pointer:UnsafeMutablePointer<sockaddr_in>) in
                return pointer.pointee
            })
            self = .IPv4(address: address, length: AddressFamily.IPv4.getSize())
        case AF_INET6:
            let address = addrInfo.ai_addr.withMemoryRebound(to: sockaddr_in6.self , capacity: 1, {
                (pointer: UnsafeMutablePointer<sockaddr_in6>) in
                return pointer.pointee
            })
            self = .IPv6(address:address, length: AddressFamily.IPv6.getSize())
            
        default:
            self = .empty
        }
    }
    
    init(from sockAddr : sockaddr) {
        switch Int32(sockAddr.sa_family) {
        case AF_INET:
            let address = withUnsafePointer(to: sockAddr, { pointer in
                pointer.withMemoryRebound(to: sockaddr_in.self, capacity: 1, { addrPointer in
                    return addrPointer.pointee
                })
            })
            self = .IPv4(address: address,length: AddressFamily.IPv4.getSize())
        case AF_INET6:
            let address = withUnsafePointer(to: sockAddr, { pointer in
                pointer.withMemoryRebound(to: sockaddr_in6.self, capacity: 1, { addrPointer in
                    return addrPointer.pointee
                })
            })
            self = .IPv6(address:address, length: AddressFamily.IPv6.getSize())
            
        default:
            self = .empty
        }
    }
    
}

extension SockAddress{
    private func getSockAddress<T>(address : T) -> sockaddr{
        return withUnsafePointer(to: address, { pointer -> sockaddr in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1, { addrPointer in
                return addrPointer.pointee
            })
        })
    }
    
    private func getMutableSockAddress<T>(address : inout T) -> sockaddr{
        return withUnsafeMutablePointer(to: &address, { pointer -> sockaddr in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1, { addrPointer in
                return addrPointer.pointee
            })
        })
    }
    
    
    func getAddress(params : (UnsafePointer<sockaddr>,socklen_t) throws -> ()) rethrows{
        switch self {
        case .IPv4(let address,let length):
            var addr = getSockAddress(address: address)
            try params(&addr,length)
            
        case .IPv6(let address,let length):
            var addr = getSockAddress(address: address)
            try params(&addr,length)
        case .empty:
            return
        }
    }
    
    func getMutableAddress(params : (UnsafeMutablePointer<sockaddr>,UnsafeMutablePointer<socklen_t>) throws -> ()) rethrows{
        switch self {
        case .IPv4(var address,var length):
            var addr = getMutableSockAddress(address: &address)
            try params(&addr,&length)
            
        case .IPv6(var address,var length):
            var addr = getMutableSockAddress(address: &address)
            try params(&addr,&length)
            
        case .empty:
            return
        }
    }
}
