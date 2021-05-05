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
    init(host:String,port: String) throws {
        self = try AddressInfo(host: host, port: port).getAddressInfo(params: { addrInfo in
            return try Self.init(addrInfo: addrInfo)
        })
    }
}

extension ClientSocket{
    func connect() throws{
        try address.getAddress(params: { sockAddr,length in
            try socket.connect(to: sockAddr, sockLength: length)
        })
    }
}
