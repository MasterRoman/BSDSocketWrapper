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
    init(port: String) throws {
        self = try AddressInfo(host: nil, port: port).getAddressInfo(params: { addrInfo in
            return try Self.init(addrInfo: addrInfo)
        })
    }
}


extension ServerSocket{
    func listen(with backlog : Int32 = 5) throws{
        try socket.listen(with: backlog)
    }
    
    func accept<T>() throws -> T where T : BaseSocket{
        let (clientSocket,address) = try socket.accept()
        return try T(socket: clientSocket, address: address)
    }
}
