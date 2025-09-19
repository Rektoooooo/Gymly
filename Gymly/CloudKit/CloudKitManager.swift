//
//  CloudKitManager.swift
//  Gymly
//
//  Created by CloudKit Integration on 18.09.2025.
//

import Foundation
import CloudKit
import SwiftData
import SwiftUI

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()

    private let container = CKContainer(identifier: "iCloud.com.gymly.app")
    private let privateDatabase: CKDatabase

    @Published var isSyncing = false
    @Published var syncError: String?
    @Published var isCloudKitEnabled = false
    @Published var lastSyncDate: Date?

    private let userDefaults = UserDefaults.standard
    private let lastSyncKey = "lastCloudKitSync"
    private let cloudKitEnabledKey = "isCloudKitEnabled"

    init() {
        self.privateDatabase = container.privateCloudDatabase
        self.lastSyncDate = userDefaults.object(forKey: lastSyncKey) as? Date

        // Check if we have an existing preference saved
        let hasExistingPreference = userDefaults.object(forKey: cloudKitEnabledKey) != nil
        let savedCloudKitState = userDefaults.bool(forKey: cloudKitEnabledKey)

        if hasExistingPreference {
            self.isCloudKitEnabled = savedCloudKitState
            print("🔥 INIT CLOUDKIT MANAGER - RESTORED EXISTING STATE: \(savedCloudKitState)")
        } else {
            // No existing preference - will be set based on availability check
            self.isCloudKitEnabled = false
            print("🔥 INIT CLOUDKIT MANAGER - NO EXISTING PREFERENCE, WILL CHECK AVAILABILITY")
        }

        Task {
            await checkCloudKitStatus()
        }
    }

    // MARK: - CloudKit Status
    func checkCloudKitStatus() async {
        await withCheckedContinuation { continuation in
            container.accountStatus { [weak self] status, error in
                DispatchQueue.main.async {
                    switch status {
                    case .available:
                        // CloudKit is available, check if user had it enabled before
                        let hasExistingPreference = self?.userDefaults.object(forKey: self?.cloudKitEnabledKey ?? "isCloudKitEnabled") != nil
                        let userPreference = self?.userDefaults.bool(forKey: self?.cloudKitEnabledKey ?? "isCloudKitEnabled") ?? false

                        if hasExistingPreference {
                            // User has a saved preference, respect it
                            self?.isCloudKitEnabled = userPreference
                            print("🔥 CLOUDKIT STATUS CHECK: AVAILABLE, EXISTING USER PREFERENCE: \(userPreference)")
                        } else {
                            // First time or fresh install - enable CloudKit by default when available
                            self?.isCloudKitEnabled = true
                            self?.userDefaults.set(true, forKey: self?.cloudKitEnabledKey ?? "isCloudKitEnabled")
                            print("🔥 CLOUDKIT STATUS CHECK: AVAILABLE, NO EXISTING PREFERENCE - ENABLING BY DEFAULT")
                        }
                        self?.syncError = nil
                    case .noAccount:
                        self?.isCloudKitEnabled = false
                        self?.syncError = "iCloud account not available. Please sign in to iCloud in Settings."
                        self?.userDefaults.set(false, forKey: self?.cloudKitEnabledKey ?? "isCloudKitEnabled")
                        print("🔥 CLOUDKIT STATUS CHECK: NO ACCOUNT")
                    case .restricted:
                        self?.isCloudKitEnabled = false
                        self?.syncError = "iCloud is restricted on this device."
                        self?.userDefaults.set(false, forKey: self?.cloudKitEnabledKey ?? "isCloudKitEnabled")
                        print("🔥 CLOUDKIT STATUS CHECK: RESTRICTED")
                    case .couldNotDetermine:
                        self?.isCloudKitEnabled = false
                        self?.syncError = "Could not determine iCloud status."
                        self?.userDefaults.set(false, forKey: self?.cloudKitEnabledKey ?? "isCloudKitEnabled")
                        print("🔥 CLOUDKIT STATUS CHECK: COULD NOT DETERMINE")
                    case .temporarilyUnavailable:
                        self?.isCloudKitEnabled = false
                        self?.syncError = "iCloud is temporarily unavailable."
                        self?.userDefaults.set(false, forKey: self?.cloudKitEnabledKey ?? "isCloudKitEnabled")
                        print("🔥 CLOUDKIT STATUS CHECK: TEMPORARILY UNAVAILABLE")
                    @unknown default:
                        self?.isCloudKitEnabled = false
                        self?.syncError = "Unknown iCloud status."
                        self?.userDefaults.set(false, forKey: self?.cloudKitEnabledKey ?? "isCloudKitEnabled")
                        print("🔥 CLOUDKIT STATUS CHECK: UNKNOWN")
                    }
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - CloudKit State Management
    func setCloudKitEnabled(_ enabled: Bool) {
        isCloudKitEnabled = enabled
        userDefaults.set(enabled, forKey: cloudKitEnabledKey)
        print("🔥 CLOUDKIT STATE SET TO: \(enabled)")
    }

    func isCloudKitAvailable() async -> Bool {
        await withCheckedContinuation { continuation in
            container.accountStatus { status, error in
                continuation.resume(returning: status == .available)
            }
        }
    }

    // MARK: - Split Sync
    func saveSplit(_ split: Split) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let recordID = CKRecord.ID(recordName: split.id.uuidString)

        // Try to fetch existing record first
        let record: CKRecord
        do {
            record = try await privateDatabase.record(for: recordID)
        } catch {
            // Record doesn't exist, create new one
            record = CKRecord(recordType: "Split", recordID: recordID)
        }

        // Update record fields
        record["name"] = split.name
        record["isActive"] = split.isActive ? 1 : 0
        record["startDate"] = split.startDate

        // Save days as references
        let dayReferences = (split.days ?? []).map { day in
            CKRecord.Reference(recordID: CKRecord.ID(recordName: day.id.uuidString), action: .deleteSelf)
        }
        record["days"] = dayReferences

        try await privateDatabase.save(record)

        // Save each day
        for day in split.days ?? [] {
            try await saveDay(day, splitId: split.id)
        }
    }

    func saveDay(_ day: Day, splitId: UUID) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let recordID = CKRecord.ID(recordName: day.id.uuidString)

        // Try to fetch existing record first
        let record: CKRecord
        do {
            record = try await privateDatabase.record(for: recordID)
        } catch {
            // Record doesn't exist, create new one
            record = CKRecord(recordType: "Day", recordID: recordID)
        }
        record["name"] = day.name
        record["dayOfSplit"] = day.dayOfSplit
        record["date"] = day.date
        record["splitId"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: splitId.uuidString), action: .deleteSelf)

        // Save exercises as references
        let exerciseReferences = (day.exercises ?? []).map { exercise in
            CKRecord.Reference(recordID: CKRecord.ID(recordName: exercise.id.uuidString), action: .deleteSelf)
        }
        record["exercises"] = exerciseReferences

        try await privateDatabase.save(record)

        // Save each exercise
        for exercise in day.exercises ?? [] {
            try await saveExercise(exercise, dayId: day.id)
        }
    }

    func saveExercise(_ exercise: Exercise, dayId: UUID) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let recordID = CKRecord.ID(recordName: exercise.id.uuidString)

        // Try to fetch existing record first
        let record: CKRecord
        do {
            record = try await privateDatabase.record(for: recordID)
        } catch {
            // Record doesn't exist, create new one
            record = CKRecord(recordType: "Exercise", recordID: recordID)
        }
        record["name"] = exercise.name
        record["repGoal"] = exercise.repGoal
        record["muscleGroup"] = exercise.muscleGroup
        record["createdAt"] = exercise.createdAt
        record["completedAt"] = exercise.completedAt
        record["exerciseOrder"] = exercise.exerciseOrder
        record["done"] = exercise.done ? 1 : 0
        record["dayId"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: dayId.uuidString), action: .deleteSelf)

        // Save sets as data
        if let setsData = try? JSONEncoder().encode(exercise.sets) {
            record["setsData"] = setsData as CKRecordValue
        }

        try await privateDatabase.save(record)
    }

    // MARK: - DayStorage Sync
    func saveDayStorage(_ dayStorage: DayStorage) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let recordID = CKRecord.ID(recordName: dayStorage.id.uuidString)

        // Try to fetch existing record first
        let record: CKRecord
        do {
            record = try await privateDatabase.record(for: recordID)
        } catch {
            // Record doesn't exist, create new one
            record = CKRecord(recordType: "DayStorage", recordID: recordID)
        }
        record["date"] = dayStorage.date
        record["dayId"] = dayStorage.dayId.uuidString
        record["dayName"] = dayStorage.dayName
        record["dayOfSplit"] = dayStorage.dayOfSplit

        try await privateDatabase.save(record)
    }

    // MARK: - WeightPoint Sync
    func saveWeightPoint(_ weightPoint: WeightPoint) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let recordID = CKRecord.ID(recordName: weightPoint.cloudKitID)

        // Try to fetch existing record first
        let record: CKRecord
        do {
            record = try await privateDatabase.record(for: recordID)
        } catch {
            // Record doesn't exist, create new one
            record = CKRecord(recordType: "WeightPoint", recordID: recordID)
        }
        record["weight"] = weightPoint.weight
        record["date"] = weightPoint.date

        try await privateDatabase.save(record)
    }


    // MARK: - Fetch Data
    func fetchAllSplits() async throws -> [Split] {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let query = CKQuery(recordType: "Split", predicate: NSPredicate(value: true))
        let records = try await privateDatabase.records(matching: query).matchResults.compactMap { try? $0.1.get() }

        var splits: [Split] = []
        for record in records {
            if let split = await splitFromRecord(record) {
                splits.append(split)
            }
        }

        return splits
    }

    private func splitFromRecord(_ record: CKRecord) async -> Split? {
        guard let name = record["name"] as? String,
              let startDate = record["startDate"] as? Date else {
            return nil
        }

        let id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        let isActive = (record["isActive"] as? Int ?? 0) == 1

        // Fetch days
        var days: [Day] = []
        if let dayReferences = record["days"] as? [CKRecord.Reference] {
            for reference in dayReferences {
                if let day = try? await fetchDay(recordID: reference.recordID) {
                    days.append(day)
                }
            }
        }

        return Split(id: id, name: name, days: days, isActive: isActive, startDate: startDate)
    }

    private func fetchDay(recordID: CKRecord.ID) async throws -> Day {
        let record = try await privateDatabase.record(for: recordID)

        guard let name = record["name"] as? String,
              let dayOfSplit = record["dayOfSplit"] as? Int,
              let date = record["date"] as? String else {
            throw CloudKitError.invalidData
        }

        let id = UUID(uuidString: record.recordID.recordName) ?? UUID()

        // Fetch exercises
        var exercises: [Exercise] = []
        if let exerciseReferences = record["exercises"] as? [CKRecord.Reference] {
            for reference in exerciseReferences {
                if let exercise = try? await fetchExercise(recordID: reference.recordID) {
                    exercises.append(exercise)
                }
            }
        }

        return Day(id: id, name: name, dayOfSplit: dayOfSplit, exercises: exercises, date: date)
    }

    private func fetchExercise(recordID: CKRecord.ID) async throws -> Exercise {
        let record = try await privateDatabase.record(for: recordID)

        guard let name = record["name"] as? String,
              let repGoal = record["repGoal"] as? String,
              let muscleGroup = record["muscleGroup"] as? String,
              let exerciseOrder = record["exerciseOrder"] as? Int else {
            throw CloudKitError.invalidData
        }

        let id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        let createdAt = record["createdAt"] as? Date ?? Date()
        let completedAt = record["completedAt"] as? Date
        let done = (record["done"] as? Int ?? 0) == 1

        // Decode sets
        var sets: [Exercise.Set] = []
        if let setsData = record["setsData"] as? Data {
            sets = (try? JSONDecoder().decode([Exercise.Set].self, from: setsData)) ?? []
        }

        return Exercise(
            id: id,
            name: name,
            sets: sets,
            repGoal: repGoal,
            muscleGroup: muscleGroup,
            createdAt: createdAt,
            completedAt: completedAt,
            exerciseOrder: exerciseOrder,
            done: done
        )
    }

    func fetchAllDayStorage() async throws -> [DayStorage] {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let query = CKQuery(recordType: "DayStorage", predicate: NSPredicate(value: true))
        let records = try await privateDatabase.records(matching: query).matchResults.compactMap { try? $0.1.get() }

        var dayStorages: [DayStorage] = []
        for record in records {
            if let date = record["date"] as? String,
               let dayIdString = record["dayId"] as? String,
               let dayName = record["dayName"] as? String,
               let dayOfSplit = record["dayOfSplit"] as? Int,
               let dayId = UUID(uuidString: dayIdString) {
                let id = UUID(uuidString: record.recordID.recordName) ?? UUID()
                dayStorages.append(DayStorage(id: id, dayId: dayId, dayName: dayName, dayOfSplit: dayOfSplit, date: date))
            }
        }

        return dayStorages
    }

    func fetchAllWeightPoints() async throws -> [WeightPoint] {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let query = CKQuery(recordType: "WeightPoint", predicate: NSPredicate(value: true))
        let records = try await privateDatabase.records(matching: query).matchResults.compactMap { try? $0.1.get() }

        var weightPoints: [WeightPoint] = []
        for record in records {
            if let weight = record["weight"] as? Double,
               let date = record["date"] as? Date {
                weightPoints.append(WeightPoint(date: date, weight: weight))
            }
        }

        return weightPoints
    }


    // MARK: - Delete Operations
    func deleteSplit(_ splitId: UUID) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let recordID = CKRecord.ID(recordName: splitId.uuidString)
        try await privateDatabase.deleteRecord(withID: recordID)
    }

    func deleteDay(_ dayId: UUID) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let recordID = CKRecord.ID(recordName: dayId.uuidString)
        try await privateDatabase.deleteRecord(withID: recordID)
    }

    func deleteExercise(_ exerciseId: UUID) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        let recordID = CKRecord.ID(recordName: exerciseId.uuidString)
        try await privateDatabase.deleteRecord(withID: recordID)
    }

    // MARK: - Full Sync
    func performFullSync(context: ModelContext, config: Config) async {
        guard isCloudKitEnabled else { return }

        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncError = nil
        }

        do {
            // Sync Splits
            let descriptor = FetchDescriptor<Split>()
            let localSplits = try context.fetch(descriptor)
            for split in localSplits {
                try await saveSplit(split)
            }

            // Sync DayStorage
            let dayStorageDescriptor = FetchDescriptor<DayStorage>()
            let localDayStorages = try context.fetch(dayStorageDescriptor)
            for dayStorage in localDayStorages {
                try await saveDayStorage(dayStorage)
            }

            // Sync WeightPoints
            let weightPointDescriptor = FetchDescriptor<WeightPoint>()
            let localWeightPoints = try context.fetch(weightPointDescriptor)
            for weightPoint in localWeightPoints {
                try await saveWeightPoint(weightPoint)
            }


            // Update last sync date
            let now = Date()
            userDefaults.set(now, forKey: lastSyncKey)

            DispatchQueue.main.async {
                self.lastSyncDate = now
                self.isSyncing = false
            }
        } catch {
            DispatchQueue.main.async {
                self.syncError = error.localizedDescription
                self.isSyncing = false
            }
        }
    }

    func fetchAndMergeData(context: ModelContext, config: Config) async {
        guard isCloudKitEnabled else {
            print("🔥 CLOUDKIT NOT ENABLED - SKIPPING FETCH")
            return
        }

        print("🔥 STARTING FETCHANDMERGEDATA")
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncError = nil
        }

        do {
            // Fetch and merge splits
            let cloudSplits = try await fetchAllSplits()
            let localSplitDescriptor = FetchDescriptor<Split>()
            let localSplits = try context.fetch(localSplitDescriptor)

            for cloudSplit in cloudSplits {
                if !localSplits.contains(where: { $0.id == cloudSplit.id }) {
                    context.insert(cloudSplit)
                }
            }

            // Fetch and merge DayStorage
            let cloudDayStorages = try await fetchAllDayStorage()
            let localDayStorageDescriptor = FetchDescriptor<DayStorage>()
            let localDayStorages = try context.fetch(localDayStorageDescriptor)

            for cloudDayStorage in cloudDayStorages {
                if !localDayStorages.contains(where: { $0.id == cloudDayStorage.id }) {
                    context.insert(cloudDayStorage)
                }
            }

            // Fetch and merge WeightPoints
            let cloudWeightPoints = try await fetchAllWeightPoints()
            let localWeightPointDescriptor = FetchDescriptor<WeightPoint>()
            let localWeightPoints = try context.fetch(localWeightPointDescriptor)

            for cloudWeightPoint in cloudWeightPoints {
                if !localWeightPoints.contains(where: { $0.id == cloudWeightPoint.id }) {
                    context.insert(cloudWeightPoint)
                }
            }

            // Save context
            try context.save()

            // Update last sync date
            let now = Date()
            userDefaults.set(now, forKey: lastSyncKey)

            DispatchQueue.main.async {
                self.lastSyncDate = now
                self.isSyncing = false
            }
        } catch {
            DispatchQueue.main.async {
                self.syncError = error.localizedDescription
                self.isSyncing = false
            }
        }
    }

    // MARK: - UserProfile CloudKit Methods

    func saveUserProfile(_ profile: UserProfile) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        do {
            // Use fixed record ID for user profile so there's only one per user
            let recordID = CKRecord.ID(recordName: "user_profile", zoneID: .default)

            let record: CKRecord
            do {
                // Try to fetch existing record to update it
                let existingRecord = try await privateDatabase.record(for: recordID)
                record = existingRecord
                print("🔄 USER PROFILE: Updating existing CloudKit record")
            } catch {
                // Record doesn't exist, create new one
                record = CKRecord(recordType: "UserProfile", recordID: recordID)
                print("🆕 USER PROFILE: Creating new CloudKit record")
            }

            // Update record with current profile data
            record["username"] = profile.username as CKRecordValue
            record["email"] = profile.email as CKRecordValue
            record["height"] = profile.height as CKRecordValue
            record["weight"] = profile.weight as CKRecordValue
            record["age"] = profile.age as CKRecordValue
            record["bmi"] = profile.bmi as CKRecordValue
            record["isHealthEnabled"] = (profile.isHealthEnabled ? 1 : 0) as CKRecordValue
            record["weightUnit"] = profile.weightUnit as CKRecordValue
            record["roundSetWeights"] = (profile.roundSetWeights ? 1 : 0) as CKRecordValue
            record["updatedAt"] = profile.updatedAt as CKRecordValue
            record["modifiedAt"] = Date() as CKRecordValue // For CloudKit query sorting

            if let cloudKitID = profile.profileImageCloudKitID {
                record["profileImageCloudKitID"] = cloudKitID as CKRecordValue
            }

            _ = try await privateDatabase.save(record)
            print("✅ USER PROFILE: Saved to CloudKit with ID: \(record.recordID.recordName)")

        } catch {
            print("❌ USER PROFILE: Failed to save to CloudKit - \(error)")
            throw CloudKitError.syncFailed(error.localizedDescription)
        }
    }

    func fetchUserProfile() async throws -> [String: Any]? {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        // Use direct record fetch with fixed ID instead of query to avoid field queryability issues
        let recordID = CKRecord.ID(recordName: "user_profile", zoneID: .default)

        do {
            let record = try await privateDatabase.record(for: recordID)
            print("✅ USER PROFILE: Found existing CloudKit profile")
            return UserProfile.fromCKRecord(record)
        } catch {
            // Record doesn't exist or other error
            if let ckError = error as? CKError, ckError.code == .unknownItem {
                print("🔍 USER PROFILE: No CloudKit profile found")
                return nil
            } else {
                print("❌ USER PROFILE: Failed to fetch from CloudKit - \(error)")
                throw CloudKitError.syncFailed(error.localizedDescription)
            }
        }
    }

    func saveProfileImage(_ image: UIImage) async throws -> String {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw CloudKitError.invalidData
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("profile_image.jpg")
        try imageData.write(to: tempURL)

        let asset = CKAsset(fileURL: tempURL)

        // Use fixed record ID for profile image so there's only one per user
        let recordID = CKRecord.ID(recordName: "user_profile_image", zoneID: .default)
        let record: CKRecord

        do {
            // Try to fetch existing record first
            let existingRecord = try await privateDatabase.record(for: recordID)
            record = existingRecord
            print("🔄 PROFILE IMAGE: Updating existing CloudKit record")
        } catch {
            // Create new record if it doesn't exist
            record = CKRecord(recordType: "ProfileImage", recordID: recordID)
            print("🆕 PROFILE IMAGE: Creating new CloudKit record")
        }

        record["image"] = asset

        do {
            _ = try await privateDatabase.save(record)
            print("✅ PROFILE IMAGE: Saved to CloudKit")
            return "cloudkit_profile_image"
        } catch {
            print("❌ PROFILE IMAGE: Failed to save to CloudKit - \(error)")
            throw CloudKitError.syncFailed(error.localizedDescription)
        }
    }

    func fetchProfileImage() async throws -> UIImage? {
        guard isCloudKitEnabled else {
            throw CloudKitError.notAvailable
        }

        // Use the same fixed record ID as saveProfileImage
        let recordID = CKRecord.ID(recordName: "user_profile_image", zoneID: .default)

        do {
            let record = try await privateDatabase.record(for: recordID)

            if let asset = record["image"] as? CKAsset,
               let fileURL = asset.fileURL,
               let imageData = try? Data(contentsOf: fileURL),
               let image = UIImage(data: imageData) {
                print("✅ PROFILE IMAGE: Fetched from CloudKit")
                return image
            }

            print("🔍 PROFILE IMAGE: Record found but no valid image data")
            return nil
        } catch {
            print("🔍 PROFILE IMAGE: No CloudKit profile image found")
            return nil
        }
    }
}

enum CloudKitError: LocalizedError {
    case notAvailable
    case invalidData
    case syncFailed(String)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "iCloud is not available. Please check your iCloud settings."
        case .invalidData:
            return "Invalid data format received from iCloud."
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        }
    }
}
