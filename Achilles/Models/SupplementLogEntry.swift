import Foundation
import SwiftData

@Model
final class SupplementLogEntry {
    var supplementName: String
    var dosage: String
    var taken: Bool
    var timestamp: Date
    var dailyLog: DailyLog?

    init(supplementName: String, dosage: String, taken: Bool = false) {
        self.supplementName = supplementName
        self.dosage = dosage
        self.taken = taken
        self.timestamp = .now
    }
}
