import SwiftUI
import SwiftData
import Charts

struct IntelView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @Query(sort: \WeightEntry.date, order: .reverse) private var weightEntries: [WeightEntry]
    @Query(sort: \DailyLog.dateString, order: .reverse) private var logs: [DailyLog]
    @State private var showingEditProfile = false
    @State private var showingLogWeight = false
    @State private var newWeight = ""

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavBarBrand(tabName: "INTEL", trailingContent: AnyView(
                    Button {
                        showingEditProfile = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .accessibilityLabel("Edit profile settings")
                ))
                ScrollView {
                    VStack(spacing: Theme.spacingMD) {
                        profileCard
                        goalsCard
                        weightSection
                        macroAdherenceChart
                        workoutFrequencyChart
                        exportButton
                    }
                    .padding(Theme.spacingMD)
                }
            }
            .background(Theme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        TacticalCard {
            HStack(spacing: Theme.spacingMD) {
                ZStack {
                    Circle()
                        .fill(Theme.olive.opacity(0.2))
                        .frame(width: 56, height: 56)
                    Text(String((profile?.name ?? "O").prefix(1)).uppercased())
                        .font(Theme.heading(24))
                        .foregroundStyle(Theme.olive)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile?.name ?? "Operator")
                        .font(Theme.heading(20))
                        .foregroundStyle(Theme.textPrimary)
                    HStack(spacing: Theme.spacingSM) {
                        Text("Age \(profile?.age ?? 0)")
                            .font(Theme.mono(12))
                            .foregroundStyle(Theme.textSecondary)
                        Text("·")
                            .foregroundStyle(Theme.textTertiary)
                        Text("\(Int(profile?.weightLbs ?? 0)) lbs")
                            .font(Theme.mono(12))
                            .foregroundStyle(Theme.textSecondary)
                        Text("·")
                            .foregroundStyle(Theme.textTertiary)
                        Text(formatHeight(profile?.heightInches ?? 0))
                            .font(Theme.mono(12))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer()
            }
        }
    }

    private func formatHeight(_ inches: Double) -> String {
        let ft = Int(inches) / 12
        let inch = Int(inches) % 12
        return "\(ft)'\(inch)\""
    }

    // MARK: - Goals Card

    private var goalsCard: some View {
        TacticalCard {
            VStack(spacing: Theme.spacingMD) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MISSION")
                            .font(Theme.label(10, weight: .bold))
                            .foregroundStyle(Theme.textTertiary)
                            .tracking(1.5)
                        Text(profile?.goal.rawValue.uppercased() ?? "--")
                            .font(Theme.heading(20))
                            .foregroundStyle(Theme.amber)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("ACTIVITY")
                            .font(Theme.label(10, weight: .bold))
                            .foregroundStyle(Theme.textTertiary)
                            .tracking(1.5)
                        Text(profile?.activityLevel.rawValue ?? "--")
                            .font(Theme.label(14, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                }

                Divider().background(Theme.border)

                HStack {
                    StatReadout(label: "Calories", value: "\(profile?.calorieTarget ?? 0)", unit: "cal")
                    Spacer()
                    StatReadout(label: "Protein", value: "\(profile?.proteinTarget ?? 0)", unit: "g", color: Theme.proteinColor)
                    Spacer()
                    StatReadout(label: "Carbs", value: "\(profile?.carbsTarget ?? 0)", unit: "g", color: Theme.carbsColor)
                    Spacer()
                    StatReadout(label: "Fat", value: "\(profile?.fatTarget ?? 0)", unit: "g", color: Theme.fatColor)
                }

                if let targetDate = profile?.targetDate {
                    Divider().background(Theme.border)
                    HStack {
                        Text("TARGET DATE")
                            .font(Theme.label(10, weight: .bold))
                            .foregroundStyle(Theme.textTertiary)
                            .tracking(1.5)
                        Spacer()
                        Text(targetDate.formatted(.dateTime.month(.abbreviated).day().year()))
                            .font(Theme.mono(13))
                            .foregroundStyle(Theme.textPrimary)
                        let days = Calendar.current.dateComponents([.day], from: .now, to: targetDate).day ?? 0
                        Text("(\(days)d)")
                            .font(Theme.mono(11))
                            .foregroundStyle(days > 0 ? Theme.olive : Theme.danger)
                    }
                }
            }
        }
    }

    // MARK: - Weight Section

    private var weightSection: some View {
        VStack(spacing: Theme.spacingSM) {
            SectionHeader(title: "Body Weight") {
                showingLogWeight = true
            }

            TacticalCard {
                VStack(spacing: Theme.spacingSM) {
                    if weightEntries.count >= 2 {
                        Chart(weightEntries.prefix(60).reversed(), id: \.date) { entry in
                            LineMark(x: .value("Date", entry.date), y: .value("Wt", entry.weightLbs))
                                .foregroundStyle(Theme.olive)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                            AreaMark(x: .value("Date", entry.date), y: .value("Wt", entry.weightLbs))
                                .foregroundStyle(LinearGradient(colors: [Theme.olive.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom))
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisValueLabel().font(Theme.mono(9)).foregroundStyle(Theme.textTertiary)
                            }
                        }
                        .frame(height: 140)
                    .accessibilityLabel("Body weight trend chart")
                    } else {
                        Text("Log at least 2 weigh-ins to see trends")
                            .font(Theme.label(12))
                            .foregroundStyle(Theme.textTertiary)
                            .frame(maxWidth: .infinity, minHeight: 60)
                    }

                    HStack(spacing: Theme.spacingSM) {
                        TextField("", text: $newWeight, prompt: Text("Weight (lbs)").foregroundStyle(Theme.textTertiary))
                            .font(Theme.mono(15))
                            .foregroundStyle(Theme.textPrimary)
                            .keyboardType(.decimalPad)
                            .padding(10)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

                        Button {
                            if let w = Double(newWeight) {
                                let entry = WeightEntry(weightLbs: w)
                                context.insert(entry)
                                newWeight = ""
                                HapticService.success()
                            }
                        } label: {
                            Text("LOG")
                                .font(Theme.label(12, weight: .bold))
                                .foregroundStyle(Theme.amber)
                                .padding(.horizontal, Theme.spacingMD)
                                .padding(.vertical, 10)
                                .background(Theme.amber.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Macro Adherence

    private var macroAdherenceChart: some View {
        TacticalCard {
            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                Text("MACRO ADHERENCE (7-DAY)")
                    .font(Theme.label(10, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(1.5)

                let recentLogs = Array(logs.prefix(7))
                if recentLogs.count >= 2, let profile {
                    Chart(recentLogs, id: \.dateString) { log in
                        let target = Double(profile.calorieTarget)
                        let pct = target > 0 ? Double(log.totalCalories) / target : 0

                        BarMark(
                            x: .value("Day", String(log.dateString.suffix(5))),
                            y: .value("Pct", pct * 100)
                        )
                        .foregroundStyle(pct > 1.1 ? Theme.danger : (pct > 0.9 ? Theme.success : Theme.amber))
                        .cornerRadius(2)

                        RuleMark(y: .value("Target", 100))
                            .foregroundStyle(Theme.textTertiary)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisValueLabel().font(Theme.mono(9)).foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel().font(Theme.mono(8)).foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .frame(height: 120)
                    .accessibilityLabel("Macro adherence chart for last 7 days")
                } else {
                    Text("Log meals for at least 2 days")
                        .font(Theme.label(12))
                        .foregroundStyle(Theme.textTertiary)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
            }
        }
    }

    // MARK: - Workout Frequency

    private var workoutFrequencyChart: some View {
        TacticalCard {
            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                Text("WORKOUT FREQUENCY (4 WEEKS)")
                    .font(Theme.label(10, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(1.5)

                let weekData = computeWeeklyWorkouts()
                if !weekData.isEmpty {
                    Chart(weekData, id: \.week) { item in
                        BarMark(
                            x: .value("Week", item.week),
                            y: .value("Sessions", item.count)
                        )
                        .foregroundStyle(Theme.olive)
                        .cornerRadius(2)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisValueLabel().font(Theme.mono(9)).foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .frame(height: 100)
                    .accessibilityLabel("Workout frequency chart for last 4 weeks")
                } else {
                    Text("Complete workouts to see frequency data")
                        .font(Theme.label(12))
                        .foregroundStyle(Theme.textTertiary)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
            }
        }
    }

    private struct WeekWorkout {
        let week: String
        let count: Int
    }

    private func computeWeeklyWorkouts() -> [WeekWorkout] {
        var result: [WeekWorkout] = []
        for weekOffset in (0..<4).reversed() {
            let start = Calendar.current.date(byAdding: .weekOfYear, value: -weekOffset, to: .now)!
            let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: start)?.start ?? start
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!

            let descriptor = FetchDescriptor<WorkoutSession>(
                predicate: #Predicate { $0.date >= startOfWeek && $0.date < endOfWeek }
            )
            let count = (try? context.fetchCount(descriptor)) ?? 0
            let label = "W\(4 - weekOffset)"
            result.append(WeekWorkout(week: label, count: count))
        }
        return result
    }

    // MARK: - Export

    private var exportButton: some View {
        TacticalButton(title: "Export Data (CSV)", icon: "square.and.arrow.up", style: .ghost) {
            exportCSV()
        }
    }

    private func exportCSV() {
        var csv = "Date,Calories,Protein,Carbs,Fat,Water(oz),Workouts\n"
        for log in logs {
            let workoutCount = log.workoutSessions.count
            csv += "\(log.dateString),\(log.totalCalories),\(Int(log.totalProtein)),\(Int(log.totalCarbs)),\(Int(log.totalFat)),\(Int(log.waterIntakeOz)),\(workoutCount)\n"
        }

        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("achilles_export.csv")
        try? csv.write(to: tmpURL, atomically: true, encoding: .utf8)

        let activityVC = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
