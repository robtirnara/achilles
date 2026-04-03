import Foundation

enum MacroCalculator {
    struct MacroResult {
        var tdee: Int
        var calories: Int
        var protein: Int
        var carbs: Int
        var fat: Int
    }

    static func calculate(
        sex: BiologicalSex,
        weightLbs: Double,
        heightInches: Double,
        age: Int,
        activityLevel: ActivityLevel,
        goal: FitnessGoal
    ) -> MacroResult {
        let weightKg = weightLbs * 0.453592
        let heightCm = heightInches * 2.54

        let bmr: Double
        switch sex {
        case .male:
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) + 5
        case .female:
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) - 161
        }

        let tdee = Int(bmr * activityLevel.multiplier)

        let calories: Int
        let proteinPerLb: Double
        let fatPercent: Double

        switch goal {
        case .cut:
            calories = tdee - 500
            proteinPerLb = 1.0
            fatPercent = 0.25
        case .bulk:
            calories = tdee + 400
            proteinPerLb = 1.0
            fatPercent = 0.25
        case .recomp:
            calories = tdee
            proteinPerLb = 1.2
            fatPercent = 0.25
        case .maintain:
            calories = tdee
            proteinPerLb = 0.8
            fatPercent = 0.30
        case .performance:
            calories = tdee + 200
            proteinPerLb = 1.0
            fatPercent = 0.20
        }

        let protein = Int(weightLbs * proteinPerLb)
        let fatCals = Double(calories) * fatPercent
        let fat = Int(fatCals / 9.0)
        let remainingCals = Double(calories) - (Double(protein) * 4.0) - fatCals
        let carbs = max(0, Int(remainingCals / 4.0))

        return MacroResult(
            tdee: tdee,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }
}
