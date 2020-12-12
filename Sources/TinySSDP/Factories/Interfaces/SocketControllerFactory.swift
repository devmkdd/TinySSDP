//
//  SocketControllerFactory.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 27.09.20.
//

import Foundation


protocol SocketControllerFactory {
    
    func createUDPSocketController(host: String, port: UInt, socketFactory: SocketFactory, callbackQueue: OperationQueue) -> UDPSocketController?
    
}
