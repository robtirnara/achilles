import SwiftUI
import SwiftData

struct AddFoodEntryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var customFoods: [CustomFood]

    let dailyLog: DailyLog?

    @State private var mode: EntryMode = .search
    @State private var searchText = ""
    @State private var selectedSlot: MealSlot = .lunch
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var servingSize = "1 serving"
    @State private var saveToMyFoods = false

    enum EntryMode: String, CaseIterable {
        case search = "Search"
        case manual = "Manual"
    }

    private var searchResults: [CatalogFood] {
        CatalogService.shared.searchFoods(query: searchText)
    }

    private var matchingCustomFoods: [CustomFood] {
        guard !searchText.isEmpty else { return customFoods }
        let q = searchText.lowercased()
        return customFoods.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                mealSlotPicker
                modePicker
                content
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ADD ENTRY")
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

    // MARK: - Meal Slot Picker

    private var mealSlotPicker: some View {
        Picker("Meal", selection: $selectedSlot) {
            ForEach(MealSlot.allCases, id: \.self) { slot in
                Text(slot.rawValue).tag(slot)
            }
        }
        .pickerStyle(.segmented)
        .padding(Theme.spacingMD)
    }

    // MARK: - Mode Picker

    private var modePicker: some View {
        Picker("Mode", selection: $mode) {
            ForEach(EntryMode.allCases, id: \.self) { m in
                Text(m.rawValue).tag(m)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, Theme.spacingMD)
        .padding(.bottom, Theme.spacingSM)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch mode {
        case .search:
            searchContent
        case .manual:
            manualContent
        }
    }

    // MARK: - Search Content

    private var searchContent: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.textTertiary)
                TextField("", text: $searchText, prompt: Text("Search foods, shakes, supplements...").foregroundStyle(Theme.textTertiary))
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
            .padding(.horizontal, Theme.spacingMD)

            List {
                if !matchingCustomFoods.isEmpty {
                    Section {
                        ForEach(matchingCustomFoods) { food in
                            Button {
                                addCustomFood(food)
                            } label: {
                                foodRow(name: food.name, cal: food.calories, p: food.protein, c: food.carbs, f: food.fat, serving: food.defaultServing)
                            }
                        }
                    } header: {
                        Text("MY FOODS")
                            .font(Theme.label(10, weight: .bold))
                            .foregroundStyle(Theme.amber)
                            .tracking(1.2)
                    }
                }

                Section {
                    ForEach(searchResults.prefix(50)) { food in
                        Button {
                            addCatalogFood(food)
                        } label: {
                            foodRow(name: food.name, cal: food.calories, p: food.protein, c: food.carbs, f: food.fat, serving: food.defaultServingSize, brand: food.brand)
                        }
                    }
                } header: {
                    Text("CATALOG")
                        .font(Theme.label(10, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1.2)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private func foodRow(name: String, cal: Int, p: Double, c: Double, f: Double, serving: String, brand: String? = nil) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(Theme.label(14))
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: 4) {
                    if let brand {
                        Text(brand)
                            .font(Theme.label(11))
                            .foregroundStyle(Theme.amber.opacity(0.7))
                    }
                    Text(serving)
                        .font(Theme.label(11))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(cal) cal")
                    .font(Theme.mono(12, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text("P\(Int(p)) C\(Int(c)) F\(Int(f))")
                    .font(Theme.mono(9))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .listRowBackground(Theme.surface)
    }

    // MARK: - Manual Content

    private var manualContent: some View {
        ScrollView {
            VStack(spacing: Theme.spacingMD) {
                manualField("FOOD NAME", text: $name, prompt: "e.g. Grilled Chicken Breast")
                manualField("SERVING SIZE", text: $servingSize, prompt: "e.g. 6oz, 1 cup")
                manualField("CALORIES", text: $calories, prompt: "0", keyboard: .numberPad)

                HStack(spacing: Theme.spacingSM) {
                    manualField("PROTEIN (g)", text: $protein, prompt: "0", keyboard: .decimalPad)
                    manualField("CARBS (g)", text: $carbs, prompt: "0", keyboard: .decimalPad)
                    manualField("FAT (g)", text: $fat, prompt: "0", keyboard: .decimalPad)
                }

                Toggle(isOn: $saveToMyFoods) {
                    Text("SAVE TO MY FOODS")
                        .font(Theme.label(11, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(1)
                }
                .tint(Theme.amber)

                TacticalButton(title: "Log Entry", icon: "plus.circle") {
                    addManualEntry()
                }
            }
            .padding(Theme.spacingMD)
        }
    }

    private func manualField(_ label: String, text: Binding<String>, prompt: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Theme.label(9, weight: .bold))
                .foregroundStyle(Theme.textTertiary)
                .tracking(1.2)
            TextField("", text: text, prompt: Text(prompt).foregroundStyle(Theme.textTertiary))
                .font(Theme.mono(15))
                .foregroundStyle(Theme.textPrimary)
                .keyboardType(keyboard)
                .padding(10)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
    }

    // MARK: - Actions

    private func addCatalogFood(_ food: CatalogFood) {
        let entry = FoodEntry(
            name: food.name,
            calories: food.calories,
            protein: food.protein,
            carbs: food.carbs,
            fat: food.fat,
            servingSize: food.defaultServingSize,
            mealSlot: selectedSlot,
            isFromCatalog: true
        )
        entry.dailyLog = dailyLog
        context.insert(entry)
        HapticService.success()
        dismiss()
    }

    private func addCustomFood(_ food: CustomFood) {
        let entry = FoodEntry(
            name: food.name,
            calories: food.calories,
            protein: food.protein,
            carbs: food.carbs,
            fat: food.fat,
            servingSize: food.defaultServing,
            mealSlot: selectedSlot,
            isFromCatalog: false
        )
        entry.dailyLog = dailyLog
        context.insert(entry)
        HapticService.success()
        dismiss()
    }

    private func addManualEntry() {
        guard !name.isEmpty else { return }
        let entry = FoodEntry(
            name: name,
            calories: Int(calories) ?? 0,
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0,
            servingSize: servingSize,
            mealSlot: selectedSlot,
            isFromCatalog: false
        )
        entry.dailyLog = dailyLog
        context.insert(entry)

        if saveToMyFoods {
            let custom = CustomFood(
                name: name,
                calories: Int(calories) ?? 0,
                protein: Double(protein) ?? 0,
                carbs: Double(carbs) ?? 0,
                fat: Double(fat) ?? 0,
                defaultServing: servingSize
            )
            context.insert(custom)
        }

        HapticService.success()
        dismiss()
    }
}
