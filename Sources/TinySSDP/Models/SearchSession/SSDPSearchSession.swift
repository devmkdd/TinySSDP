//
//  SSDPSearchSession.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 27.09.20.
//

import Foundation



public protocol SSDPSearchSession {
    
    var delegate: SSDPSearchSessionDelegate? { get set }
    
    func startSearch()
    func stopSearch()
}
