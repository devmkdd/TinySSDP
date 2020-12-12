//
//  DefaultUDPSocketController.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 26.09.20.
//

import Foundation
import os


// DefaultUDPSocketController is designed to be tied to one host and port. If that host and port needs to be changed, then a new instance of DefaultUDPSocketController needs to be created.
class DefaultUDPSocketController: UDPSocketController {
    
    weak var delegate: UDPSocketControllerDelegate?
    
    private(set) var state: UDPSocketControllerState = .ready
    
    private let socket: UDPSocket
    
    private let host: String
    private let port: UInt
    
    // To make the communication via that delegate more predictable when creating that socket, the thread that the communication will happen on is passed in.
    fileprivate let callbackQueue: OperationQueue
    
    // fileprivate let callbackQueue: OperationQueue
    fileprivate let socketWriterQueue = DispatchQueue(label: "de.mkdd.udpsocket.writer.queue",
                                                      attributes: .concurrent)
    
    // Reading from a BlueSocket socket configured to read datagram messages using UDP is a blocking call - any thread that readDatagram(into:) is called on will be blocked at that line until there is data there to be read. To avoid the app from freezing, reading from the socket must be pushed off the caller queue and onto a background queue: socketWriterQueue.
    private let socketListeningQueue = DispatchQueue(label: "de.mkdd.udpsocket.listen.queue",  attributes: .concurrent)
    
    
    init?(host: String, port: UInt, socketFactory: SocketFactory, callbackQueue: OperationQueue) {
        
        guard let socket = socketFactory.createUDPSocket() else {
            os_log("no socket returned from factory")
            return nil
        }
        
        self.host = host
        self.port = port
        self.socket = socket
        self.callbackQueue = callbackQueue
    }
    
    
    // When writing to a socket, we only want to allow communication with a socket that hasn't been closed so the first action of the write(message:) is to check if state is in a closed state.
    func write(message: String) {
        
        // only  allow communication with a socket that hasn't been close
        guard !state.isClosed else {
           // os_log(.info, "Attempting to write to a closed socket")
            return
        }
        
        // We only need to configure the socket to listen once - on the first write.
        let shouldStartListening = state.isReady
        state = .active
        
        if shouldStartListening {
            startListening(on: socketListeningQueue)
        }
        
        write(message: message, on: socketWriterQueue)
        
    }
    
    
    func close() {
        state = .closed
        socket.close()
    }
    
    
}

/// Private helper
extension DefaultUDPSocketController {
    
    
    // Writing to a socket can be a time-consuming operation, so the operation is pushed onto a background queue: socketWriterQueue.
    private func write(message: String, on queue: DispatchQueue) {
        
        queue.async {
            
            // As a write operation can throw an exception, we wrap that operation in a do...catch whereupon catching an exception the socket is closed, and any error reported (we will implement this shortly).
            do {
                try self.socket.write(message, to: self.host, on: self.port)
            } catch {
                self.closeAndReportError(error)
            }
        }
    }
    
    
    
    private func startListening(on queue: DispatchQueue) {
       // os_log(.info, "startListening")
        
        // Finally,
        
        //  An interesting point to note is that closing a socket that is being polled will throw an exception. So when an exception is thrown during polling, we only care about that exception if the session is listening.
        
        queue.async {
            do {
                
                // if the state active ( and so listening for responses) the socket is polled again.
                repeat {
                    var data = Data()
                    try self.socket.readDatagram(into: &data) //blocking call
                    self.reportResponseReceived(data)
                    
                } while self.state.isActive
                
            } catch {
                
                // when catching an exception the socket is closed
                if self.state.isActive { // ignore any errors for non-active sockets
                    self.closeAndReportError(error)
                }
            }
        }
    }
    
    private func reportResponseReceived(_ data: Data) {
        //os_log(.info, "Response received: \r%{public}@", data as CVarArg)
        
        callbackQueue.addOperation {
            self.delegate?.controller(self, didReceiveResponse: data)
        }
    }
    
    
    
    private func closeAndReportError(_ error: Error) {
        close()
       // os_log(.info, "Error received: \r%{public}@", error as CVarArg)
        
        callbackQueue.addOperation {
            self.delegate?.controller(self, didEncounterError: error)
        }
    }
    
    
}
