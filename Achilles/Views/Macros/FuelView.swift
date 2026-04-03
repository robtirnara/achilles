import SwiftUI
import SwiftData

struct FuelView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @State private var selectedDate = Date()
    @State private var todayLog: DailyLog?
    @State private var showingAddEntry = false
    @State private var showingWaterLog = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavBarBrand(tabName: "FUEL", trailingContent: AnyView(
                    Button {
                        showingAddEntry = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.amber)
                    }
                    .accessibilityLabel("Add food entry")
                ))
                ScrollView {
                    VStack(spacing: Theme.spacingMD) {
                        DaySelector(selectedDate: $selectedDate)

                        calorieBar
                        macroProgressBars
                        macroAlertBanner
                        waterSection
                        supplementChecklist

                        ForEach(MealSlot.allCases, id: \.self) { slot in
                            mealSlotSection(slot)
                        }

                        stillHungryCard
                    }
                    .padding(.vertical, Theme.spacingMD)
                }
            }
            .background(Theme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddEntry) {
                AddFoodEntryView(dailyLog: todayLog)
                    .onDisappear { refreshLog() }
            }
            .sheet(isPresented: $showingWaterLog) {
                WaterLogSheet(dailyLog: todayLog, target: profile?.waterTargetOz ?? 128)
            }
            .onChange(of: selectedDate) { _, _ in refreshLog() }
            .onAppear { refreshLog() }
        }
    }

    // MARK: - Calorie Bar

    private var calorieBar: some View {
        let consumed = todayLog?.totalCalories ?? 0
        let target = profile?.calorieTarget ?? 2400
        let progress = target > 0 ? Double(consumed) / Double(target) : 0

        return TacticalCard {
            VStack(spacing: Theme.spacingSM) {
                HStack {
                    Text("CALORIES")
                        .font(Theme.label(10, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1.5)
                    Spacer()
                    Text("\(consumed) / \(target)")
                        .font(Theme.mono(14, weight: .bold))
                        .foregroundStyle(progress > 1 ? Theme.danger : Theme.textPrimary)
                }
                TacticalProgressBar(
                    progress: progress,
                    color: progress > 1 ? Theme.danger : Theme.amber
                )
            }
        }
        .padding(.horizontal, Theme.spacingMD)
    }

    // MARK: - Macro Progress Bars

    private var macroProgressBars: some View {
        TacticalCard {
            VStack(spacing: Theme.spacingSM) {
                macroBar("PROTEIN", value: todayLog?.totalProtein ?? 0, target: Double(profile?.proteinTarget ?? 170), color: Theme.proteinColor)
                macroBar("CARBS", value: todayLog?.totalCarbs ?? 0, target: Double(profile?.carbsTarget ?? 250), color: Theme.carbsColor)
                macroBar("FAT", value: todayLog?.totalFat ?? 0, target: Double(profile?.fatTarget ?? 67), color: Theme.fatColor)
            }
        }
        .padding(.horizontal, Theme.spacingMD)
    }

    private func macroBar(_ label: String, value: Double, target: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            HStack {
                Text(label)
                    .font(Theme.label(9, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(1)
                Spacer()
                Text("\(Int(value))/\(Int(target))g")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.textSecondary)
            }
            TacticalProgressBar(progress: target > 0 ? value / target : 0, color: color, height: 4)
        }
    }

    // MARK: - Macro Alert Banner

    @ViewBuilder
    private var macroAlertBanner: some View {
        if let profile, let log = todayLog {
            let calProgress = Double(log.totalCalories) / Double(profile.calorieTarget)
            let protProgress = profile.proteinTarget > 0 ? log.totalProtein / Double(profile.proteinTarget) : 0

            if calProgress > 1.0 {
                alertBanner(
                    "Calorie target exceeded by \(log.totalCalories - profile.calorieTarget) cal",
                    color: Theme.danger
                )
            } else if calProgress >= 0.95 {
                alertBanner(
                    "Nearly at calorie ceiling — \(profile.calorieTarget - log.totalCalories) cal remaining",
                    color: Theme.danger.opacity(0.8)
                )
            } else if calProgress >= 0.80 {
                alertBanner(
                    "Approaching calorie target — \(profile.calorieTarget - log.totalCalories) cal remaining",
                    color: Theme.amber
                )
            }

            if protProgress >= 0.80 && protProgress < 1.0 {
                alertBanner(
                    "Approaching protein target — \(Int(Double(profile.proteinTarget) - log.totalProtein))g remaining",
                    color: Theme.proteinColor
                )
            }
        }
    }

    private func alertBanner(_ text: String, color: Color) -> some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .accessibilityHidden(true)
            Text(text)
                .font(Theme.label(12, weight: .medium))
        }
        .accessibilityElement(children: .combine)
        .foregroundStyle(color)
        .padding(Theme.spacingSM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .padding(.horizontal, Theme.spacingMD)
    }

    // MARK: - Water Section

    private var waterSection: some View {
        let intake = todayLog?.waterIntakeOz ?? 0
        let target = profile?.waterTargetOz ?? 128

        return TacticalCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HYDRATION")
                        .font(Theme.label(10, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1.5)
                    Text("\(Int(intake)) / \(Int(target)) oz")
                        .font(Theme.mono(16, weight: .bold))
                        .foregroundStyle(Theme.waterColor)
                }
                Spacer()
                HStack(spacing: Theme.spacingSM) {
                    waterButton("+8oz", amount: 8)
                    waterButton("+16oz", amount: 16)
                }
                RingProgress(progress: target > 0 ? intake / target : 0, color: Theme.waterColor, lineWidth: 4, size: 36)
            }
        }
        .padding(.horizontal, Theme.spacingMD)
    }

    private func waterButton(_ label: String, amount: Double) -> some View {
        Button {
            todayLog?.waterIntakeOz += amount
            HapticService.impact(.light)
        } label: {
            Text(label)
                .font(Theme.mono(10, weight: .bold))
                .foregroundStyle(Theme.waterColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Theme.waterColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .accessibilityLabel("Add \(Int(amount)) ounces of water")
    }

    // MARK: - Supplement Checklist

    @ViewBuilder
    private var supplementChecklist: some View {
        if let supplements = profile?.dailySupplements, !supplements.isEmpty {
            TacticalCard {
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text("SUPPLEMENT STACK")
                        .font(Theme.label(10, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1.5)

                    ForEach(supplements) { supp in
                        let entry = todayLog?.supplementEntries.first(where: { $0.supplementName == supp.name })
                        let taken = entry?.taken ?? false

                    Button {
                        toggleSupplement(supp, currentlyTaken: taken, entry: entry)
                    } label: {
                        HStack {
                            Image(systemName: taken ? "checkmark.square.fill" : "square")
                                .foregroundStyle(taken ? Theme.success : Theme.textTertiary)
                            Text(supp.name)
                                .font(Theme.label(13))
                                .foregroundStyle(taken ? Theme.textSecondary : Theme.textPrimary)
                                .strikethrough(taken)
                            Spacer()
                            Text(supp.dosage)
                                .font(Theme.mono(11))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .accessibilityLabel("\(supp.name), \(supp.dosage)")
                    .accessibilityValue(taken ? "Taken" : "Not taken")
                    .accessibilityHint("Double tap to toggle")
                    }
                }
            }
            .padding(.horizontal, Theme.spacingMD)
        }
    }

    // MARK: - Meal Slot Sections

    private func mealSlotSection(_ slot: MealSlot) -> some View {
        let entries = (todayLog?.foodEntries ?? []).filter { $0.mealSlot == slot }.sorted { $0.timestamp < $1.timestamp }

        return VStack(alignment: .leading, spacing: Theme.spacingSM) {
            SectionHeader(title: slot.rawValue) {
                showingAddEntry = true
            }
            .padding(.horizontal, Theme.spacingMD)

            if entries.isEmpty {
                HStack {
                    Image(systemName: slot.icon)
                        .foregroundStyle(Theme.textTertiary)
                    Text("No entries")
                        .font(Theme.label(13))
                        .foregroundStyle(Theme.textTertiary)
                    Spacer()
                }
                .padding(Theme.spacingMD)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                .padding(.horizontal, Theme.spacingMD)
            } else {
                VStack(spacing: 1) {
                    ForEach(entries) { entry in
                        foodEntryRow(entry)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                .padding(.horizontal, Theme.spacingMD)
            }
        }
    }

    private func foodEntryRow(_ entry: FoodEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(Theme.label(14))
                    .foregroundStyle(Theme.textPrimary)
                if !entry.servingSize.isEmpty {
                    Text(entry.servingSize)
                        .font(Theme.label(11))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.calories) cal")
                    .font(Theme.mono(13, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text("P\(Int(entry.protein)) C\(Int(entry.carbs)) F\(Int(entry.fat))")
                    .font(Theme.mono(10))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(Theme.spacingMD)
        .background(Theme.surface)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                context.delete(entry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Still Hungry Card

    @ViewBuilder
    private var stillHungryCard: some View {
        if let profile, let log = todayLog {
            let remainingCal = profile.calorieTarget - log.totalCalories
            let remainingProtein = Double(profile.proteinTarget) - log.totalProtein

            if remainingCal > 100 {
                let suggestions = CatalogService.shared.foodsForRemainingMacros(
                    remainingCalories: remainingCal,
                    remainingProtein: remainingProtein,
                    goal: profile.goal
                ).prefix(5)

                if !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.spacingSM) {
                        SectionHeader(title: "Still Hungry?")
                            .padding(.horizontal, Theme.spacingMD)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.spacingSM) {
                                ForEach(Array(suggestions), id: \.id) { food in
                                    suggestionCard(food)
                                }
                            }
                            .padding(.horizontal, Theme.spacingMD)
                        }
                    }
                }
            }
        }
    }

    private func suggestionCard(_ food: CatalogFood) -> some View {
        Button {
            addFromCatalog(food)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(Theme.label(12, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text("\(food.calories) cal")
                    .font(Theme.mono(11, weight: .bold))
                    .foregroundStyle(Theme.amber)
                Text("P\(Int(food.protein)) C\(Int(food.carbs)) F\(Int(food.fat))")
                    .font(Theme.mono(9))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(Theme.spacingSM)
            .frame(width: 140, alignment: .leading)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .strokeBorder(Theme.border, lineWidth: 0.5)
            )
        }
    }

    // MARK: - Actions

    private func refreshLog() {
        todayLog = DailyLogService.getOrCreateLog(for: selectedDate, context: context)
    }

    private func toggleSupplement(_ config: SupplementConfig, currentlyTaken: Bool, entry: SupplementLogEntry?) {
        HapticService.impact(.light)
        if let entry {
            entry.taken.toggle()
        } else {
            let newEntry = SupplementLogEntry(supplementName: config.name, dosage: config.dosage, taken: true)
            newEntry.dailyLog = todayLog
            context.insert(newEntry)
        }
    }

    private func addFromCatalog(_ food: CatalogFood) {
        let entry = FoodEntry(
            name: food.name,
            calories: food.calories,
            protein: food.protein,
            carbs: food.carbs,
            fat: food.fat,
            servingSize: food.defaultServingSize,
            mealSlot: .snack,
            isFromCatalog: true
        )
        entry.dailyLog = todayLog
        context.insert(entry)
        HapticService.success()
    }
}
