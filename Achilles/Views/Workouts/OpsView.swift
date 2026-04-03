import SwiftUI
import SwiftData
import Charts

struct OpsView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @State private var selectedDate = Date()
    @State private var todayLog: DailyLog?
    @State private var showingStartWorkout = false
    @State private var showingCatalog = false

    private var profile: UserProfile? { profiles.first }
    private var sessions: [WorkoutSession] {
        (todayLog?.workoutSessions ?? []).sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavBarBrand(tabName: "OPS", trailingContent: AnyView(
                    Button {
                        showingStartWorkout = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.amber)
                    }
                    .accessibilityLabel("Start new workout")
                ))
                ScrollView {
                    VStack(spacing: Theme.spacingMD) {
                        DaySelector(selectedDate: $selectedDate)
                        todaySummary
                        workoutSessions
                        recommendedWorkouts
                        volumeChart
                    }
                    .padding(.vertical, Theme.spacingMD)
                }
            }
            .background(Theme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingStartWorkout) {
                StartWorkoutView(dailyLog: todayLog)
                    .onDisappear { refreshLog() }
            }
            .sheet(isPresented: $showingCatalog) {
                WorkoutCatalogView(dailyLog: todayLog)
                    .onDisappear { refreshLog() }
            }
            .onChange(of: selectedDate) { _, _ in refreshLog() }
            .onAppear { refreshLog() }
        }
    }

    // MARK: - Today Summary

    private var todaySummary: some View {
        TacticalCard {
            HStack {
                StatReadout(
                    label: "Sessions",
                    value: "\(sessions.count)",
                    unit: "today",
                    color: sessions.isEmpty ? Theme.textTertiary : Theme.amber
                )
                Spacer()
                StatReadout(
                    label: "Total Volume",
                    value: sessions.isEmpty ? "--" : formatVolume(sessions.reduce(0) { $0 + $1.totalVolume }),
                    unit: "lbs"
                )
                Spacer()
                StatReadout(
                    label: "Duration",
                    value: "\(sessions.reduce(0) { $0 + $1.durationMinutes })",
                    unit: "min"
                )
            }
        }
        .padding(.horizontal, Theme.spacingMD)
    }

    private func formatVolume(_ v: Double) -> String {
        if v >= 1000 {
            return String(format: "%.1fk", v / 1000)
        }
        return "\(Int(v))"
    }

    // MARK: - Workout Sessions

    private var workoutSessions: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            SectionHeader(title: "Sessions")
                .padding(.horizontal, Theme.spacingMD)

            if sessions.isEmpty {
                TacticalCard {
                    VStack(spacing: Theme.spacingSM) {
                        Image(systemName: "figure.run")
                            .font(.title2)
                            .foregroundStyle(Theme.textTertiary)
                        Text("No workouts logged")
                            .font(Theme.label(13))
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingMD)
                }
                .padding(.horizontal, Theme.spacingMD)
            } else {
                ForEach(sessions) { session in
                    NavigationLink {
                        WorkoutDetailView(session: session)
                    } label: {
                        sessionRow(session)
                    }
                }
            }

            HStack(spacing: Theme.spacingSM) {
                TacticalButton(title: "Quick Start", icon: "bolt.fill") {
                    showingStartWorkout = true
                }
                TacticalButton(title: "From Catalog", icon: "list.bullet", style: .secondary) {
                    showingCatalog = true
                }
            }
            .padding(.horizontal, Theme.spacingMD)
        }
    }

    private func sessionRow(_ session: WorkoutSession) -> some View {
        TacticalCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.name.isEmpty ? "Workout" : session.name)
                        .font(Theme.label(15, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("\(session.sets.count) sets · \(session.durationMinutes) min")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Theme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, Theme.spacingMD)
    }

    // MARK: - Recommended Workouts

    @ViewBuilder
    private var recommendedWorkouts: some View {
        if let goal = profile?.goal {
            let recs = CatalogService.shared.workoutsForGoal(goal)
            if !recs.isEmpty {
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    SectionHeader(title: "Recommended for Your Mission")
                        .padding(.horizontal, Theme.spacingMD)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.spacingSM) {
                            ForEach(recs.prefix(4)) { template in
                                workoutTemplateCard(template)
                            }
                        }
                        .padding(.horizontal, Theme.spacingMD)
                    }
                }
            }
        }
    }

    private func workoutTemplateCard(_ template: CatalogWorkoutTemplate) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(template.name)
                .font(Theme.label(13, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
            Text("\(template.daysPerWeek)x/week · \(template.difficulty)")
                .font(Theme.mono(10))
                .foregroundStyle(Theme.textSecondary)
            Text(template.description)
                .font(Theme.label(11))
                .foregroundStyle(Theme.textTertiary)
                .lineLimit(2)
        }
        .padding(Theme.spacingSM)
        .frame(width: 180, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .strokeBorder(Theme.olive.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Volume Chart

    private var volumeChart: some View {
        TacticalCard {
            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                Text("WEEKLY VOLUME BY GROUP")
                    .font(Theme.label(10, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(1.5)

                let muscleVolume = computeWeeklyVolume()
                if muscleVolume.isEmpty {
                    Text("Complete workouts to see volume data")
                        .font(Theme.label(12))
                        .foregroundStyle(Theme.textTertiary)
                        .padding(.vertical, Theme.spacingMD)
                } else {
                    Chart(muscleVolume, id: \.group) { item in
                        BarMark(
                            x: .value("Group", item.group),
                            y: .value("Sets", item.sets)
                        )
                        .foregroundStyle(Theme.olive)
                        .cornerRadius(2)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisValueLabel()
                                .font(Theme.mono(9))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .font(Theme.mono(8))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .frame(height: 150)
                    .accessibilityLabel("Weekly volume by muscle group chart")
                }
            }
        }
        .padding(.horizontal, Theme.spacingMD)
    }

    private struct MuscleVolume {
        let group: String
        let sets: Int
    }

    private func computeWeeklyVolume() -> [MuscleVolume] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now)!
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.date >= weekAgo }
        )
        guard let sessions = try? context.fetch(descriptor) else { return [] }

        var grouped: [String: Int] = [:]
        for session in sessions {
            for set in session.sets {
                let group = exerciseMuscleGroup(set.exerciseName)
                grouped[group, default: 0] += 1
            }
        }
        return grouped.map { MuscleVolume(group: $0.key, sets: $0.value) }
            .sorted { $0.sets > $1.sets }
    }

    private func exerciseMuscleGroup(_ name: String) -> String {
        let n = name.lowercased()
        if n.contains("bench") || n.contains("push") || n.contains("chest") || n.contains("fly") { return "Chest" }
        if n.contains("squat") || n.contains("leg") || n.contains("lunge") || n.contains("quad") { return "Legs" }
        if n.contains("dead") || n.contains("row") || n.contains("pull") || n.contains("back") || n.contains("lat") { return "Back" }
        if n.contains("press") || n.contains("shoulder") || n.contains("delt") || n.contains("lateral") { return "Shoulders" }
        if n.contains("curl") || n.contains("bicep") { return "Biceps" }
        if n.contains("tricep") || n.contains("extension") || n.contains("dip") { return "Triceps" }
        if n.contains("core") || n.contains("ab") || n.contains("crunch") || n.contains("plank") { return "Core" }
        return "Other"
    }

    private func refreshLog() {
        todayLog = DailyLogService.getOrCreateLog(for: selectedDate, context: context)
    }
}
