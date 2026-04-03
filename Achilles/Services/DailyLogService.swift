import Foundation
import SwiftData

@MainActor
final class DailyLogService {
    static func getOrCreateLog(for date: Date, context: ModelContext) -> DailyLog {
        let dateKey = DailyLog.dateKey(from: date)
        let descriptor = FetchDescriptor<DailyLog>(predicate: #Predicate { $0.dateString == dateKey })

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let newLog = DailyLog(dateString: dateKey)
        context.insert(newLog)
        return newLog
    }

    static func streakCount(context: ModelContext) -> Int {
        let all = (try? context.fetch(FetchDescriptor<DailyLog>(
            sortBy: [SortDescriptor(\.dateString, order: .reverse)]
        ))) ?? []

        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: .now)

        for _ in 0..<365 {
            let key = DailyLog.dateKey(from: checkDate)
            if all.contains(where: { $0.dateString == key && (!$0.foodEntries.isEmpty || !$0.workoutSessions.isEmpty) }) {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }

        return streak
    }
}
