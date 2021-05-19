//
//  BSDSocketWrapperTests.swift
//  BSDSocketWrapperTests
//
//  Created by Admin on 30.04.2021.
//

import XCTest
@testable import BSDSocketWrapper

class S: ServerSocket{
    required init(socket: Socket, address: SockAddress) throws {
        self.socket = socket
        self.address = address
    }
    
    var socket: Socket
    
    var address: SockAddress
    
    
    
}

class C: ClientSocket{
    required init(socket: Socket, address: SockAddress) throws {
        self.socket = socket
        self.address = address
    }
    
    var socket: Socket
    
    var address: SockAddress
    
}

class BSDSocketWrapperTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        let s = try ServerEndpoint(port: "1137",sockType: .stream)
        let c = try ClientEndpoint(host: "127.0.0.1", port: "1137",sockType: .stream)
        try s.bind()
        
        
        try s.listen()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            do{
                try c.connect()
            } catch{
                
            }
            
        }
        
        let client : ServerEndpoint = try s.accept()
        
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            do{
                let data = Data("dsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasddsadasdsd1234!!!!".utf8)
                try  client.send(data: data)
               
                
            } catch{
                
            }
            
        }
        
        
        do{
            try c.receive({str in
                print( String(decoding: str, as: UTF8.self))
                
            })
            
        } catch{
            
        }
       
        
    
        
        try s.close()
        try c.close()
    
        
    }
    
}
