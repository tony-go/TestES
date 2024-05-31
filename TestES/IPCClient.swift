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
        connection = NSXPCConnection(serviceName: "tonygo.TestES.Extension")
        connection.remoteObjectInterface = NSXPCInterface(with:
                                                            IPCServiceProtocol.self)
        connection.interruptionHandler = {
            Logger.app.error("Remote process crashed or exited!")
        }
        connection.invalidationHandler = {
            Logger.app.error("Connection has not being established!")
        }
        connection.resume()
        
        service = connection.remoteObjectProxyWithErrorHandler { error in
            Logger.app.error("Error during remote connection: \(error)")
        } as! IPCServiceProtocol
        
        Logger.app.debug("Connection established")
    }
    
    deinit {
        connection.invalidate()
    }
    
    @objc func ping () {
        Logger.app.debug("Call ping")
        service.ping()
    }
}
