//
//  IPC.swift
//  Extension
//
//  Created by Tony Gorez on 28/05/2024.
//

import Foundation
import EndpointSecurity
import OSLog


@objc class IPCService: NSObject, IPCServiceProtocol {
    var client: OpaquePointer?
    
    @objc func start() -> Void {
        Logger.sysext.debug("Starting ES client")
        let res = es_new_client(&client) { (client, message) in
            // Do processing on the message received
        }
        
        if res != ES_NEW_CLIENT_RESULT_SUCCESS {
            Logger.sysext.error("Did not succeed to open ES client")
            exit(EXIT_FAILURE)
        }
        
        Logger.sysext.info("HELL YEAH!")
    }
    
    @objc func stop() -> Void {
        client = nil
        
        Logger.sysext.info("Client stoped!")
    }
}

class IPCDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        Logger.sysext.debug("Incoming connection")
        newConnection.exportedInterface = NSXPCInterface(with: IPCServiceProtocol.self)
        
        let ipcService = IPCService()
        newConnection.exportedObject = ipcService
        
        newConnection.resume()
        Logger.sysext.debug("Connection resumed")
       
        return true
    }
}
