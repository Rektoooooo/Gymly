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
                    get: { userProfileManager.currentProfile?.isHealthEnabled ?? false },
                    set: { userProfileManager.updateHealthPermissions(healthEnabled: $0) }
                ))
                    .onChange(of: userProfileManager.currentProfile?.isHealthEnabled ?? false) {
                        if userProfileManager.currentProfile?.isHealthEnabled ?? false {
                            requestHealthKitAuthorization()
                        }
                    }

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
            if userProfileManager.currentProfile?.isHealthEnabled ?? false  {
                updateHealthPermissions() // ✅ Ensure toggles sync with user settings
            }
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
                self.updateHealthPermissions() // ✅ Ensure UI updates right after auth
            }
        }
    }

    
    /// Syncs UI toggles with HealthKit permissions
    private func updateHealthPermissions() {
        let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        let heightType = HKObjectType.quantityType(forIdentifier: .height)!
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!

        DispatchQueue.global(qos: .userInitiated).async {
            let dateOfBirthStatus = self.healthStore.authorizationStatus(for: dateOfBirthType)
            let heightStatus = self.healthStore.authorizationStatus(for: heightType)
            let weightStatus = self.healthStore.authorizationStatus(for: weightType)
        }
    }


}
