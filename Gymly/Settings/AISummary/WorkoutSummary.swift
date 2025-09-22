//
//  WorkoutSummary.swift
//  Gymly
//
//  Created by Sebastián Kučera on 22.09.2025.
//


import Foundation
import FoundationModels

@Generable
public struct WorkoutSummary: Codable {
    public var version: String                // "1.0"
    public var headline: String               // e.g., "Solid Pull Day — 2 PRs"
    public var overview: String               // 2–3 sentences in plain language
    public var keyStats: [KeyStat]            // compact, UI-friendly metrics
    public var session: SessionBreakdown      // per-exercise rollup
    public var trends: [Trend]                // short-term patterns (1–4 weeks)
    public var prs: [PersonalRecord]          // any PRs detected
    public var issues: [Issue]                // injuries, form flags, anomalies
    public var recommendations: [Recommendation] // next-steps you can act on
}

@Generable
public struct KeyStat: Codable {
    public var name: String                   // "Total Volume"
    public var value: String                  // "21,450 kg"
    public var delta: String?                 // "+6% vs last week"
    public var emoji: String?                 // "📈"
}

@Generable
public struct SessionBreakdown: Codable {
    public var durationMinutes: Int
    public var effortRating: Int?             // 1–10 subjective or inferred
    public var exercises: [ExerciseSummary]
}

@Generable
public struct ExerciseSummary: Codable {
    public var name: String                   // "Barbell Bench Press"
    public var sets: Int
    public var repsTotal: Int
    public var topSet: String?                // "110 kg × 3 @ RPE 9"
    public var volume: String?                // "7,920 kg"
    public var notes: String?                 // short, 1 sentence
}

@Generable
public struct Trend: Codable {
    public var label: String                  // "Bench strength"
    public var direction: String              // "up" | "flat" | "down"
    public var evidence: String               // "Top set +5 kg vs last week"
}

@Generable
public struct PersonalRecord: Codable {
    public var exercise: String               // "Deadlift"
    public var type: String                   // "1RM est" | "rep PR" | "volume PR"
    public var value: String                  // "180 kg (est 1RM)"
}

@Generable
public struct Issue: Codable {
    public var category: String               // "Form" | "Pain" | "Consistency"
    public var detail: String                 // "Knees caved on last 2 reps"
    public var severity: String               // "low" | "medium" | "high"
}

@Generable
public struct Recommendation: Codable {
    public var title: String                  // "Deload lower body volume by 10%"
    public var rationale: String              // why
    public var action: String                 // concrete next step
}
