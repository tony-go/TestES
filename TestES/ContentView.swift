//
//  ContentView.swift
//  TestES
//
//  Created by Tony Gorez on 27/05/2024.
//


import SwiftUI
import CoreData
import SystemExtensions
import OSLog

extension Logger {
    private static var subsystem = "tonygo.TestES"

    static let installer = Logger(subsystem: subsystem, category: "installer")
    static let app = Logger(subsystem: subsystem, category: "app")
}

enum InstallerStatus {
    case empty
    case await
    case needApproval
    case replace
    case failed(String)
    case succeed
}


class InstallerStatusManager: ObservableObject {
    @Published var status: InstallerStatus = .empty
}

class SystemExtensionInstaller: NSObject, OSSystemExtensionRequestDelegate {
    @ObservedObject var statusManager: InstallerStatusManager
    
    init(statusManager: InstallerStatusManager) {
        self.statusManager = statusManager
        super.init()
    }
    
    func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        Logger.installer.debug("SystemExtensionInstaller - request actionForReplacingExtension");
        statusManager.status = .replace
        return .replace
    }
    
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        Logger.installer.debug("SystemExtensionInstaller- requestNeedsUserApproval")
        statusManager.status = .needApproval
    }
    
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        Logger.installer.debug("SystemExtensionInstaller - didFinishWithResult: \(result.rawValue)");
        statusManager.status = .succeed
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        Logger.installer.debug("SystemExtensionInstaller - didFailWithError: \(error.localizedDescription)");
        statusManager.status = .failed(error.localizedDescription)
    }
}

struct ContentView: View {
    @StateObject private var statusManager = InstallerStatusManager()
    @State private var inst: SystemExtensionInstaller?
    
    var body: some View {
        VStack {
            switch statusManager.status {
            case .empty:
                Text("Status:")
                    .foregroundColor(.gray)
            case .await:
                Text("Status: Awaiting")
                    .foregroundColor(.blue)
                ProgressView()
            case .needApproval:
                Text("Status: Need Approval")
                    .foregroundColor(.orange)
            case .replace:
                Text("Status: Replace")
                    .foregroundColor(.purple)
            case .failed(let message):
                VStack {
                    Text("Status: Failed")
                        .foregroundColor(.red)
                    Text("Error: \(message)")
                        .foregroundColor(.red)
                }
            case .succeed:
                Text("Status: Succeed")
                    .foregroundColor(.green)
            }
            Button(action: installExtension) {
                Text("Install")
                    .padding()
                    .foregroundColor(.white)
                    .background(.green)
                    .cornerRadius(10)
            }.buttonStyle(.plain)
        }
        .onAppear {
            if inst == nil {
                inst = SystemExtensionInstaller(statusManager: statusManager)
            }
        }
    }
    
    private func installExtension() {
        Logger.app.debug("SystemExtensionInstaller - Install extension...")
        
        let networkExtensionIdentifier = "tonygo.TestES.Extension"
        let request = OSSystemExtensionRequest.activationRequest(
            forExtensionWithIdentifier: networkExtensionIdentifier,
            queue: DispatchQueue.main
        )
        request.delegate = inst
        OSSystemExtensionManager.shared.submitRequest(request)
        statusManager.status = .await
    }
}
