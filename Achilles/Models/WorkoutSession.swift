import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var name: String
    var date: Date
    var durationMinutes: Int
    var notes: String
    var dailyLog: DailyLog?
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.workoutSession) var sets: [ExerciseSet]

    var totalVolume: Double {
        sets.reduce(0) { $0 + (Double($1.reps) * $1.weight) }
    }

    init(name: String = "", durationMinutes: Int = 0, notes: String = "") {
        self.name = name
        self.date = .now
        self.durationMinutes = durationMinutes
        self.notes = notes
        self.sets = []
    }
}
