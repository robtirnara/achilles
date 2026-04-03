import Foundation
import SwiftData

@Model
final class DailyLog {
    @Attribute(.unique) var dateString: String
    var notes: String
    var waterIntakeOz: Double
    @Relationship(deleteRule: .cascade, inverse: \FoodEntry.dailyLog) var foodEntries: [FoodEntry]
    @Relationship(deleteRule: .cascade, inverse: \SupplementLogEntry.dailyLog) var supplementEntries: [SupplementLogEntry]
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSession.dailyLog) var workoutSessions: [WorkoutSession]

    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? .now
    }

    var totalCalories: Int {
        foodEntries.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        foodEntries.reduce(0) { $0 + $1.protein }
    }

    var totalCarbs: Double {
        foodEntries.reduce(0) { $0 + $1.carbs }
    }

    var totalFat: Double {
        foodEntries.reduce(0) { $0 + $1.fat }
    }

    init(dateString: String = "", notes: String = "", waterIntakeOz: Double = 0) {
        self.dateString = dateString
        self.notes = notes
        self.waterIntakeOz = waterIntakeOz
        self.foodEntries = []
        self.supplementEntries = []
        self.workoutSessions = []
    }

    static func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
