//
//  AISummaryView.swift
//  Gymly
//
//  Created by Sebastián Kučera on 22.09.2025.
//

import SwiftUI
import SwiftData

struct AISummaryView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.modelContext) private var context
    @StateObject private var summarizer = WorkoutSummarizer()
    @State private var dataFetcher: WorkoutDataFetcher?
    @State private var weeklyWorkouts: [CompletedWorkout] = []
    @State private var selectedTimeframe = 7
    @State private var showError = false
    @State private var hasStartedGeneration = false
    
    var body: some View {
        ZStack {
            FloatingClouds(theme: CloudsTheme.appleIntelligence(scheme))
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    
                    if summarizer.isGenerating && !hasStartedGeneration {
                        loadingView
                    } else if hasStartedGeneration || summarizer.workoutSummary != nil {
                        streamingContent
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
        }
        .navigationTitle("AI Workout Summary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupDataFetcher()
            fetchWorkouts()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(summarizer.error?.localizedDescription ?? "An error occurred")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(hasStartedGeneration ? "Regenerate" : "Generate") {
                    generateSummary()
                }
                .disabled(summarizer.isGenerating || weeklyWorkouts.isEmpty)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain")
                .font(.system(size: 50))
                .foregroundStyle(.linearGradient(
                    colors: [.purple, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            Text("Weekly Workout Intelligence")
                .font(.title2.bold())
            
            Text("AI-powered insights from your past \(selectedTimeframe) days")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Analyzing your workouts...")
                .font(.headline)
            
            Text("This may take a moment")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder
    private var streamingContent: some View {
        VStack(spacing: 20) {
            if summarizer.isGenerating {
                VStack(spacing: 16) {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Analyzing your workouts...")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text("AI is examining patterns, trends, and performance")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            if let summary = summarizer.workoutSummary {
                summaryContent(summary)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: summarizer.workoutSummary?.headline)
        .animation(.easeInOut(duration: 0.3), value: summarizer.workoutSummary?.overview)
        .animation(.easeInOut(duration: 0.3), value: summarizer.workoutSummary?.keyStats?.count)
        .animation(.easeInOut(duration: 0.3), value: summarizer.workoutSummary?.trends?.count)
        .animation(.easeInOut(duration: 0.3), value: summarizer.workoutSummary?.prs?.count)
        .animation(.easeInOut(duration: 0.3), value: summarizer.workoutSummary?.issues?.count)
        .animation(.easeInOut(duration: 0.3), value: summarizer.workoutSummary?.recommendations?.count)
    }
    
    @ViewBuilder
    private func summaryContent(_ summary: WorkoutSummary.PartiallyGenerated) -> some View {
        VStack(spacing: 20) {
            if let headline = summary.headline {
                headlineCard(headline)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            if let overview = summary.overview {
                overviewCard(overview)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            if let keyStats = summary.keyStats, !keyStats.isEmpty {
                keyStatsCard(keyStats)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            if let trends = summary.trends, !trends.isEmpty {
                trendsCard(trends)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            if let prs = summary.prs, !prs.isEmpty {
                personalRecordsCard(prs)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            if let issues = summary.issues, !issues.isEmpty {
                issuesCard(issues)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            
            if let recommendations = summary.recommendations, !recommendations.isEmpty {
                recommendationsCard(recommendations)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            if summarizer.isGenerating {
                HStack {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.6)
                        Text("Generating more insights...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .opacity(0.7)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private func headlineCard(_ headline: String) -> some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text(headline)
                .font(.title3.bold())
                .multilineTextAlignment(.leading)
                .contentTransition(.opacity)
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func overviewCard(_ overview: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Overview", systemImage: "doc.text")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(overview)
                .font(.body)
                .foregroundStyle(.secondary)
                .contentTransition(.opacity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func keyStatsCard(_ stats: [KeyStat].PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Key Stats", systemImage: "chart.bar.fill")
                .font(.headline)
            
            ForEach(stats) { stat in
                HStack {
                    Image(systemName: iconForStat(stat.name ?? ""))
                        .font(.title3)
                        .foregroundStyle(.gray)
                    VStack(alignment: .leading) {
                        if let name = stat.name {
                            Text(name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if let value = stat.value {
                            Text(value)
                                .font(.headline)
                        }
                    }
                    Spacer()
                    if let delta = stat.delta {
                        Text(delta)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(delta.contains("+") ? Color.green.opacity(0.5) : (delta.contains("-") ? Color.red.opacity(0.5) : Color.gray.opacity(0.5)))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    
    private func trendsCard(_ trends: [Trend].PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
            
            ForEach(trends) { trend in
                HStack {
                    if let direction = trend.direction {
                        Image(systemName: trendIcon(for: direction))
                            .foregroundStyle(trendColor(for: direction))
                    }
                    
                    VStack(alignment: .leading) {
                        if let label = trend.label {
                            Text(label)
                                .font(.subheadline.bold())
                        }
                        if let evidence = trend.evidence {
                            Text(evidence)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func personalRecordsCard(_ prs: [PersonalRecord].PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Personal Records", systemImage: "trophy.fill")
                .font(.headline)
                .foregroundStyle(.yellow)
            
            ForEach(prs) { pr in
                HStack {
                    Image(systemName: "medal.fill")
                        .foregroundStyle(.yellow)
                    
                    VStack(alignment: .leading) {
                        if let exercise = pr.exercise {
                            Text(exercise)
                                .font(.subheadline.bold())
                        }
                        HStack {
                            if let type = pr.type {
                                Text(type)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text("•")
                                .foregroundStyle(.secondary)
                            if let value = pr.value {
                                Text(value)
                                    .font(.caption.bold())
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 12)
        )
    }
    
    private func issuesCard(_ issues: [Issue].PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Areas of Concern", systemImage: "exclamationmark.triangle")
                .font(.headline)
                .foregroundStyle(.orange)
            
            ForEach(issues) { issue in
                HStack(alignment: .top) {
                    if let severity = issue.severity {
                        Circle()
                            .fill(severityColor(for: severity))
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                    }
                    
                    VStack(alignment: .leading) {
                        if let category = issue.category {
                            Text(category)
                                .font(.caption.bold())
                                .foregroundStyle(severityColor(for: issue.severity ?? "low"))
                        }
                        if let detail = issue.detail {
                            Text(detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func recommendationsCard(_ recommendations: [Recommendation].PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recommendations", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(.blue)
            
            ForEach(recommendations) { recommendation in
                VStack(alignment: .leading, spacing: 8) {
                    if let title = recommendation.title {
                        Text(title)
                            .font(.subheadline.bold())
                    }
                    
                    if let rationale = recommendation.rationale {
                        Text(rationale)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let action = recommendation.action {
                        Label(action, systemImage: "arrow.right.circle")
                            .font(.caption.bold())
                            .foregroundStyle(.blue)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundStyle(.quaternary)
            
            Text("No Summary Yet")
                .font(.title2.bold())
            
            Text("Complete some workouts this week and generate an AI summary to see insights")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if !weeklyWorkouts.isEmpty {
                Button(action: generateSummary) {
                    Label("Generate Summary", systemImage: "sparkles")
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
    }
    
    private func setupDataFetcher() {
        print("🔍 AI View: Setting up data fetcher")
        dataFetcher = WorkoutDataFetcher(context: context)
        summarizer.prewarm()
    }
    
    private func fetchWorkouts() {
        print("🔍 AI View: Starting to fetch workouts")
        guard let fetcher = dataFetcher else {
            print("❌ AI View: No data fetcher available")
            return
        }
        weeklyWorkouts = fetcher.fetchWeeklyWorkouts()
        print("🔍 AI View: Fetched \(weeklyWorkouts.count) weekly workouts")
        
        for (index, workout) in weeklyWorkouts.enumerated() {
            print("🔍 AI View: Workout \(index + 1): \(workout.dayName) on \(workout.date) with \(workout.exercises.count) exercises")
        }
    }
    
    private func generateSummary() {
        guard !weeklyWorkouts.isEmpty else { return }
        guard let fetcher = dataFetcher else { return }

        Task {
            do {
                await MainActor.run {
                    hasStartedGeneration = true
                    // Clear previous summary to show fresh streaming
                    summarizer.clearSummary()
                }

                let comparisonData = fetcher.fetchWorkoutsForComparison()
                try await summarizer.generateWeeklySummary(thisWeek: comparisonData.thisWeek, lastWeek: comparisonData.lastWeek)
            } catch {
                await MainActor.run {
                    summarizer.error = error
                    showError = true
                    hasStartedGeneration = false
                }
            }
        }
    }
    
    private func trendIcon(for direction: String) -> String {
        switch direction.lowercased() {
        case "up": return "arrow.up.right"
        case "down": return "arrow.down.right"
        default: return "arrow.right"
        }
    }
    
    private func trendColor(for direction: String) -> Color {
        switch direction.lowercased() {
        case "up": return .green
        case "down": return .red
        default: return .gray
        }
    }
    
    private func severityColor(for severity: String) -> Color {
        switch severity.lowercased() {
        case "high": return .red
        case "medium": return .orange
        default: return .yellow
        }
    }

    private func iconForStat(_ statName: String) -> String {
        let name = statName.lowercased()

        if name.contains("volume") || name.contains("weight") {
            return "scalemass"
        } else if name.contains("session") || name.contains("workout") {
            return "figure.strengthtraining.traditional"
        } else if name.contains("duration") || name.contains("time") {
            return "clock"
        } else if name.contains("pr") || name.contains("record") {
            return "trophy"
        } else if name.contains("exercise") {
            return "dumbbell"
        } else if name.contains("rep") {
            return "repeat"
        } else {
            return "chart.bar"
        }
    }
}

#Preview {
    NavigationStack {
        AISummaryView()
    }
}
