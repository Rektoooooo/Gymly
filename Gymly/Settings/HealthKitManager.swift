//
//  HealthKitManager.swift
//  Gymly
//
//  Created by Sebastián Kučera on 28.01.2025.
//


import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()

    /// Check if HealthKit is available
    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    /// Request authorization for Height, Weight, and Date of Birth (age)
    func requestAuthorization() {
        guard isHealthKitAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)! // Needed for age
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                print("HealthKit authorization granted!")
            } else {
                print("HealthKit authorization denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    /// Fetch users height
    func fetchHeight(completion: @escaping (Double?) -> Void) {
        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            if let sample = results?.first as? HKQuantitySample {
                let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
                completion(heightInMeters)
            } else {
                completion(nil)
            }
        }
        healthStore.execute(query)
    }

    /// Fetch users weight
    func fetchWeight(completion: @escaping (Double?) -> Void) {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, _ in
            if let sample = results?.first as? HKQuantitySample {
                let weightInKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                completion(weightInKg)
            } else {
                completion(nil)
            }
        }
        healthStore.execute(query)
    }
    
    /// Fetch users age
    func fetchAge(completion: @escaping (Int?) -> Void) {
        do {
            let birthDate = try healthStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let age = calendar.dateComponents([.year], from: birthDate.date!, to: Date()).year
            completion(age)
        } catch {
            print("Error retrieving age: \(error.localizedDescription)")
            completion(nil)
        }
    }
}
