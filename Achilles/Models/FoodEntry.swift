import Foundation
import SwiftData

@Model
final class FoodEntry {
    var name: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var servingSize: String
    var mealSlot: MealSlot
    var timestamp: Date
    var isFromCatalog: Bool
    var dailyLog: DailyLog?

    init(
        name: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        servingSize: String = "",
        mealSlot: MealSlot = .snack,
        isFromCatalog: Bool = false
    ) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingSize = servingSize
        self.mealSlot = mealSlot
        self.timestamp = .now
        self.isFromCatalog = isFromCatalog
    }
}

enum MealSlot: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var icon: String {
        switch self {
        case .breakfast: "sunrise"
        case .lunch: "sun.max"
        case .dinner: "moon.stars"
        case .snack: "leaf"
        }
    }

    var sortOrder: Int {
        switch self {
        case .breakfast: 0
        case .lunch: 1
        case .dinner: 2
        case .snack: 3
        }
    }
}
