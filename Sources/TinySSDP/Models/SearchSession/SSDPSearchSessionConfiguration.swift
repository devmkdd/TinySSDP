//
//  SSDPSearchSessionConfiguration.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 27.09.20.
//

import Foundation



enum SSDPSearchTarget: String {
    case all = "ssdp:all"
    case mediaServer = "urn:schemas-upnp-org:device:MediaServer:1"
    case mediaRenderer = "urn:schemas-upnp-org:device:MediaRenderer:1"
    case contentDirectory = "urn:schemas-upnp-org:service:ContentDirectory:1"
}

/**
 3 pieces of information are required to send an M-Search message:

 Search target (ST).
 The IP address and port (HOST).
 Maximum wait response time (MX).
 */

struct SSDPSearchSessionConfiguration {
    
    let searchTarget: SSDPSearchTarget // Setting searchTarget to ssdp:all should cause all root devices to respond with their full range of SSDP services.
    let host: String
    let port: UInt
    let maximumWaitResponseTime: TimeInterval
    
    //  used to control how many M-Search messages are sent before the search session is closed. 
    let maximumSearchRequestsBeforeClosing: UInt
    
    
    
    init(searchTarget: SSDPSearchTarget,
         host: String,
         port: UInt,
         maximumWaitResponseTime: TimeInterval,
         maximumSearchRequestsBeforeClosing: UInt) {
        
        assert(maximumWaitResponseTime >= 1
                && maximumWaitResponseTime <= 5,
               "maximumWaitResponseTime should be between 1 and 5 (inclusive)")
        
        self.searchTarget = searchTarget
        self.host = host
        self.port = port
        self.maximumWaitResponseTime = maximumWaitResponseTime
        self.maximumSearchRequestsBeforeClosing = maximumSearchRequestsBeforeClosing
    }
}


extension SSDPSearchSessionConfiguration {

    // small factory method to return a preconfigured multicast SSDPSearchSessionConfiguration instance
    static func createMulticastConfiguration(forSearchTarget searchTarget: SSDPSearchTarget, maximumWaitResponseTime: TimeInterval = 3, maximumSearchRequestsBeforeClosing: UInt = 3) -> SSDPSearchSessionConfiguration {
        
        let configuration = SSDPSearchSessionConfiguration(searchTarget: searchTarget,
                                                           host: "239.255.255.250",
                                                           port: 1900,
                                                           maximumWaitResponseTime: maximumWaitResponseTime,
                                                           maximumSearchRequestsBeforeClosing: maximumSearchRequestsBeforeClosing)

        return configuration
    }
}
