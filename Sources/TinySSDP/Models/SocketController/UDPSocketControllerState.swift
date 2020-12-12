//
//  UDPSocketControllerState.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 26.09.20.
//

import Foundation



enum UDPSocketControllerState {
    
    case ready
    case active
    case closed
    
    var isReady: Bool {
        self == .ready
    }
    
    var isActive: Bool {
        self == .active
    }
    
    var isClosed: Bool {
        self == .closed
    }
    
    
    
}
