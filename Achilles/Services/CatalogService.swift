import Foundation

final class CatalogService {
    static let shared = CatalogService()

    private(set) var foods: [CatalogFood] = []
    private(set) var exercises: [CatalogExercise] = []
    private(set) var workoutTemplates: [CatalogWorkoutTemplate] = []

    private init() {
        loadAll()
    }

    private func loadAll() {
        foods = load("food_catalog", as: [CatalogFood].self) ?? []
        exercises = load("exercise_catalog", as: [CatalogExercise].self) ?? []
        workoutTemplates = load("workout_templates", as: [CatalogWorkoutTemplate].self) ?? []
    }

    private func load<T: Decodable>(_ name: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func searchFoods(query: String) -> [CatalogFood] {
        guard !query.isEmpty else { return foods }
        let q = query.lowercased()
        return foods.filter { food in
            food.name.lowercased().contains(q) ||
            food.brand?.lowercased().contains(q) == true ||
            food.category.rawValue.lowercased().contains(q) ||
            food.tags.contains(where: { $0.lowercased().contains(q) })
        }
    }

    func foodsForRemainingMacros(
        remainingCalories: Int,
        remainingProtein: Double,
        goal: FitnessGoal
    ) -> [CatalogFood] {
        let filtered = foods.filter { $0.calories <= max(remainingCalories, 50) && $0.calories > 0 }

        let proteinWeight: Double = (goal == .cut || goal == .recomp) ? 2.0 : 1.0
        let calorieWeight: Double = goal == .bulk ? 0.3 : 1.0

        return filtered.sorted { a, b in
            let aScore = (a.protein * proteinWeight) - (Double(a.calories) * calorieWeight * 0.01)
            let bScore = (b.protein * proteinWeight) - (Double(b.calories) * calorieWeight * 0.01)
            return aScore > bScore
        }
    }

    static let exerciseMuscleGroups = ["All", "Chest", "Back", "Legs", "Shoulders", "Arms", "Core", "Full Body", "Cardio"]

    func searchExercises(query: String, muscleGroup: String? = nil) -> [CatalogExercise] {
        var results = exercises

        if let group = muscleGroup, group != "All" {
            let g = group.lowercased()
            results = results.filter { ex in
                let mg = ex.muscleGroup.lowercased()
                switch g {
                case "arms":
                    return mg.contains("bicep") || mg.contains("tricep") || mg.contains("forearm")
                case "legs":
                    return mg.contains("quad") || mg.contains("hamstring") || mg.contains("glute") ||
                           mg.contains("calf") || mg.contains("adduct") || mg.contains("abduct") ||
                           mg.contains("leg")
                case "full body":
                    return mg.contains("full body")
                default:
                    return mg.contains(g)
                }
            }
        }

        guard !query.isEmpty else { return results }
        let q = query.lowercased()
        return results.filter { ex in
            ex.name.lowercased().contains(q) ||
            ex.muscleGroup.lowercased().contains(q) ||
            ex.equipment.lowercased().contains(q)
        }
    }

    func workoutsForGoal(_ goal: FitnessGoal) -> [CatalogWorkoutTemplate] {
        let goalKey = goal.rawValue.lowercased()
        return workoutTemplates.filter { template in
            template.goalTags.contains(where: { $0.lowercased() == goalKey })
        }
    }
}
