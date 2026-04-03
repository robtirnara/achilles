import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var age: Int
    var sex: BiologicalSex
    var weightLbs: Double
    var heightInches: Double
    var bodyFatPercent: Double?
    var goal: FitnessGoal
    var activityLevel: ActivityLevel
    var targetDate: Date?
    var tdee: Int
    var proteinTarget: Int
    var carbsTarget: Int
    var fatTarget: Int
    var calorieTarget: Int
    var waterTargetOz: Double
    var dailySupplements: [SupplementConfig]
    var useMetric: Bool
    var createdAt: Date

    init(
        name: String = "",
        age: Int = 25,
        sex: BiologicalSex = .male,
        weightLbs: Double = 170,
        heightInches: Double = 70,
        bodyFatPercent: Double? = nil,
        goal: FitnessGoal = .recomp,
        activityLevel: ActivityLevel = .moderate,
        targetDate: Date? = nil,
        tdee: Int = 2400,
        proteinTarget: Int = 170,
        carbsTarget: Int = 250,
        fatTarget: Int = 67,
        calorieTarget: Int = 2400,
        waterTargetOz: Double = 128,
        dailySupplements: [SupplementConfig] = [],
        useMetric: Bool = false
    ) {
        self.name = name
        self.age = age
        self.sex = sex
        self.weightLbs = weightLbs
        self.heightInches = heightInches
        self.bodyFatPercent = bodyFatPercent
        self.goal = goal
        self.activityLevel = activityLevel
        self.targetDate = targetDate
        self.tdee = tdee
        self.proteinTarget = proteinTarget
        self.carbsTarget = carbsTarget
        self.fatTarget = fatTarget
        self.calorieTarget = calorieTarget
        self.waterTargetOz = waterTargetOz
        self.dailySupplements = dailySupplements
        self.useMetric = useMetric
        self.createdAt = .now
    }
}

enum BiologicalSex: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
}

enum FitnessGoal: String, Codable, CaseIterable {
    case cut = "Cut"
    case bulk = "Bulk"
    case recomp = "Recomp"
    case maintain = "Maintain"
    case performance = "Performance"

    var tagline: String {
        switch self {
        case .cut: "Lean down, preserve muscle"
        case .bulk: "Build size and strength"
        case .recomp: "Lose fat, gain muscle"
        case .maintain: "Hold steady"
        case .performance: "Maximize output"
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case light = "Light"
    case moderate = "Moderate"
    case veryActive = "Very Active"
    case athlete = "Athlete"

    var multiplier: Double {
        switch self {
        case .sedentary: 1.2
        case .light: 1.375
        case .moderate: 1.55
        case .veryActive: 1.725
        case .athlete: 1.9
        }
    }
}

struct SupplementConfig: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var dosage: String
}
