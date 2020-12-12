//
//  UDPSocketControllerDelegate.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 30.09.20.
//

import Foundation


protocol UDPSocketControllerDelegate: class {
    
    func controller(_ controller: UDPSocketController, didReceiveResponse response: Data)
        
    func controller(_ controller: UDPSocketController, didEncounterError error: Error)
    
}
