//
//  SSDPSearchSessionDelegate.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 20.10.20.
//

import Foundation


public enum SSDPSearchSessionError: Error {
    case searchAborted(Error)
}


public protocol SSDPSearchSessionDelegate: class {
    func searchSession(_ searchSession: SSDPSearchSession, didFindService service: SSDPService)
    func searchSession(_ searchSession: SSDPSearchSession, didEncounterError error: SSDPSearchSessionError)
    func searchSessionDidStopSearch(_ searchSession: SSDPSearchSession, foundServices: [SSDPService])
}
