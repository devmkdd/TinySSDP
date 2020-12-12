//
//  File.swift
//  
//
//  Created by Michael Kuhardt on 20.11.20.
//

import Foundation



public protocol SearchSessionFactory {
    
    func mediaServerSearchSession() -> SSDPSearchSession?
    
}
