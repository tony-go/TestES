//
//  IPC.swift
//  Extension
//
//  Created by Tony Gorez on 28/05/2024.
//

import Foundation
import OSLog

class IPCDelegate: NSObject, NSXPCListenerDelegate, IPCServiceProtocol {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        Logger.sysext.debug("Incoming connection")
        newConnection.exportedInterface = NSXPCInterface(with: IPCServiceProtocol.self)
        newConnection.exportedObject = self
        
        newConnection.resume()
        Logger.sysext.debug("Connection resumed")
       
        return true
    }
    
    @objc func ping() -> Void {
        Logger.sysext.info("Pong")
    }
}
