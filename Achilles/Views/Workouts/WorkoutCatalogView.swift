import SwiftUI
import SwiftData

struct WorkoutCatalogView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    let dailyLog: DailyLog?

    private var templates: [CatalogWorkoutTemplate] {
        CatalogService.shared.workoutTemplates
    }

    private var recommended: [CatalogWorkoutTemplate] {
        guard let goal = profiles.first?.goal else { return [] }
        return CatalogService.shared.workoutsForGoal(goal)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingMD) {
                    if !recommended.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.spacingSM) {
                            SectionHeader(title: "Recommended")
                                .padding(.horizontal, Theme.spacingMD)
                            ForEach(recommended) { template in
                                templateRow(template, highlighted: true)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: Theme.spacingSM) {
                        SectionHeader(title: "All Programs")
                            .padding(.horizontal, Theme.spacingMD)
                        ForEach(templates) { template in
                            templateRow(template, highlighted: false)
                        }
                    }
                }
                .padding(.vertical, Theme.spacingMD)
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("WORKOUT CATALOG")
                        .font(Theme.heading(16))
                        .foregroundStyle(Theme.textPrimary)
                        .tracking(2)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func templateRow(_ template: CatalogWorkoutTemplate, highlighted: Bool) -> some View {
        TacticalCard {
            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                HStack {
                    Text(template.name)
                        .font(Theme.label(15, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("\(template.daysPerWeek)x/wk")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.olive)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Theme.olive.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                }

                Text(template.description)
                    .font(Theme.label(12))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(3)

                HStack(spacing: Theme.spacingSM) {
                    Text(template.difficulty.uppercased())
                        .font(Theme.label(9, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1)
                    Text("·")
                        .foregroundStyle(Theme.textTertiary)
                    Text(template.category.uppercased())
                        .font(Theme.label(9, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                        .tracking(1)
                }

                if !template.exercises.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(template.exercises.prefix(5), id: \.name) { ex in
                            HStack {
                                Text(ex.name)
                                    .font(Theme.label(12))
                                    .foregroundStyle(Theme.textSecondary)
                                Spacer()
                                Text("\(ex.sets)×\(ex.reps)")
                                    .font(Theme.mono(11))
                                    .foregroundStyle(Theme.textTertiary)
                            }
                        }
                        if template.exercises.count > 5 {
                            Text("+\(template.exercises.count - 5) more")
                                .font(Theme.label(11))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .strokeBorder(highlighted ? Theme.olive : .clear, lineWidth: 1)
        )
        .padding(.horizontal, Theme.spacingMD)
    }
}
