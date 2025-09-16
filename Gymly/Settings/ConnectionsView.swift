//
//  ConnectionsView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 29.01.2025.
//

import SwiftUI
import HealthKit

struct ConnectionsView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @StateObject var healthKitManager = HealthKitManager()
    @EnvironmentObject var config: Config
    @Environment(\.colorScheme) var scheme
    private let healthStore = HKHealthStore()

    var body: some View {
        ZStack {
            FloatingClouds(theme: CloudsTheme.graphite(scheme))
                .ignoresSafeArea()
            Form {
            Section(header: Text("Apple Health")) {
                Toggle("Enable Apple Health", isOn: $config.isHealthEnabled)
                    .onChange(of: config.isHealthEnabled) {
                        if config.isHealthEnabled {
                            requestHealthKitAuthorization()
                        } else {
                            disableHealthKitAccess()
                        }
                    }
                
                // TODO: Toggles does not sinc with the healt kit so there are doing nothing
                if config.isHealthEnabled {
                   // Toggle("Allow Date of Birth", isOn: $config.allowDateOfBirth)
                   // Toggle("Allow Height", isOn: $config.allowHeight)
                   // Toggle("Allow Weight", isOn: $config.allowWeight)
                }
            }
            .listRowBackground(Color.black.opacity(0.05))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("Connected Apps")
        .onAppear {
            if config.isHealthEnabled {
                updateHealthPermissions() // ✅ Ensure toggles sync with user settings
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
            
            DispatchQueue.main.async {
                self.config.allowDateOfBirth = (dateOfBirthStatus == .sharingAuthorized)
                self.config.allowHeight = (heightStatus == .sharingAuthorized)
                self.config.allowWeight = (weightStatus == .sharingAuthorized)
            }
        }
    }
    
    /// Resets permissions when HealthKit is disabled
    private func disableHealthKitAccess() {
        config.allowDateOfBirth = false
        config.allowHeight = false
        config.allowWeight = false
    }
}
