import Foundation
import SwiftData

@Model
final class WeightEntry {
    var date: Date
    var weightLbs: Double

    init(date: Date = .now, weightLbs: Double) {
        self.date = date
        self.weightLbs = weightLbs
    }
}
