import Foundation

struct CatalogFood: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var category: FoodCategory
    var brand: String?
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var defaultServingSize: String
    var servingUnit: String
    var tags: [String]
    var goalSuitability: [String]

    enum FoodCategory: String, Codable, CaseIterable {
        case protein, grain, vegetable, fruit, dairy, supplement, shake, snack, prepared
    }
}

struct CatalogExercise: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var muscleGroup: String
    var equipment: String
    var difficulty: String
    var instructions: String
}

struct CatalogWorkoutTemplate: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var category: String
    var goalTags: [String]
    var difficulty: String
    var daysPerWeek: Int
    var description: String
    var exercises: [TemplateExercise]
}

struct TemplateExercise: Codable, Hashable {
    var name: String
    var sets: Int
    var reps: String
    var restSeconds: Int
}
