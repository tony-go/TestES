//
//  IPC.swift
//  Extension
//
//  Created by Tony Gorez on 28/05/2024.
//

import Foundation
import OSLog

@objc class IPCService: NSObject, IPCServiceProtocol {
    @objc func ping() -> Void {
        Logger.sysext.info("Pong")
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
