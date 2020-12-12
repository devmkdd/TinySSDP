//
//  SSDPSearchParser.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 01.10.20.
//

import Foundation


protocol SSDPServiceParser {
    func parse(_ data: Data) -> SSDPService?
}
