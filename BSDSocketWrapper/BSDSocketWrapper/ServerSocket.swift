//
//  ServerSocket.swift
//  BSDSocketWrapper
//
//  Created by Admin on 05.05.2021.
//

import Foundation

protocol ServerSocket : BaseSocket {
}

extension ServerSocket{
    public init(port: String, sockType: SockType) throws {
        self = try AddressInfo(host: nil, port: port, sockType: sockType).getAddressInfo(params: { addrInfo in
            return try Self.init(addrInfo: addrInfo)
        })
    }
}


extension ServerSocket{
    public func listen(with backlog : Int32 = 5) throws{
        try socket.listen(with: backlog)
    }
    
    public func accept<T>() throws -> T where T : BaseSocket{
        let (clientSocket,address) = try socket.accept()
        return try T(socket: clientSocket, address: address)
    }
}

open class ServerEndpoint : ServerSocket{
    required public init(socket: Socket, address: SockAddress) throws {
        self.socket = socket
        self.address = address
    }
    
    var socket: Socket
    
    var address: SockAddress
}


