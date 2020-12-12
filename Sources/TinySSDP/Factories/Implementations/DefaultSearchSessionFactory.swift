//
//  File.swift
//  
//
//  Created by Michael Kuhardt on 20.11.20.
//

import Foundation



public class DefaultSearchSessionFactory {
    
    public init() {}
    
}


// MARK: - SearchSessionFactory
extension DefaultSearchSessionFactory: SearchSessionFactory {
    
    public func mediaServerSearchSession() -> SSDPSearchSession? {
        
        let searchSessionConfig = SSDPSearchSessionConfiguration.createMulticastConfiguration(forSearchTarget: SSDPSearchTarget.mediaServer)
        return TinySSDPDefaultSearchSession(configuration: searchSessionConfig)
    }
    
    
}
