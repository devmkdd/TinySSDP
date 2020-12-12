//
//  SocketFactory.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 26.09.20.
//

import Foundation


protocol SocketFactory {
    func createUDPSocket() -> UDPSocket?
}
