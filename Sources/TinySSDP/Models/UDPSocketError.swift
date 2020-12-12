//
//  UDPSocketError.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 26.09.20.
//

import Foundation


enum UDPSocketError: Error {
    case addressCreationFailure
    case writeError(underlayingError: Error)
    case readError(underlayingError: Error)
}
