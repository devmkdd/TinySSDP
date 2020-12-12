//
//  DefaultSocketControllerFactory.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 27.09.20.
//

import Foundation



class DefaultSocketControllerFactory: SocketControllerFactory {
   
    
    func createUDPSocketController(host: String, port: UInt, socketFactory: SocketFactory, callbackQueue: OperationQueue) -> UDPSocketController? {
        
        return DefaultUDPSocketController(host:host, port: port, socketFactory: socketFactory, callbackQueue: callbackQueue)
    }
    
    
    
    
}
