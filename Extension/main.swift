//
//  main.swift
//  Extension
//
//  Created by Tony Gorez on 27/05/2024.
//

import Foundation
import EndpointSecurity
import OSLog

extension Logger {
    static let sysext = Logger(subsystem: "tonygo.TestES", category: "sysext")
}

var client: OpaquePointer?

// Create the client
let res = es_new_client(&client) { (client, message) in
    // Do processing on the message received
}

if res != ES_NEW_CLIENT_RESULT_SUCCESS {
    exit(EXIT_FAILURE)
}

Logger.sysext.error("HELL YEAH!")

dispatchMain()
