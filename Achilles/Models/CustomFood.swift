import Foundation
import SwiftData

@Model
final class CustomFood {
    var name: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var defaultServing: String
    var category: String
    var createdAt: Date

    init(
        name: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        defaultServing: String = "1 serving",
        category: String = "Custom"
    ) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.defaultServing = defaultServing
        self.category = category
        self.createdAt = .now
    }
}
