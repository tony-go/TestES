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
    var connectionEstablished: (() -> Void)
    
    init(statusManager: InstallerStatusManager, connectionEstablished: @escaping () -> Void) {
        self.statusManager = statusManager
        self.connectionEstablished = connectionEstablished
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
//        let oneSecond = DispatchTime.now() + DispatchTimeInterval.seconds(1)
//        DispatchQueue.main.asyncAfter(deadline: oneSecond, execute: {
            self.connectionEstablished()
//        })
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        Logger.installer.debug("SystemExtensionInstaller - didFailWithError: \(error.localizedDescription)");
        statusManager.status = .failed(error.localizedDescription)
    }
}

struct ContentView: View {
    @StateObject private var statusManager = InstallerStatusManager()
    @State private var inst: SystemExtensionInstaller?
    @State private var ipcClient: IPCClient?
    
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
            
            Button(action: startIPC) {
                Text("Start IPC")
                    .padding()
                    .foregroundColor(.white)
                    .background(.orange)
                    .cornerRadius(10)
            }.buttonStyle(.plain)

            Button(action: ping) {
                Text("Ping")
                    .padding()
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(10)
            }.buttonStyle(.plain)
                .disabled(ipcClient == nil)
            
        }
        .onAppear {
            if inst == nil {
                inst = SystemExtensionInstaller(statusManager: statusManager, connectionEstablished: {
                    
                })
            }
        }
    }
    
    private func startIPC() {
        Logger.app.debug("Establishing IPC Client")
        ipcClient = IPCClient()
    }
    
    private func ping() {
        guard let ipc = ipcClient else {
            Logger.app.error("Imposible to start es client, ipc client is not ready")
            return
        }
        
        ipc.ping()
    }
    
    private func installExtension() {
        Logger.app.debug("SystemExtensionInstaller - Install extension...")
        
        let networkExtensionIdentifier = "com.tonygo.TestES.Extension"
        let request = OSSystemExtensionRequest.activationRequest(
            forExtensionWithIdentifier: networkExtensionIdentifier,
            queue: DispatchQueue.main
        )
        request.delegate = inst
        OSSystemExtensionManager.shared.submitRequest(request)
        statusManager.status = .await
    }
}
