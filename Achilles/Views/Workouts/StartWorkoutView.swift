import SwiftUI
import SwiftData

struct StartWorkoutView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let dailyLog: DailyLog?

    @State private var workoutName = ""
    @State private var sets: [SetInput] = []
    @State private var startTime = Date()

    @State private var exerciseMode: ExercisePickMode = .search
    @State private var searchText = ""
    @State private var selectedMuscleGroup = "All"
    @State private var exerciseName = ""
    @State private var selectedExercise: CatalogExercise?
    @State private var showInstructions = false
    @State private var reps = ""
    @State private var weight = ""

    enum ExercisePickMode: String, CaseIterable {
        case search = "Search"
        case manual = "Manual"
    }

    struct SetInput: Identifiable {
        let id = UUID()
        var exerciseName: String
        var setNumber: Int
        var reps: Int
        var weight: Double
    }

    private var searchResults: [CatalogExercise] {
        CatalogService.shared.searchExercises(query: searchText, muscleGroup: selectedMuscleGroup)
    }

    private var hasExerciseSelected: Bool {
        !exerciseName.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingMD) {
                    sessionNameField
                    Divider().background(Theme.border)
                    if !sets.isEmpty { exerciseLog }
                    addExerciseSection
                    Spacer(minLength: Theme.spacingLG)
                    if !sets.isEmpty {
                        TacticalButton(title: "Complete Session", icon: "checkmark.circle") {
                            saveSession()
                        }
                    }
                }
                .padding(Theme.spacingMD)
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("LOG WORKOUT")
                        .font(Theme.heading(16))
                        .foregroundStyle(Theme.textPrimary)
                        .tracking(2)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }

    // MARK: - Session Name

    private var sessionNameField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SESSION NAME")
                .font(Theme.label(9, weight: .bold))
                .foregroundStyle(Theme.textTertiary)
                .tracking(1.2)
            TextField("", text: $workoutName, prompt: Text("e.g. Push Day, Upper Body").foregroundStyle(Theme.textTertiary))
                .font(Theme.mono(16))
                .foregroundStyle(Theme.textPrimary)
                .padding(10)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
    }

    // MARK: - Logged Sets

    private var exerciseLog: some View {
        let grouped = Dictionary(grouping: sets, by: \.exerciseName)

        return VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("LOGGED SETS")
                .font(Theme.label(10, weight: .bold))
                .foregroundStyle(Theme.textTertiary)
                .tracking(1.5)

            ForEach(Array(grouped.keys.sorted()), id: \.self) { name in
                VStack(alignment: .leading, spacing: 4) {
                    Text(name.uppercased())
                        .font(Theme.label(12, weight: .bold))
                        .foregroundStyle(Theme.amber)
                        .tracking(0.8)

                    ForEach(grouped[name]!) { set in
                        HStack {
                            Text("Set \(set.setNumber)")
                                .font(Theme.mono(12))
                                .foregroundStyle(Theme.textTertiary)
                                .frame(width: 50, alignment: .leading)
                            Text("\(set.reps) reps")
                                .font(Theme.mono(13, weight: .bold))
                                .foregroundStyle(Theme.textPrimary)
                            Text("× \(Int(set.weight)) lbs")
                                .font(Theme.mono(13))
                                .foregroundStyle(Theme.textSecondary)
                            Spacer()
                        }
                    }
                }
                .padding(Theme.spacingSM)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            }
        }
    }

    // MARK: - Add Exercise Section

    private var addExerciseSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("ADD EXERCISE")
                .font(Theme.label(10, weight: .bold))
                .foregroundStyle(Theme.textTertiary)
                .tracking(1.5)

            Picker("Mode", selection: $exerciseMode) {
                ForEach(ExercisePickMode.allCases, id: \.self) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: exerciseMode) { _, _ in
                clearExerciseSelection()
            }

            switch exerciseMode {
            case .search:
                exerciseSearchContent
            case .manual:
                manualExerciseField
            }

            if hasExerciseSelected {
                selectedExerciseHeader
                if let ex = selectedExercise, !ex.instructions.isEmpty {
                    instructionsHint(ex)
                }
                setInputFields
            }
        }
    }

    // MARK: - Search Mode

    private var exerciseSearchContent: some View {
        VStack(spacing: Theme.spacingSM) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.textTertiary)
                TextField("", text: $searchText, prompt: Text("Search exercises...").foregroundStyle(Theme.textTertiary))
                    .font(Theme.label(14))
                    .foregroundStyle(Theme.textPrimary)
                    .textInputAutocapitalization(.never)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(12)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

            muscleGroupChips

            if !hasExerciseSelected {
                exerciseResultsList
            }
        }
    }

    // MARK: - Muscle Group Chips

    private var muscleGroupChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(CatalogService.exerciseMuscleGroups, id: \.self) { group in
                    Button {
                        HapticService.selection()
                        selectedMuscleGroup = group
                    } label: {
                        Text(group.uppercased())
                            .font(Theme.label(10, weight: .bold))
                            .foregroundStyle(selectedMuscleGroup == group ? Theme.background : Theme.textSecondary)
                            .tracking(0.6)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedMuscleGroup == group ? Theme.olive : Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                    .strokeBorder(selectedMuscleGroup == group ? Theme.olive : Theme.border, lineWidth: 0.5)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Exercise Results List

    private var exerciseResultsList: some View {
        let results = searchResults

        return VStack(spacing: 1) {
            if results.isEmpty {
                HStack {
                    Text("No exercises found")
                        .font(Theme.label(13))
                        .foregroundStyle(Theme.textTertiary)
                    Spacer()
                }
                .padding(Theme.spacingMD)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
            } else {
                ForEach(results.prefix(20)) { exercise in
                    Button {
                        selectExercise(exercise)
                    } label: {
                        exerciseRow(exercise)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
    }

    private func exerciseRow(_ exercise: CatalogExercise) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(Theme.label(14))
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: 6) {
                    Text(exercise.muscleGroup)
                        .font(Theme.label(11))
                        .foregroundStyle(Theme.olive)
                    Text("·")
                        .foregroundStyle(Theme.textTertiary)
                    Text(exercise.equipment)
                        .font(Theme.label(11))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            Spacer()
            Text(exercise.difficulty)
                .font(Theme.mono(9))
                .foregroundStyle(Theme.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 2))
        }
        .padding(Theme.spacingSM)
        .background(Theme.surface)
    }

    // MARK: - Manual Mode

    private var manualExerciseField: some View {
        TextField("", text: $exerciseName, prompt: Text("Exercise name").foregroundStyle(Theme.textTertiary))
            .font(Theme.label(14))
            .foregroundStyle(Theme.textPrimary)
            .padding(10)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }

    // MARK: - Selected Exercise Header

    private var selectedExerciseHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("EXERCISE")
                    .font(Theme.label(9, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(1)
                Text(exerciseName)
                    .font(Theme.label(15, weight: .bold))
                    .foregroundStyle(Theme.amber)
            }
            Spacer()
            if exerciseMode == .search {
                Button {
                    clearExerciseSelection()
                } label: {
                    Text("CHANGE")
                        .font(Theme.label(10, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(0.8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }
            }
        }
        .padding(Theme.spacingSM)
        .background(Theme.olive.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .strokeBorder(Theme.olive.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Instructions Hint

    private func instructionsHint(_ exercise: CatalogExercise) -> some View {
        Button {
            withAnimation(Theme.snapAnimation) { showInstructions.toggle() }
        } label: {
            VStack(alignment: .leading, spacing: showInstructions ? 6 : 0) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundStyle(Theme.textTertiary)
                    Text("HOW TO PERFORM")
                        .font(Theme.label(9, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1)
                    Spacer()
                    Image(systemName: showInstructions ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(Theme.textTertiary)
                }
                if showInstructions {
                    Text(exercise.instructions)
                        .font(Theme.label(12))
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(Theme.spacingSM)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
    }

    // MARK: - Set Input Fields

    private var setInputFields: some View {
        VStack(spacing: Theme.spacingSM) {
            HStack(spacing: Theme.spacingSM) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("REPS")
                        .font(Theme.label(9, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1)
                    TextField("", text: $reps, prompt: Text("0").foregroundStyle(Theme.textTertiary))
                        .font(Theme.mono(16))
                        .foregroundStyle(Theme.textPrimary)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("WEIGHT (LBS)")
                        .font(Theme.label(9, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1)
                    TextField("", text: $weight, prompt: Text("0").foregroundStyle(Theme.textTertiary))
                        .font(Theme.mono(16))
                        .foregroundStyle(Theme.textPrimary)
                        .keyboardType(.decimalPad)
                        .padding(10)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }
            }

            TacticalButton(title: "Add Set", icon: "plus", style: .secondary) {
                addSet()
            }
        }
    }

    // MARK: - Actions

    private func selectExercise(_ exercise: CatalogExercise) {
        exerciseName = exercise.name
        selectedExercise = exercise
        showInstructions = false
        HapticService.selection()
    }

    private func clearExerciseSelection() {
        exerciseName = ""
        selectedExercise = nil
        showInstructions = false
    }

    private func addSet() {
        guard !exerciseName.isEmpty else { return }
        let setNumber = sets.filter { $0.exerciseName == exerciseName }.count + 1
        sets.append(SetInput(
            exerciseName: exerciseName,
            setNumber: setNumber,
            reps: Int(reps) ?? 0,
            weight: Double(weight) ?? 0
        ))
        reps = ""
        weight = ""
        HapticService.impact(.light)
    }

    private func saveSession() {
        let duration = Int(Date().timeIntervalSince(startTime) / 60)
        let session = WorkoutSession(
            name: workoutName.isEmpty ? "Workout" : workoutName,
            durationMinutes: max(duration, 1)
        )
        session.dailyLog = dailyLog
        context.insert(session)

        for s in sets {
            let exerciseSet = ExerciseSet(
                exerciseName: s.exerciseName,
                setNumber: s.setNumber,
                reps: s.reps,
                weight: s.weight
            )
            exerciseSet.workoutSession = session
            context.insert(exerciseSet)
        }

        HapticService.success()
        dismiss()
    }
}
