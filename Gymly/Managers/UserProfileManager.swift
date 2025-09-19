//
//  UserProfileManager.swift
//  Gymly
//
//  Created by SwiftData Migration on 18.09.2025.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit

@MainActor
class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    @Published var currentProfile: UserProfile?
    @Published var isLoading = false
    @Published var error: String?

    // Computed property to check if profile is ready to use
    var isProfileReady: Bool {
        return currentProfile != nil
    }

    // Get current profile, creating one if necessary (for UI access)
    var profileWithFallback: UserProfile {
        if let profile = currentProfile {
            return profile
        } else {
            ensureProfileExists()
            return currentProfile ?? UserProfile() // Emergency fallback
        }
    }

    // DEBUG: Clear all profiles (for testing fresh install)
    func clearAllProfiles() {
        guard let context = modelContext else { return }

        do {
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)

            for profile in profiles {
                context.delete(profile)
            }

            try context.save()
            currentProfile = nil
            print("🗑️ DEBUG: Cleared all UserProfiles from database")
        } catch {
            print("❌ DEBUG: Failed to clear profiles - \(error)")
        }
    }

    private var modelContext: ModelContext?
    private var syncTask: Task<Void, Never>?
    private var isSyncing = false
    
    private init() {}
    
    // MARK: - Setup
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Profile Management
    
    /// Load existing profile or create a temporary one that can be overridden by CloudKit
    func loadOrCreateProfile() {
        guard let context = modelContext else {
            error = "ModelContext not available"
            return
        }

        do {
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)

            if let existingProfile = profiles.first {
                currentProfile = existingProfile
                print("✅ USER PROFILE: Loaded existing profile for \(existingProfile.username)")
            } else {
                // Create a temporary profile that will be replaced by CloudKit data if available
                let tempProfile = UserProfile()
                context.insert(tempProfile)
                try context.save()
                currentProfile = tempProfile
                print("✅ USER PROFILE: Created temporary profile (will be replaced by CloudKit if available)")
            }
        } catch {
            self.error = "Failed to load user profile: \(error.localizedDescription)"
            print("❌ USER PROFILE: \(self.error!)")
        }
    }

    /// Create a new profile if none exists (called when needed)
    private func ensureProfileExists() {
        guard currentProfile == nil, let context = modelContext else { return }

        do {
            let newProfile = UserProfile()
            context.insert(newProfile)
            try context.save()
            currentProfile = newProfile
            print("✅ USER PROFILE: Created new profile")
        } catch {
            self.error = "Failed to create user profile: \(error.localizedDescription)"
            print("❌ USER PROFILE: Failed to create profile - \(self.error!)")
        }
    }
    
    /// Save current profile
    func saveProfile() {
        guard let context = modelContext, let profile = currentProfile else {
            error = "No profile or context available"
            return
        }
        
        do {
            profile.markAsUpdated()
            try context.save()
            print("✅ USER PROFILE: Saved profile for \(profile.username)")
            
            // Trigger debounced CloudKit sync if enabled
            if CloudKitManager.shared.isCloudKitEnabled {
                debouncedSyncToCloudKit()
            }
        } catch {
            self.error = "Failed to save profile: \(error.localizedDescription)"
            print("❌ USER PROFILE: Save failed - \(self.error!)")
        }
    }

    private func debouncedSyncToCloudKit() {
        // Cancel existing sync task if running
        syncTask?.cancel()

        // Create new debounced sync task
        syncTask = Task {
            // Wait 2 seconds before syncing to batch multiple changes
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            // Check if task was cancelled
            guard !Task.isCancelled else { return }

            await syncToCloudKit()
        }
    }
    
    // MARK: - Update Methods
    
    func updateUsername(_ username: String) {
        ensureProfileExists()
        currentProfile?.username = username
        saveProfile()
    }

    func updateEmail(_ email: String) {
        ensureProfileExists()
        currentProfile?.email = email
        saveProfile()
    }

    func updatePhysicalStats(height: Double? = nil, weight: Double? = nil, age: Int? = nil) {
        ensureProfileExists()
        guard let profile = currentProfile else { return }
        
        if let height = height {
            profile.height = height
        }
        if let weight = weight {
            profile.weight = weight
        }
        if let age = age {
            profile.age = age
        }
        
        profile.updateBMI()
        saveProfile()
    }
    
    func updateHealthPermissions(healthEnabled: Bool? = nil) {
        ensureProfileExists()
        guard let profile = currentProfile else { return }
        
        if let healthEnabled = healthEnabled {
            profile.isHealthEnabled = healthEnabled
        }
        
        saveProfile()
    }
    
    func updatePreferences(weightUnit: String? = nil, roundSetWeights: Bool? = nil) {
        ensureProfileExists()
        guard let profile = currentProfile else { return }
        
        if let weightUnit = weightUnit {
            profile.weightUnit = weightUnit
        }
        if let roundSetWeights = roundSetWeights {
            profile.roundSetWeights = roundSetWeights
        }
        
        saveProfile()
    }
    
    func updateProfileImage(_ image: UIImage?) {
        ensureProfileExists()
        guard let profile = currentProfile else { return }
        
        profile.setProfileImage(image)
        saveProfile()
        
        // Handle CloudKit image sync separately
        if let image = image {
            Task {
                do {
                    let cloudKitID = try await CloudKitManager.shared.saveProfileImage(image)
                    await MainActor.run {
                        profile.profileImageCloudKitID = cloudKitID
                        try? modelContext?.save()
                    }
                } catch {
                    print("❌ Failed to sync profile image to CloudKit: \(error)")
                }
            }
        }
    }
    
    // MARK: - CloudKit Integration
    
    private func syncToCloudKit() async {
        guard let profile = currentProfile,
              CloudKitManager.shared.isCloudKitEnabled,
              !isSyncing else {
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        do {
            print("🔄 USER PROFILE: Syncing to CloudKit...")
            try await CloudKitManager.shared.saveUserProfile(profile)
            await MainActor.run {
                profile.markAsSynced()
                try? modelContext?.save()
            }
            print("✅ USER PROFILE: Synced to CloudKit successfully")
        } catch {
            await MainActor.run {
                self.error = "CloudKit sync failed: \(error.localizedDescription)"
            }
            print("❌ USER PROFILE: CloudKit sync failed - \(error)")
        }
    }
    

    func syncFromCloudKit() async {
        guard CloudKitManager.shared.isCloudKitEnabled else {
            print("🔍 USER PROFILE: CloudKit not enabled, skipping sync")
            return
        }
        
        do {
            print("🔄 USER PROFILE: Fetching from CloudKit...")
            if let cloudProfile = try await CloudKitManager.shared.fetchUserProfile() {
                await MainActor.run {
                    if let existingProfile = currentProfile {
                        // Replace all data with CloudKit data (complete restoration)
                        existingProfile.updateFromCloudKit(cloudProfile)
                        try? modelContext?.save()
                        print("✅ USER PROFILE: Completely restored from CloudKit data")

                        // Trigger UI updates by notifying that profile changed
                        objectWillChange.send()
                    } else {
                        // Create new profile from CloudKit data
                        let newProfile = UserProfile()
                        newProfile.updateFromCloudKit(cloudProfile)
                        modelContext?.insert(newProfile)
                        currentProfile = newProfile
                        try? modelContext?.save()
                        print("✅ USER PROFILE: Created from CloudKit data")
                    }
                }
                
                // Load profile image if available
                if let cloudKitID = cloudProfile["profileImageCloudKitID"] as? String,
                   cloudKitID == "cloudkit_profile_image" {
                    if let cloudImage = try? await CloudKitManager.shared.fetchProfileImage() {
                        await MainActor.run {
                            currentProfile?.setProfileImage(cloudImage)
                            try? modelContext?.save()
                        }
                    }
                }
            } else {
                print("🔍 USER PROFILE: No CloudKit data found")
            }
        } catch {
            await MainActor.run {
                self.error = "CloudKit fetch failed: \(error.localizedDescription)"
            }
            print("❌ USER PROFILE: CloudKit fetch failed - \(error)")
        }
    }
    

    
}
