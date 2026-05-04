import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @State private var step = 0
    @State private var name = ""
    @State private var age = 25
    @State private var sex: BiologicalSex = .male
    @State private var weightLbs: Double = 170
    @State private var heightFeet = 5
    @State private var heightInches = 10
    @State private var bodyFatPercent: Double? = nil
    @State private var goal: FitnessGoal = .recomp
    @State private var targetDate: Date? = nil
    @State private var hasDeadline = false
    @State private var activityLevel: ActivityLevel = .moderate
    @State private var waterTargetOz: Double = 128
    @State private var supplements: [SupplementConfig] = []
    @State private var newSuppName = ""
    @State private var newSuppDosage = ""

    private let totalSteps = 8

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                stepIndicator
                    .padding(.top, Theme.spacingMD)

                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    profileStep.tag(1)
                    bodyMetricsStep.tag(2)
                    goalStep.tag(3)
                    timelineStep.tag(4)
                    activityStep.tag(5)
                    hydrationStep.tag(6)
                    summaryStep.tag(7)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(Theme.snapAnimation, value: step)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(i <= step ? Theme.amber : Theme.border)
                    .frame(height: 2)
            }
        }
        .padding(.horizontal, Theme.spacingLG)
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()

            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)

            Text("ACHILLES HQ")
                .font(Theme.heading(42))
                .foregroundStyle(Theme.textPrimary)
                .tracking(8)

            Text("MACRO & WORKOUT TRACKER")
                .font(Theme.label(12, weight: .semibold))
                .foregroundStyle(Theme.amber)
                .tracking(3)

            Spacer()

            Text("Track your fuel. Execute your mission.\nResults follow discipline.")
                .font(Theme.label(15))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()

            TacticalButton(title: "Begin Assessment", icon: "chevron.right") {
                HapticService.impact(.medium)
                withAnimation { step = 1 }
            }
            .padding(.horizontal, Theme.spacingLG)
            .padding(.bottom, Theme.spacingXL)
        }
    }

    // MARK: - Step 1: Profile

    private var profileStep: some View {
        stepContainer(title: "PROFILE", subtitle: "Basic identification") {
            VStack(spacing: Theme.spacingLG) {
                fieldGroup("CALL SIGN") {
                    TextField("", text: $name, prompt: Text("Your name").foregroundStyle(Theme.textTertiary))
                        .font(Theme.mono(18))
                        .foregroundStyle(Theme.textPrimary)
                        .textInputAutocapitalization(.words)
                        .padding(12)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }

                fieldGroup("AGE") {
                    Stepper(value: $age, in: 13...99) {
                        Text("\(age)")
                            .font(Theme.mono(24, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .tint(Theme.amber)
                }

                fieldGroup("BIOLOGICAL SEX") {
                    Picker("Sex", selection: $sex) {
                        ForEach(BiologicalSex.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }

    // MARK: - Step 2: Body Metrics

    private var bodyMetricsStep: some View {
        stepContainer(title: "BODY METRICS", subtitle: "Current measurements") {
            VStack(spacing: Theme.spacingLG) {
                fieldGroup("WEIGHT (LBS)") {
                    HStack {
                        Text("\(Int(weightLbs))")
                            .font(Theme.mono(28, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text("lbs")
                            .font(Theme.mono(14))
                            .foregroundStyle(Theme.textSecondary)
                        Spacer()
                    }
                    Slider(value: $weightLbs, in: 80...400, step: 1)
                        .tint(Theme.amber)
                }

                fieldGroup("HEIGHT") {
                    HStack(spacing: Theme.spacingMD) {
                        Picker("Feet", selection: $heightFeet) {
                            ForEach(4...7, id: \.self) { f in Text("\(f) ft").tag(f) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 100)

                        Picker("Inches", selection: $heightInches) {
                            ForEach(0...11, id: \.self) { i in Text("\(i) in").tag(i) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 100)
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Goal

    private var goalStep: some View {
        stepContainer(title: "MISSION OBJECTIVE", subtitle: "Select your primary goal") {
            VStack(spacing: Theme.spacingSM) {
                ForEach(FitnessGoal.allCases, id: \.self) { g in
                    Button {
                        HapticService.selection()
                        goal = g
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(g.rawValue.uppercased())
                                    .font(Theme.label(15, weight: .bold))
                                    .foregroundStyle(goal == g ? Theme.amber : Theme.textPrimary)
                                Text(g.tagline)
                                    .font(Theme.label(12))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                            if goal == g {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.amber)
                            }
                        }
                        .padding(Theme.spacingMD)
                        .background(goal == g ? Theme.olive.opacity(0.15) : Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                .strokeBorder(goal == g ? Theme.olive : Theme.border, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Step 4: Timeline

    private var timelineStep: some View {
        stepContainer(title: "TIMELINE", subtitle: "Set your target date") {
            VStack(spacing: Theme.spacingLG) {
                Toggle(isOn: $hasDeadline) {
                    Text("SET A DEADLINE")
                        .font(Theme.label(13, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .tracking(1)
                }
                .tint(Theme.amber)

                if hasDeadline {
                    DatePicker(
                        "Target Date",
                        selection: Binding(get: { targetDate ?? .now.addingTimeInterval(86400 * 90) },
                                          set: { targetDate = $0 }),
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(Theme.amber)
                    .colorScheme(.dark)
                } else {
                    TacticalCard {
                        HStack {
                            Image(systemName: "infinity")
                                .font(.title2)
                                .foregroundStyle(Theme.olive)
                            Text("No deadline — continuous improvement")
                                .font(Theme.label(14))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 5: Activity Level

    private var activityStep: some View {
        stepContainer(title: "ACTIVITY LEVEL", subtitle: "Your typical weekly activity") {
            VStack(spacing: Theme.spacingSM) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    Button {
                        HapticService.selection()
                        activityLevel = level
                    } label: {
                        HStack {
                            Text(level.rawValue.uppercased())
                                .font(Theme.label(14, weight: .bold))
                                .foregroundStyle(activityLevel == level ? Theme.amber : Theme.textPrimary)
                            Spacer()
                            Text("×\(String(format: "%.2f", level.multiplier))")
                                .font(Theme.mono(13))
                                .foregroundStyle(Theme.textSecondary)
                            if activityLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.amber)
                            }
                        }
                        .padding(Theme.spacingMD)
                        .background(activityLevel == level ? Theme.olive.opacity(0.15) : Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                .strokeBorder(activityLevel == level ? Theme.olive : Theme.border, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Step 6: Hydration & Supplements

    private var hydrationStep: some View {
        stepContainer(title: "HYDRATION & SUPPLEMENTS", subtitle: "Daily targets") {
            VStack(spacing: Theme.spacingLG) {
                fieldGroup("DAILY WATER TARGET") {
                    HStack {
                        Text("\(Int(waterTargetOz))")
                            .font(Theme.mono(28, weight: .bold))
                            .foregroundStyle(Theme.waterColor)
                        Text("oz")
                            .font(Theme.mono(14))
                            .foregroundStyle(Theme.textSecondary)
                        Spacer()
                    }
                    Slider(value: $waterTargetOz, in: 32...256, step: 8)
                        .tint(Theme.waterColor)
                }

                fieldGroup("SUPPLEMENT STACK") {
                    VStack(spacing: Theme.spacingSM) {
                        ForEach(supplements) { supp in
                            HStack {
                                Text(supp.name)
                                    .font(Theme.label(14))
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Text(supp.dosage)
                                    .font(Theme.mono(12))
                                    .foregroundStyle(Theme.textSecondary)
                                Button {
                                    supplements.removeAll { $0.id == supp.id }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Theme.textTertiary)
                                }
                                .accessibilityLabel("Remove \(supp.name)")
                            }
                            .padding(Theme.spacingSM)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        }

                        HStack(spacing: Theme.spacingSM) {
                            TextField("", text: $newSuppName, prompt: Text("Name").foregroundStyle(Theme.textTertiary))
                                .font(Theme.label(13))
                                .foregroundStyle(Theme.textPrimary)
                                .padding(8)
                                .background(Theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

                            TextField("", text: $newSuppDosage, prompt: Text("Dose").foregroundStyle(Theme.textTertiary))
                                .font(Theme.label(13))
                                .foregroundStyle(Theme.textPrimary)
                                .frame(width: 80)
                                .padding(8)
                                .background(Theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

                            Button {
                                guard !newSuppName.isEmpty else { return }
                                supplements.append(SupplementConfig(name: newSuppName, dosage: newSuppDosage))
                                newSuppName = ""
                                newSuppDosage = ""
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(Theme.amber)
                                    .font(.title3)
                            }
                            .accessibilityLabel("Add supplement")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 7: Summary

    private var summaryStep: some View {
        let totalInches = Double(heightFeet * 12 + heightInches)
        let result = MacroCalculator.calculate(
            sex: sex, weightLbs: weightLbs, heightInches: totalInches,
            age: age, activityLevel: activityLevel, goal: goal
        )

        return stepContainer(title: "MISSION BRIEF", subtitle: "Review your plan") {
            VStack(spacing: Theme.spacingLG) {
                TacticalCard {
                    VStack(spacing: Theme.spacingMD) {
                        HStack {
                            StatReadout(label: "TDEE", value: "\(result.tdee)", unit: "cal")
                            Spacer()
                            StatReadout(label: "Target", value: "\(result.calories)", unit: "cal", color: Theme.amber)
                        }
                        Divider().background(Theme.border)
                        HStack {
                            StatReadout(label: "Protein", value: "\(result.protein)", unit: "g", color: Theme.proteinColor)
                            Spacer()
                            StatReadout(label: "Carbs", value: "\(result.carbs)", unit: "g", color: Theme.carbsColor)
                            Spacer()
                            StatReadout(label: "Fat", value: "\(result.fat)", unit: "g", color: Theme.fatColor)
                        }
                    }
                }

                TacticalCard {
                    HStack {
                        StatReadout(label: "Water", value: "\(Int(waterTargetOz))", unit: "oz", color: Theme.waterColor)
                        Spacer()
                        StatReadout(label: "Supplements", value: "\(supplements.count)", unit: "daily")
                    }
                }

                TacticalCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("GOAL")
                                .font(Theme.label(10, weight: .semibold))
                                .foregroundStyle(Theme.textTertiary)
                                .tracking(1.2)
                            Text(goal.rawValue.uppercased())
                                .font(Theme.heading(18))
                                .foregroundStyle(Theme.amber)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("ACTIVITY")
                                .font(Theme.label(10, weight: .semibold))
                                .foregroundStyle(Theme.textTertiary)
                                .tracking(1.2)
                            Text(activityLevel.rawValue)
                                .font(Theme.label(14, weight: .semibold))
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                }

                TacticalButton(title: "Deploy", icon: "bolt.fill") {
                    saveProfile(result: result)
                }
            }
        }
    }

    // MARK: - Helpers

    private func stepContainer<C: View>(title: String, subtitle: String, @ViewBuilder content: () -> C) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingLG) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.heading(28))
                        .foregroundStyle(Theme.textPrimary)
                    Text(subtitle)
                        .font(Theme.label(14))
                        .foregroundStyle(Theme.textSecondary)
                }

                content()

                Spacer(minLength: Theme.spacingLG)

                if step < totalSteps - 1 {
                    TacticalButton(title: "Continue", icon: "chevron.right") {
                        HapticService.impact(.light)
                        withAnimation { step += 1 }
                    }
                }
            }
            .padding(Theme.spacingLG)
        }
    }

    private func fieldGroup<C: View>(_ label: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text(label)
                .font(Theme.label(10, weight: .bold))
                .foregroundStyle(Theme.textTertiary)
                .tracking(1.5)
            content()
        }
    }

    private func saveProfile(result: MacroCalculator.MacroResult) {
        let totalInches = Double(heightFeet * 12 + heightInches)
        let profile = UserProfile(
            name: name.isEmpty ? "Operator" : name,
            age: age,
            sex: sex,
            weightLbs: weightLbs,
            heightInches: totalInches,
            bodyFatPercent: bodyFatPercent,
            goal: goal,
            activityLevel: activityLevel,
            targetDate: hasDeadline ? targetDate : nil,
            tdee: result.tdee,
            proteinTarget: result.protein,
            carbsTarget: result.carbs,
            fatTarget: result.fat,
            calorieTarget: result.calories,
            waterTargetOz: waterTargetOz,
            dailySupplements: supplements
        )
        context.insert(profile)
        HapticService.success()
    }
}
