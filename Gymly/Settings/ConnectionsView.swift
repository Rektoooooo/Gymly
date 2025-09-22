//
//  ConnectionsView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 29.01.2025.
//

import SwiftUI
import HealthKit
import CloudKit
import Foundation

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

struct ConnectionsView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @StateObject var healthKitManager = HealthKitManager()
    @StateObject var cloudKitManager = CloudKitManager.shared
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var config: Config
    @Environment(\.colorScheme) var scheme
    @State private var isCloudKitAvailable = false
    private let healthStore = HKHealthStore()

    var body: some View {
        ZStack {
            FloatingClouds(theme: CloudsTheme.graphite(scheme))
                .ignoresSafeArea()
            Form {
            Section(header: Text("Apple Health")) {
                Toggle("Enable Apple Health", isOn: Binding(
                    get: { config.isHealtKitEnabled },
                    set: { newValue in
                        if newValue {
                            // User wants to enable HealthKit - request authorization first
                            requestHealthKitAuthorization()
                        }
                    }
                ))

                Text("To fully revoke permissions, disable HealthKit access in Settings > Privacy & Security > Health > Gymly")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

            }
            .listRowBackground(Color.black.opacity(0.05))

            Section(header: Text("iCloud Sync")) {
                Toggle("Enable iCloud Sync", isOn: Binding(
                    get: { config.isCloudKitEnabled },
                    set: { newValue in
                        Task {
                            if newValue && isCloudKitAvailable {
                                cloudKitManager.setCloudKitEnabled(true)
                                config.isCloudKitEnabled = true
                                viewModel.performFullCloudKitSync()
                            } else if !newValue {
                                cloudKitManager.setCloudKitEnabled(false)
                                config.isCloudKitEnabled = false
                            } else {
                                // CloudKit not available but user wants to enable it
                                print("❌ CloudKit not available, cannot enable sync")
                            }
                        }
                    }
                ))
                    .disabled(!isCloudKitAvailable)

                if cloudKitManager.isSyncing {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Syncing...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if let error = cloudKitManager.syncError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                }

                if let lastSync = cloudKitManager.lastSyncDate {
                    Text("Last synced: \(lastSync, formatter: DateFormatter.shortDateTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if config.isCloudKitEnabled && cloudKitManager.isCloudKitEnabled {
                    Button("Sync Now") {
                        viewModel.performFullCloudKitSync()
                    }
                    .disabled(cloudKitManager.isSyncing)
                }

                Text("Sync your splits, workout history, and settings across all your devices. Requires iCloud to be enabled.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .listRowBackground(Color.black.opacity(0.05))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("Connected Apps")
        .task {
            await cloudKitManager.checkCloudKitStatus()
            isCloudKitAvailable = await cloudKitManager.isCloudKitAvailable()
            // Sync the config state with CloudKit manager state
            if cloudKitManager.isCloudKitEnabled && !config.isCloudKitEnabled {
                config.isCloudKitEnabled = true
            }
        }
    }
    
    
    /// Requests HealthKit authorization and updates UI instantly
    private func requestHealthKitAuthorization() {
        let healthDataToRead: Set = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: healthDataToRead) { success, error in
            DispatchQueue.main.async {

                    config.isHealtKitEnabled = true
                    print("🩺 HEALTH: Authorization result - permissions granted")

            }
        }
    }


    /// Check if HealthKit permissions are granted
    private func checkHealthKitPermissions() -> Bool {
        let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        let heightType = HKObjectType.quantityType(forIdentifier: .height)!
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!

        let dateOfBirthStatus = healthStore.authorizationStatus(for: dateOfBirthType)
        let heightStatus = healthStore.authorizationStatus(for: heightType)
        let weightStatus = healthStore.authorizationStatus(for: weightType)

        // Return true if at least one permission is granted
        return dateOfBirthStatus == .sharingAuthorized ||
               heightStatus == .sharingAuthorized ||
               weightStatus == .sharingAuthorized
    }

}
