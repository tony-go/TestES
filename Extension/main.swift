//
//  main.swift
//  Extension
//
//  Created by Tony Gorez on 27/05/2024.
//

import Foundation
import OSLog

func extensionMachServiceName(from bundle: Bundle) -> String {
    guard let networkExtensionKeys = bundle.object(forInfoDictionaryKey: "EndpointExtension") as? [String: Any],
          let machServiceName = networkExtensionKeys["MachServiceName"] as? String else {
        Logger.sysext.error("Mach service name is missing from the Info.plist")
        return ""
    }
    return machServiceName
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
