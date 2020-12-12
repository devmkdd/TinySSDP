//
//  Socket+UDP.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 26.09.20.
//

import Foundation
import Socket


extension Socket {
    
    static func createUDPSocket() throws -> UDPSocket {
        return try Socket.create(type: .datagram, proto: .udp)
    }
}
