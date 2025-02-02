//
//  ConnectionsView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 29.01.2025.
//

import SwiftUI

struct ConnectionsView: View {
    @StateObject var healthKitManager = HealthKitManager()
    @AppStorage("isHealthEnabled") private var isHealthEnabled = true
    @AppStorage("syncWorkouts") private var syncWorkouts = false
    @AppStorage("syncActiveEnergy") private var syncActiveEnergy = false
    @AppStorage("divideByHours") private var divideByHours = false
    @AppStorage("syncBodyMass") private var syncBodyMass = true
    @AppStorage("syncNutritionalData") private var syncNutritionalData = true
    @AppStorage("syncHydration") private var syncHydration = true
    @AppStorage("syncGarmin") private var syncGarmin = false
    var body: some View {
        Form {
            Section(header: Text("Apple Health")) {
                Toggle("Enable Apple Health", isOn: $isHealthEnabled)
                if isHealthEnabled {
                    Toggle("Sync workouts", isOn: $syncWorkouts)
                    Toggle("Sync active energy", isOn: $syncActiveEnergy)
                    if syncActiveEnergy {
                        Toggle("Divide by hours", isOn: $divideByHours)
                    }
                    Toggle("Sync body mass", isOn: $syncBodyMass)
                    Toggle("Sync nutritional data", isOn: $syncNutritionalData)
                    Toggle("Sync hydration", isOn: $syncHydration)
                }
            }
            Button("Request HealthKit Access") {
                healthKitManager.requestAuthorization()
            }
        }
        .navigationTitle("Connected Apps")
    }
}

#Preview {
    ConnectionsView()
}



