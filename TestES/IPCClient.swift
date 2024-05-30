//
//  IPCClient.swift
//  TestES
//
//  Created by Tony Gorez on 28/05/2024.
//

import Foundation
import OSLog

class IPCClient: IPCServiceProtocol {
    private let connection: NSXPCConnection
    private let service: IPCServiceProtocol
    
    init() {
        connection = NSXPCConnection(machServiceName: "tonygo.TestES-group.xpc")
        connection.remoteObjectInterface = NSXPCInterface(with:
                                                            IPCServiceProtocol.self)
        connection.resume()
        
        service = connection.remoteObjectProxyWithErrorHandler { error in
            Logger.app.error("Error during remote connection: \(error)")
        } as! IPCServiceProtocol
        
        Logger.app.debug("Connection established")
        
    }
    
    deinit {
        connection.invalidate()
    }
    
    func start () {
        Logger.app.debug("Call start")
        service.start()
    }
    
    func stop() {
        service.stop()
    }
    
}
