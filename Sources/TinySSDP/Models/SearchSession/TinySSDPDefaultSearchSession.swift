//
//  DefaultSearchSession.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 27.09.20.
//

import Foundation
import os


class TinySSDPDefaultSearchSession {
   
    private let socketController: UDPSocketController
    private let configuration: SSDPSearchSessionConfiguration
    private let parser: SSDPServiceParser
    
    // contains all valid services that have been received during that search session.
    private var servicesFoundDuringSearch = [SSDPService]()
    
    weak var delegate: SSDPSearchSessionDelegate?
    
    
    private let searchTimeout: TimeInterval
    private var timeoutTimer: Timer?
    private var searchRequestTimer: Timer?
    
    private lazy var mSearchMessage = {
            // Each line must end in `\r\n`
            return "M-SEARCH * HTTP/1.1\r\n" +
                "HOST: \(configuration.host):\(configuration.port)\r\n" +
                "MAN: \"ssdp:discover\"\r\n" +
                "ST: \(configuration.searchTarget.rawValue)\r\n" +
                "MX: \(Int(configuration.maximumWaitResponseTime))\r\n" +
            "\r\n" // the M-Search message as the \r\n sequence is part of the protocol spec.
        }()
    
    
    
        init?(configuration: SSDPSearchSessionConfiguration,
              socketControllerFactory: SocketControllerFactory = DefaultSocketControllerFactory(),
              parser: SSDPServiceParser = DefaultSSDPServiceParser()) {
           
            guard let socketController = socketControllerFactory.createUDPSocketController(host: configuration.host,
                                                                                           port: configuration.port,
                                                                                           socketFactory: BlueSocketFactory(),
                                                                                           callbackQueue: .main) else {
                return nil
            }
            
            self.socketController = socketController
            self.configuration = configuration
            self.parser = parser
            
            // Every M-Search message contains an MX value that represents the maximum time a service can wait before responding. When this time has elapsed, it can be confidently assumed that all services that can respond, have responded. Meaning that MX can be used as a timeout for the search session:
            self.searchTimeout = (TimeInterval(configuration.maximumSearchRequestsBeforeClosing) * configuration.maximumWaitResponseTime) + 0.1
            self.socketController.delegate = self
        }

        deinit {
            stopSearch()
        }
    
    
}


// MARK: - SSDPSearchSession
extension TinySSDPDefaultSearchSession: SSDPSearchSession {
    
    func startSearch() {
        
        
        guard configuration.maximumSearchRequestsBeforeClosing > 0 else {
//            os_log(.info, "maximumSearchRequestsBeforeClosing is set to 0 -> no request will be started")
            delegate?.searchSessionDidStopSearch(self, foundServices: servicesFoundDuringSearch)
            return
        }
        
//        os_log(.info, "SSDP search session starting")
        
        sendMSearchMessages()
        
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: searchTimeout,
                                            repeats: false,
                                            block: { [weak self] (timer) in
                    self?.searchTimedOut()
                })
    }
    
   
    
    //  once stopSearch() is called and the socket closed, a new instance of SSDPSearchSession is needed to perform another search.
    func stopSearch() {
//        os_log(.info, "SSDP search session stopping")
        close()
        
        delegate?.searchSessionDidStopSearch(self, foundServices:servicesFoundDuringSearch)
    }
    
}


fileprivate extension TinySSDPDefaultSearchSession {
    
    
    private func sendMSearchMessages() {
        let message = mSearchMessage
        
        // 4
        if configuration.maximumSearchRequestsBeforeClosing > 1 {
            let window = searchTimeout - configuration.maximumWaitResponseTime
            let interval = window / TimeInterval((configuration.maximumSearchRequestsBeforeClosing - 1))
            
            searchRequestTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] (timer) in
                self?.socketController.write(message: message)
            })
        }
        writeMessageToSocket(message)
    }
    
    private func searchTimedOut() {
//        os_log(.info, "SSDP search timed out")
        stopSearch()
    }
    
    private func close() {
        
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        
        searchRequestTimer?.invalidate()
        searchRequestTimer = nil
        
        if socketController.state.isActive {
            socketController.close()
        }
    }
    
    // MARK: - Write
    
    private func writeMessageToSocket(_ message: String) {
//        os_log(.info, "Writing to socket: \r%{public}@", message)
        socketController.write(message: message)
    }
    
    private func searchedForService(_ service: SSDPService) -> Bool {
        return service.searchTarget == configuration.searchTarget.rawValue ||
            configuration.searchTarget.rawValue == SSDPSearchTarget.all.rawValue
     }
}

// MARK: - UDPSocketControllerDelegate
extension TinySSDPDefaultSearchSession: UDPSocketControllerDelegate {
   
    
    func controller(_ controller: UDPSocketController, didReceiveResponse response: Data) {
        //os_log(.info, "Received response: \r%{public}@", response as CVarArg)
        
        guard !response.isEmpty,
              let service = parser.parse(response),
              searchedForService(service), // Once you start parsing responses, you will notice that some root devices respond to any M-Search message they receive rather than just those discovery requests that match one of their services. To counter these chatty root devices we need to ensure that the parsed SSDPService instance is the searched-for-service:
              !servicesFoundDuringSearch.contains(service) else {
                                
            return
        }
        
        //os_log(.info, "Received service \(service.debugDescription)")
        
        servicesFoundDuringSearch.append(service)
        delegate?.searchSession(self, didFindService: service)
        
    }
    
    func controller(_ controller: UDPSocketController, didEncounterError error: Error) {
//        os_log(.info, "Encountered socket error: \r%{public}@", error.localizedDescription)
        
        let wrappedError = SSDPSearchSessionError.searchAborted(error)
        delegate?.searchSession(self, didEncounterError: wrappedError)
        close()
    }
    
    
}


