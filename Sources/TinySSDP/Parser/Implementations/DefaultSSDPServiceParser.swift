//
//  DefaultSSDPServiceParser.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 01.10.20.
//

import Foundation
import os



private enum SSDPServiceResponseKey: String {
    case cacheControl = "CACHE-CONTROL"
    case location = "LOCATION"
    case server = "SERVER"
    case searchTarget = "ST"
    case uniqueServiceName = "USN"
}


class DefaultSSDPServiceParser: SSDPServiceParser {
    
    private let dateFactory: DateFactory
    
    // Init
    
    init(dateFactory: DateFactory =  CurrentDateFactory()) {
        self.dateFactory = dateFactory
    }
    
    // MARK: - Parse
    
    func parse(_ data: Data) -> SSDPService? {
        guard let responseString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        //os_log(.info, "Received SSDP response: \r%{public}@", responseString)
        
        // Splitting the string into a dictionary using \r\n to determine fields and : to determine key and value pairs.
        var responseDict = parseResponseIntoDictionary(responseString)
        
        // The response dictionary is checked to ensure that all mandatory fields are present. If any of the mandatory fields are missing, the SSDP response is considered invalid, and nil is returned.
        guard let cacheControl = parseCacheControl(responseDict[SSDPServiceResponseKey.cacheControl.rawValue]),
              let location = parseLocation(responseDict[SSDPServiceResponseKey.location.rawValue]),
              let server = responseDict[SSDPServiceResponseKey.server.rawValue],
              let searchTarget = responseDict[SSDPServiceResponseKey.searchTarget.rawValue],
              let uniqueServiceName = responseDict[SSDPServiceResponseKey.uniqueServiceName.rawValue] else {
            return nil
        }
        
        // As an SSDP response can contain non-mandatory fields, the mandatory fields are stripped from the response dictionary so leaving the only the non-mandatory fields present.
        responseDict.removeValue(forKey: SSDPServiceResponseKey.cacheControl.rawValue)
        responseDict.removeValue(forKey: SSDPServiceResponseKey.location.rawValue)
        responseDict.removeValue(forKey: SSDPServiceResponseKey.server.rawValue)
        responseDict.removeValue(forKey: SSDPServiceResponseKey.searchTarget.rawValue)
        responseDict.removeValue(forKey: SSDPServiceResponseKey.uniqueServiceName.rawValue)
        
        // An SSDPService is created using the mandatory and non-mandatory fields.
        return SSDPService(cacheControl: cacheControl, location: location, server: server, searchTarget: searchTarget, uniqueServiceName: uniqueServiceName, otherHeaders: responseDict)
    }
    
    private func parseResponseIntoDictionary(_ response: String) -> [String: String] {
        var elements = [String: String]()
        for element in response.split(separator: "\r\n") {
            let keyValuePair = element.split(separator: ":", maxSplits: 1)
            guard keyValuePair.count == 2 else {
                continue
            }
            
            let key = String(keyValuePair[0]).uppercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let value = String(keyValuePair[1]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            elements[key] = value
        }
        
        return elements
    }
    
    private func parseCacheControl(_ value: String?) -> Date? {
        guard let cacheControlRange = value?.range(of: "[0-9]+$", options: .regularExpression),
              let cacheControlString = value?[cacheControlRange],
              let cacheControlTimeInterval = TimeInterval(cacheControlString) else {
            return nil
        }
        
        let currentDate = dateFactory.currentDate()
        return currentDate.addingTimeInterval(cacheControlTimeInterval)
    }
    
    private func parseLocation(_ value: String?) -> URL? {
        guard let urlString = value,
              let url = URL(string: urlString) else {
            return nil
        }
        
        return url
    }
}

