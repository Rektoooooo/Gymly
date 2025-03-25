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

    func saveHeight(_ heightMeters: Double, date: Date = Date()) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .height) else { return }
        let quantity = HKQuantity(unit: .meter(), doubleValue: heightMeters)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)

        healthStore.save(sample) { success, error in
            if success {
                print("✅ Height saved to HealthKit")
            } else {
                print("❌ Error saving height: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
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
    
    func saveWeight(_ weightKg: Double, date: Date = Date()) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: weightKg)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)

        healthStore.save(sample) { success, error in
            if success {
                print("✅ Weight saved to HealthKit")
            } else {
                print("❌ Error saving weight: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
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
    
    /// Fetch user's BMI (calculated from latest height and weight)
    func fetchBMI(completion: @escaping (Double?) -> Void) {
        fetchWeight { weight in
            guard let weight = weight else {
                print("❌ Could not fetch weight for BMI")
                completion(nil)
                return
            }

            self.fetchHeight { height in
                guard let height = height, height > 0 else {
                    print("❌ Could not fetch height for BMI")
                    completion(nil)
                    return
                }

                let bmi = weight / (height * height)
                print("✅ BMI: \(String(format: "%.1f", bmi))")
                completion(bmi)
            }
        }
    }
}
