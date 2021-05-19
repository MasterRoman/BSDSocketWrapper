//
//  ClientSocket.swift
//  BSDSocketWrapper
//
//  Created by Admin on 06.05.2021.
//

import Foundation

protocol ClientSocket : BaseSocket {
}

extension ClientSocket{
    init(host:String,port: String, sockType: SockType) throws {
        self = try AddressInfo(host: host, port: port, sockType: sockType).getAddressInfo(params: { addrInfo in
            return try Self.init(addrInfo: addrInfo)
        })
    }
}

extension ClientSocket{
    public func connect() throws{
        try address.getAddress(params: { sockAddr,length in
            try socket.connect(to: sockAddr, sockLength: length)
        })
    }
}

open class ClientEndpoint : ClientSocket{
    required public init(socket: Socket, address: SockAddress) throws {
        self.socket = socket
        self.address = address
    }
    
    var socket: Socket
    
    var address: SockAddress
}
