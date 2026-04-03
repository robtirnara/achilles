import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    @State private var name = ""
    @State private var age = 25
    @State private var sex: BiologicalSex = .male
    @State private var weightLbs: Double = 170
    @State private var heightFeet = 5
    @State private var heightInches = 10
    @State private var goal: FitnessGoal = .recomp
    @State private var activityLevel: ActivityLevel = .moderate
    @State private var waterTargetOz: Double = 128
    @State private var supplements: [SupplementConfig] = []
    @State private var newSuppName = ""
    @State private var newSuppDosage = ""
    @State private var loaded = false
    @State private var showingResetConfirm = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    settingsGroup("PROFILE") {
                        editField("NAME") {
                            TextField("", text: $name, prompt: Text("Name").foregroundStyle(Theme.textTertiary))
                                .font(Theme.mono(15))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        editField("AGE") {
                            Stepper("\(age)", value: $age, in: 13...99)
                                .font(Theme.mono(15))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        editField("SEX") {
                            Picker("Sex", selection: $sex) {
                                ForEach(BiologicalSex.allCases, id: \.self) { s in
                                    Text(s.rawValue).tag(s)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    settingsGroup("BODY") {
                        editField("WEIGHT (LBS)") {
                            HStack {
                                Text("\(Int(weightLbs))")
                                    .font(Theme.mono(18, weight: .bold))
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                            }
                            Slider(value: $weightLbs, in: 80...400, step: 1)
                                .tint(Theme.amber)
                        }
                    }

                    settingsGroup("GOAL") {
                        Picker("Goal", selection: $goal) {
                            ForEach(FitnessGoal.allCases, id: \.self) { g in
                                Text(g.rawValue).tag(g)
                            }
                        }
                        .pickerStyle(.segmented)

                        Picker("Activity", selection: $activityLevel) {
                            ForEach(ActivityLevel.allCases, id: \.self) { l in
                                Text(l.rawValue).tag(l)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    settingsGroup("HYDRATION") {
                        editField("DAILY WATER TARGET (OZ)") {
                            HStack {
                                Text("\(Int(waterTargetOz))")
                                    .font(Theme.mono(18, weight: .bold))
                                    .foregroundStyle(Theme.waterColor)
                                Spacer()
                            }
                            Slider(value: $waterTargetOz, in: 32...256, step: 8)
                                .tint(Theme.waterColor)
                        }
                    }

                    settingsGroup("SUPPLEMENTS") {
                        ForEach(supplements) { supp in
                            HStack {
                                Text(supp.name)
                                    .font(Theme.label(13))
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Text(supp.dosage)
                                    .font(Theme.mono(11))
                                    .foregroundStyle(Theme.textSecondary)
                                Button {
                                    supplements.removeAll { $0.id == supp.id }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Theme.textTertiary)
                                }
                                .accessibilityLabel("Remove \(supp.name)")
                            }
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
                            }
                            .accessibilityLabel("Add supplement")
                        }
                    }

                    macroPreview

                    TacticalButton(title: "Save Changes", icon: "checkmark.circle") {
                        saveChanges()
                    }

                    settingsGroup("DANGER ZONE") {
                        TacticalButton(title: "Reset All Data", icon: "exclamationmark.triangle", style: .danger) {
                            showingResetConfirm = true
                        }
                    }
                    .padding(.top, Theme.spacingLG)
                }
                .padding(Theme.spacingMD)
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Reset All Data?",
                isPresented: $showingResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Everything & Start Over", role: .destructive) {
                    resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your profile, all logs, workouts, and nutrition data. You will be returned to the setup screen.")
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SETTINGS")
                        .font(Theme.heading(16))
                        .foregroundStyle(Theme.textPrimary)
                        .tracking(2)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .onAppear { loadFromProfile() }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Macro Preview

    private var macroPreview: some View {
        let totalInches = Double(heightFeet * 12 + heightInches)
        let result = MacroCalculator.calculate(
            sex: sex, weightLbs: weightLbs, heightInches: totalInches,
            age: age, activityLevel: activityLevel, goal: goal
        )

        return TacticalCard {
            VStack(spacing: Theme.spacingSM) {
                Text("RECALCULATED TARGETS")
                    .font(Theme.label(10, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(1.5)
                HStack {
                    StatReadout(label: "Calories", value: "\(result.calories)", unit: "cal", color: Theme.amber)
                    Spacer()
                    StatReadout(label: "Protein", value: "\(result.protein)", unit: "g", color: Theme.proteinColor)
                    Spacer()
                    StatReadout(label: "Carbs", value: "\(result.carbs)", unit: "g", color: Theme.carbsColor)
                    Spacer()
                    StatReadout(label: "Fat", value: "\(result.fat)", unit: "g", color: Theme.fatColor)
                }
            }
        }
    }

    // MARK: - Helpers

    private func settingsGroup<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text(title)
                .font(Theme.label(10, weight: .bold))
                .foregroundStyle(Theme.textTertiary)
                .tracking(1.5)
            content()
        }
    }

    private func editField<C: View>(_ label: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Theme.label(9, weight: .bold))
                .foregroundStyle(Theme.textTertiary)
                .tracking(1)
            content()
        }
    }

    private func loadFromProfile() {
        guard !loaded, let p = profile else { return }
        name = p.name
        age = p.age
        sex = p.sex
        weightLbs = p.weightLbs
        let totalInches = Int(p.heightInches)
        heightFeet = totalInches / 12
        heightInches = totalInches % 12
        goal = p.goal
        activityLevel = p.activityLevel
        waterTargetOz = p.waterTargetOz
        supplements = p.dailySupplements
        loaded = true
    }

    private func saveChanges() {
        guard let p = profile else { return }
        let totalInches = Double(heightFeet * 12 + heightInches)
        let result = MacroCalculator.calculate(
            sex: sex, weightLbs: weightLbs, heightInches: totalInches,
            age: age, activityLevel: activityLevel, goal: goal
        )

        p.name = name
        p.age = age
        p.sex = sex
        p.weightLbs = weightLbs
        p.heightInches = totalInches
        p.goal = goal
        p.activityLevel = activityLevel
        p.tdee = result.tdee
        p.calorieTarget = result.calories
        p.proteinTarget = result.protein
        p.carbsTarget = result.carbs
        p.fatTarget = result.fat
        p.waterTargetOz = waterTargetOz
        p.dailySupplements = supplements

        HapticService.success()
        dismiss()
    }

    private func resetAllData() {
        do {
            try context.delete(model: DailyLog.self)
            try context.delete(model: CustomFood.self)
            try context.delete(model: WeightEntry.self)
            try context.delete(model: UserProfile.self)
            try context.save()
        } catch {
            print("Reset failed: \(error)")
        }
        dismiss()
    }
}
