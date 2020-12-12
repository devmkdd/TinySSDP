//
//  SSDPService.swift
//  TinySSDP
//
//  Created by Michael Kuhardt on 01.10.20.
//

import Foundation


/// This struct describes the structure of a device promoted by ssdp
public struct SSDPService {
    public let cacheControl: Date
    public let location: URL
    public let server: String
    public let searchTarget: String
    public let uniqueServiceName: String
    public let otherHeaders: [String: String]
    
    
    
    public init(cacheControl: Date,
                location: URL,
                server: String,
                searchTarget: String,
                uniqueServiceName: String,
                otherHeaders: [String: String] = [String: String]()) {
        
        self.cacheControl = cacheControl
        self.location = location
        self.server = server
        self.searchTarget = searchTarget
        self.uniqueServiceName = uniqueServiceName
        self.otherHeaders = otherHeaders
        
    }
}


// MARK: - Equatable
extension SSDPService: Equatable {
    
    public static func == (lhs: SSDPService, rhs: SSDPService) -> Bool {
        return lhs.location == rhs.location &&
            lhs.server == rhs.server &&
            lhs.searchTarget == rhs.searchTarget &&
            lhs.uniqueServiceName == rhs.uniqueServiceName
    }
    
}


// MARK: - CustomDebugStringConvertible
extension SSDPService: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\nSSDPService:\n cacheControl=\(cacheControl),\n location=\(location),\n  server=\(server), searchTarger=\(searchTarget),\n uniqueServiceName=\(uniqueServiceName),\n otherHeaders=\(otherHeaders)\n\n"
    }
    
    
}
