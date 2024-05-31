//
//  Logger.swift
//  TestES
//
//  Created by Tony Gorez on 28/05/2024.
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = "com.tonygo.TestES"
    
    static let installer = Logger(subsystem: subsystem, category: "installer")
    static let app = Logger(subsystem: subsystem, category: "app")
    static let sysext = Logger(subsystem: subsystem, category: "sysext")
}
