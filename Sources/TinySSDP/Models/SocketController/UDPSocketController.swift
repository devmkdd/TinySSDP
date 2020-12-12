//
//  UDPSocketController.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 26.09.20.
//

import Foundation


protocol UDPSocketController: class {
    
    var delegate: UDPSocketControllerDelegate? { get set }
    
    var state: UDPSocketControllerState { get }

        func write(message: String)
        func close()
    
}
