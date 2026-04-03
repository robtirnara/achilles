import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @Query(sort: \WeightEntry.date, order: .reverse) private var weightEntries: [WeightEntry]
    @State private var todayLog: DailyLog?

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavBarBrand(tabName: "HQ")
                ScrollView {
                    VStack(spacing: Theme.spacingMD) {
                        greetingHeader
                        calorieCard
                        macroRingsCard
                        waterCard
                        HStack(spacing: Theme.spacingMD) {
                            streakCard
                            weightCard
                        }
                        quickActions
                        weightChartCard
                    }
                    .padding(Theme.spacingMD)
                }
            }
            .background(Theme.background)
            .navigationBarHidden(true)
            .onAppear { loadTodayLog() }
        }
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingText)
                    .font(Theme.label(12))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(1)
                Text(profile?.name ?? "Operator")
                    .font(Theme.heading(24))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            Text(Date.now.formatted(.dateTime.month(.abbreviated).day()))
                .font(Theme.mono(14))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 0..<6: return "LATE OPS"
        case 6..<12: return "GOOD MORNING"
        case 12..<17: return "GOOD AFTERNOON"
        default: return "GOOD EVENING"
        }
    }

    // MARK: - Calorie Card

    private var calorieCard: some View {
        let consumed = todayLog?.totalCalories ?? 0
        let target = profile?.calorieTarget ?? 2400
        let progress = target > 0 ? Double(consumed) / Double(target) : 0

        return TacticalCard {
            VStack(spacing: Theme.spacingMD) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CALORIES")
                            .font(Theme.label(10, weight: .bold))
                            .foregroundStyle(Theme.textTertiary)
                            .tracking(1.5)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(consumed)")
                                .font(Theme.mono(32, weight: .bold))
                                .foregroundStyle(Theme.textPrimary)
                            Text("/ \(target)")
                                .font(Theme.mono(16))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    Spacer()
                    RingProgress(
                        progress: progress,
                        color: progress > 1.0 ? Theme.danger : Theme.amber,
                        lineWidth: 6,
                        size: 56
                    )
                    .accessibilityLabel("Calorie progress")
                    .accessibilityValue("\(consumed) of \(target) calories")
                }
                TacticalProgressBar(
                    progress: progress,
                    color: progress > 1.0 ? Theme.danger : Theme.amber
                )
                .accessibilityHidden(true)
            }
        }
    }

    // MARK: - Macro Rings

    private var macroRingsCard: some View {
        TacticalCard {
            MacroRingTrio(
                protein: todayLog?.totalProtein ?? 0,
                carbs: todayLog?.totalCarbs ?? 0,
                fat: todayLog?.totalFat ?? 0,
                proteinTarget: Double(profile?.proteinTarget ?? 170),
                carbsTarget: Double(profile?.carbsTarget ?? 250),
                fatTarget: Double(profile?.fatTarget ?? 67)
            )
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Water

    private var waterCard: some View {
        let intake = todayLog?.waterIntakeOz ?? 0
        let target = profile?.waterTargetOz ?? 128
        let progress = target > 0 ? intake / target : 0

        return TacticalCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HYDRATION")
                        .font(Theme.label(10, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1.5)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(intake))")
                            .font(Theme.mono(22, weight: .bold))
                            .foregroundStyle(Theme.waterColor)
                        Text("/ \(Int(target)) oz")
                            .font(Theme.mono(13))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer()
                RingProgress(progress: progress, color: Theme.waterColor, lineWidth: 5, size: 44)
                    .accessibilityLabel("Water progress")
                    .accessibilityValue("\(Int(intake)) of \(Int(target)) ounces")
            }
        }
    }

    // MARK: - Streak & Weight

    private var streakCard: some View {
        let streak = DailyLogService.streakCount(context: context)
        return TacticalCard {
            VStack(spacing: 4) {
                Text("\(streak)")
                    .font(Theme.mono(28, weight: .bold))
                    .foregroundStyle(Theme.amber)
                Text("DAY STREAK")
                    .font(Theme.label(9, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var weightCard: some View {
        TacticalCard {
            VStack(spacing: 4) {
                if let latest = weightEntries.first {
                    Text(String(format: "%.1f", latest.weightLbs))
                        .font(Theme.mono(28, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("LBS")
                        .font(Theme.label(9, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1)
                } else {
                    Text("--")
                        .font(Theme.mono(28, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                    Text("NO WEIGH-IN")
                        .font(Theme.label(9, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        HStack(spacing: Theme.spacingMD) {
            NavigationLink {
                FuelView()
            } label: {
                quickActionTile(icon: "plus.circle", label: "LOG MEAL")
            }
            NavigationLink {
                OpsView()
            } label: {
                quickActionTile(icon: "bolt.circle", label: "START WORKOUT")
            }
        }
    }

    private func quickActionTile(icon: String, label: String) -> some View {
        VStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(Theme.amber)
                .accessibilityHidden(true)
            Text(label)
                .font(Theme.label(10, weight: .bold))
                .foregroundStyle(Theme.textSecondary)
                .tracking(1)
        }
        .accessibilityElement(children: .combine)
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingMD)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .strokeBorder(Theme.border, lineWidth: 0.5)
        )
    }

    // MARK: - Weight Chart

    private var weightChartCard: some View {
        TacticalCard {
            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                Text("WEIGHT TREND")
                    .font(Theme.label(10, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(1.5)

                if weightEntries.count >= 2 {
                    Chart(weightEntries.prefix(30).reversed(), id: \.date) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weightLbs)
                        )
                        .foregroundStyle(Theme.olive)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weightLbs)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.olive.opacity(0.3), .clear],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisValueLabel()
                                .font(Theme.mono(9))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .frame(height: 120)
                    .accessibilityLabel("Weight trend chart for last 30 entries")
                } else {
                    Text("Log weight entries to see trends")
                        .font(Theme.label(12))
                        .foregroundStyle(Theme.textTertiary)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
            }
        }
    }

    private func loadTodayLog() {
        todayLog = DailyLogService.getOrCreateLog(for: .now, context: context)
    }
}
