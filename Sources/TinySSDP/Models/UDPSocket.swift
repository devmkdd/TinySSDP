//
//  UDPSocketProtocol.swift
//  SSDPTest
//
//  Created by Michael Kuhardt on 26.09.20.
//


import Socket
import Foundation


/*
 UDPSocket reduces the range of tasks that can be performed on a Socket instance to only the three that we need: write, read and close. As well as reducing scope, UDPSocketProtocol also simplifies the interface of Socket by wrapping the Socket methods in our own methods.
 */
protocol UDPSocket {
    func write(_ string: String, to host: String, on port: UInt) throws
    func readDatagram(into data: inout Data) throws
    func close()
}



extension Socket: UDPSocket {
    
    
    func write(_ message: String, to host: String, on port: UInt) throws {
        
        
        /*
         we only want sockets configured that using UDP to send datagram message
         -> check determine if this Socket instance has been configured for UDP and datagram
         -> if it hasn't then a fatal error is thrown as this is a developer error.
         */
        guard let signature = self.signature,
              signature.socketType == .datagram,
              signature.proto == .udp else {
            fatalError("Only UDP sockets can use this method")
        }
        
        // create an Address instance out of parameters host and port for use with the socket
        guard let address = Socket.createAddress(for: host, on: Int32(port)) else {
            throw(UDPSocketError.addressCreationFailure)
        }
        
        // try to write the message
        do {
            try write(from: message, to: address)
        } catch {
            throw(UDPSocketError.writeError(underlayingError: error))
        }
    }
    
    func readDatagram(into data: inout Data) throws {
        
        // ensure that we are dealing with a socket configured to UDP and datagram
        guard let signature = self.signature,
              signature.socketType == .datagram,
              signature.proto == .udp else {
            fatalError("Only UDP sockets can use this method")
        }
        
        do {
            // The readDatagram(into:) method on Socket returns the number of bytes read as an Int and the address that sent those bytes as an Address. We aren't interested in either of those return values, so the readDatagram(into:) defined in SocketProtocol doesn't have a return type - our readDatagram(into:) just eats those details. If so some reason when reading from the socket an exception is thrown, this exception is caught, wrapped inside an UDPSocketError case before a new exception is thrown.
            let (_,_) = try readDatagram(into: &data)
            
        } catch {
            throw(UDPSocketError.readError(underlayingError: error))
        }
    }
    
    
}
