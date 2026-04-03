import SwiftUI

struct WorkoutDetailView: View {
    let session: WorkoutSession

    private var grouped: [(String, [ExerciseSet])] {
        let dict = Dictionary(grouping: session.sets, by: \.exerciseName)
        return dict.sorted { $0.key < $1.key }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingMD) {
                TacticalCard {
                    HStack {
                        StatReadout(label: "Duration", value: "\(session.durationMinutes)", unit: "min")
                        Spacer()
                        StatReadout(label: "Sets", value: "\(session.sets.count)", unit: "total")
                        Spacer()
                        StatReadout(label: "Volume", value: "\(Int(session.totalVolume))", unit: "lbs")
                    }
                }

                ForEach(grouped, id: \.0) { name, sets in
                    VStack(alignment: .leading, spacing: Theme.spacingSM) {
                        Text(name.uppercased())
                            .font(Theme.label(13, weight: .bold))
                            .foregroundStyle(Theme.amber)
                            .tracking(1)

                        ForEach(sets.sorted { $0.setNumber < $1.setNumber }) { set in
                            HStack {
                                Text("SET \(set.setNumber)")
                                    .font(Theme.mono(11))
                                    .foregroundStyle(Theme.textTertiary)
                                    .frame(width: 50, alignment: .leading)
                                Text("\(set.reps)")
                                    .font(Theme.mono(16, weight: .bold))
                                    .foregroundStyle(Theme.textPrimary)
                                Text("reps")
                                    .font(Theme.mono(11))
                                    .foregroundStyle(Theme.textSecondary)
                                Text("×")
                                    .foregroundStyle(Theme.textTertiary)
                                Text("\(Int(set.weight))")
                                    .font(Theme.mono(16, weight: .bold))
                                    .foregroundStyle(Theme.textPrimary)
                                Text("lbs")
                                    .font(Theme.mono(11))
                                    .foregroundStyle(Theme.textSecondary)
                                Spacer()
                                if let rpe = set.rpe {
                                    Text("RPE \(Int(rpe))")
                                        .font(Theme.mono(10))
                                        .foregroundStyle(Theme.olive)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(Theme.spacingMD)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                }

                if !session.notes.isEmpty {
                    TacticalCard {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("NOTES")
                                .font(Theme.label(10, weight: .bold))
                                .foregroundStyle(Theme.textTertiary)
                                .tracking(1.5)
                            Text(session.notes)
                                .font(Theme.label(13))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .padding(Theme.spacingMD)
        }
        .background(Theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(session.name.uppercased())
                    .font(Theme.heading(16))
                    .foregroundStyle(Theme.textPrimary)
                    .tracking(2)
            }
        }
    }
}
