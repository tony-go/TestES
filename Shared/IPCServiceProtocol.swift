//
//  IPCServiceProtocol.swift
//  TestES
//
//  Created by Tony Gorez on 28/05/2024.
//

import Foundation

@objc protocol IPCServiceProtocol {
    @objc func ping() -> Void
}
