//
//  ConnectionsView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 29.01.2025.
//

import SwiftUI
import HealthKit

struct ConnectionsView: View {
    @StateObject var healthKitManager = HealthKitManager()
    @EnvironmentObject var config: Config
    private let healthStore = HKHealthStore()
    
    var body: some View {
        Form {
            Section(header: Text("Apple Health")) {
                Toggle("Enable Apple Health", isOn: $config.isHealthEnabled)
                    .onChange(of: config.isHealthEnabled) { newValue in
                        if newValue {
                            requestHealthKitAuthorization()
                        } else {
                            disableHealthKitAccess()
                        }
                    }
                
                if config.isHealthEnabled {
                    Toggle("Allow Date of Birth", isOn: $config.allowDateOfBirth)
                    Toggle("Allow Height", isOn: $config.allowHeight)
                    Toggle("Allow Weight", isOn: $config.allowWeight)
                }
            }
        }
        .navigationTitle("Connected Apps")
        .onAppear {
            if config.isHealthEnabled {
                updateHealthPermissions() // ✅ Ensure toggles sync with user settings
            }
        }
    }
    
    /// **Requests HealthKit authorization and updates UI instantly**
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
    
    /// **Syncs UI toggles with HealthKit permissions**
    private func updateHealthPermissions() {
        let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        let heightType = HKObjectType.quantityType(forIdentifier: .height)!
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        
        DispatchQueue.global(qos: .userInitiated).async {
            let dateOfBirthStatus = self.healthStore.authorizationStatus(for: dateOfBirthType)
            let heightStatus = self.healthStore.authorizationStatus(for: heightType)
            let weightStatus = self.healthStore.authorizationStatus(for: weightType)
            
            DispatchQueue.main.async {
                config.allowDateOfBirth = (dateOfBirthStatus == .sharingAuthorized)
                config.allowHeight = (heightStatus == .sharingAuthorized)
                config.allowWeight = (weightStatus == .sharingAuthorized)
            }
        }
    }
    
    /// **Resets permissions when HealthKit is disabled**
    private func disableHealthKitAccess() {
        config.allowDateOfBirth = false
        config.allowHeight = false
        config.allowWeight = false
    }
}
