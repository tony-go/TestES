//
//  main.swift
//  Extension
//
//  Created by Tony Gorez on 27/05/2024.
//

import Foundation
import OSLog
import EndpointSecurity

func extensionMachServiceName(from bundle: Bundle) -> String {
    guard let machName = bundle.object(forInfoDictionaryKey: "NSEndpointSecurityMachServiceName") as? String else {
        Logger.sysext.error("Mach service name is missing from the Info.plist")
       return ""
    }
    
    return machName
}

autoreleasepool {
    var client: OpaquePointer?
    
    Logger.sysext.debug("Starting ES client")
    let res = es_new_client(&client) { (client, message) in
        // Do processing on the message received
    }
    
    if res != ES_NEW_CLIENT_RESULT_SUCCESS {
        Logger.sysext.error("Did not succeed to open ES client")
        exit(EXIT_FAILURE)
    }
    Logger.sysext.debug("ES client started!")
    
    let serviceName = extensionMachServiceName(from: Bundle.main)
    let listener = NSXPCListener(machServiceName: serviceName)
    
    Logger.sysext.debug("Resuming XPC Listener")
    
    let delegate = IPCDelegate()
    listener.delegate = delegate

    listener.resume()
    
    Logger.sysext.debug("Resumed")
}

dispatchMain()
