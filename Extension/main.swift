//
//  main.swift
//  Extension
//
//  Created by Tony Gorez on 27/05/2024.
//

import Foundation
import OSLog

func extensionMachServiceName(from bundle: Bundle) -> String {
    guard let machName = bundle.object(forInfoDictionaryKey: "NSEndpointSecurityMachServiceName") as? String else {
        Logger.sysext.error("Mach service name is missing from the Info.plist")
       return ""
    }
    
    return machName
}

autoreleasepool {
    let serviceName = extensionMachServiceName(from: Bundle.main)
    let delegate = IPCDelegate()
    let listener = NSXPCListener(machServiceName: serviceName)
    
    Logger.sysext.debug("Resuming XPC Listener")
    
    listener.delegate = delegate
    listener.resume()
    
    Logger.sysext.debug("Resumed")
}

dispatchMain()
