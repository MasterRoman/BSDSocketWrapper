//
//  ServerSocket.swift
//  BSDSocketWrapper
//
//  Created by Admin on 05.05.2021.
//

import Foundation

public protocol ServerSocket : BaseSocket {
}

public extension ServerSocket{
    init(port: String, sockType: SockType) throws {
        self = try AddressInfo(host: nil, port: port, sockType: sockType).getAddressInfo(params: { addrInfo in
            return try Self.init(addrInfo: addrInfo)
        })
    }
}


public extension ServerSocket{
    func listen(with backlog : Int32 = 5) throws{
        try socket.listen(with: backlog)
    }
    
    func accept<T>() throws -> T where T : BaseSocket{
        let (clientSocket,address) = try socket.accept()
        return try T(socket: clientSocket, address: address)
    }
}

open class ServerEndpoint : ServerSocket{
    
    required public init(socket: Socket, address: SockAddress) throws {
        self.socket = socket
        self.address = address
    }
    
    public var socket: Socket
    
    public var address: SockAddress
}


