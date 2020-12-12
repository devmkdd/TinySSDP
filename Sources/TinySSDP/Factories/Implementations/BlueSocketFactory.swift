//
//  BlueSocketFactory.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 26.09.20.
//

import Foundation
import Socket



class BlueSocketFactory: SocketFactory {
    
    
    func createUDPSocket() -> UDPSocket? {
        guard let socket = try? Socket.createUDPSocket() else {
            return nil
        }
        
        return socket
    }
    
    
}
