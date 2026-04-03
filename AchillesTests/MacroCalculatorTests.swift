import XCTest
@testable import Achilles

final class MacroCalculatorTests: XCTestCase {

    // MARK: - BMR / TDEE

    func testMaleBMR_SedentaryTDEE() {
        let result = MacroCalculator.calculate(
            sex: .male, weightLbs: 180, heightInches: 70,
            age: 30, activityLevel: .sedentary, goal: .maintain
        )
        let weightKg = 180.0 * 0.453592
        let heightCm = 70.0 * 2.54
        let bmr = (10 * weightKg) + (6.25 * heightCm) - (5.0 * 30.0) + 5
        let expectedTDEE = Int(bmr * 1.2)
        XCTAssertEqual(result.tdee, expectedTDEE)
    }

    func testFemaleBMR_ModerateTDEE() {
        let result = MacroCalculator.calculate(
            sex: .female, weightLbs: 140, heightInches: 64,
            age: 25, activityLevel: .moderate, goal: .maintain
        )
        let weightKg = 140.0 * 0.453592
        let heightCm = 64.0 * 2.54
        let bmr = (10 * weightKg) + (6.25 * heightCm) - (5.0 * 25.0) - 161
        let expectedTDEE = Int(bmr * 1.55)
        XCTAssertEqual(result.tdee, expectedTDEE)
    }

    // MARK: - Goal-based calorie adjustments

    func testCutCreatesDeficit() {
        let maintain = MacroCalculator.calculate(
            sex: .male, weightLbs: 170, heightInches: 70,
            age: 25, activityLevel: .moderate, goal: .maintain
        )
        let cut = MacroCalculator.calculate(
            sex: .male, weightLbs: 170, heightInches: 70,
            age: 25, activityLevel: .moderate, goal: .cut
        )
        XCTAssertEqual(cut.calories, cut.tdee - 500)
        XCTAssertLessThan(cut.calories, maintain.calories)
    }

    func testBulkCreatesSurplus() {
        let bulk = MacroCalculator.calculate(
            sex: .male, weightLbs: 170, heightInches: 70,
            age: 25, activityLevel: .moderate, goal: .bulk
        )
        XCTAssertEqual(bulk.calories, bulk.tdee + 400)
    }

    func testRecompMatchesTDEE() {
        let result = MacroCalculator.calculate(
            sex: .male, weightLbs: 170, heightInches: 70,
            age: 25, activityLevel: .moderate, goal: .recomp
        )
        XCTAssertEqual(result.calories, result.tdee)
    }

    func testPerformanceSlightSurplus() {
        let result = MacroCalculator.calculate(
            sex: .male, weightLbs: 170, heightInches: 70,
            age: 25, activityLevel: .moderate, goal: .performance
        )
        XCTAssertEqual(result.calories, result.tdee + 200)
    }

    // MARK: - Macro distribution

    func testMacrosSumToCalories() {
        for goal in FitnessGoal.allCases {
            let result = MacroCalculator.calculate(
                sex: .male, weightLbs: 170, heightInches: 70,
                age: 25, activityLevel: .moderate, goal: goal
            )
            let macroCalories = (result.protein * 4) + (result.carbs * 4) + (result.fat * 9)
            XCTAssertEqual(
                macroCalories, result.calories,
                accuracy: 10,
                "Macro calories should approximately equal target for \(goal.rawValue)"
            )
        }
    }

    func testProteinNonZero() {
        let result = MacroCalculator.calculate(
            sex: .male, weightLbs: 170, heightInches: 70,
            age: 25, activityLevel: .moderate, goal: .cut
        )
        XCTAssertGreaterThan(result.protein, 0)
    }

    func testCarbsNonNegative() {
        let result = MacroCalculator.calculate(
            sex: .female, weightLbs: 100, heightInches: 58,
            age: 50, activityLevel: .sedentary, goal: .cut
        )
        XCTAssertGreaterThanOrEqual(result.carbs, 0)
    }

    // MARK: - Activity level impact

    func testHigherActivityMeansMoreCalories() {
        let sedentary = MacroCalculator.calculate(
            sex: .male, weightLbs: 170, heightInches: 70,
            age: 25, activityLevel: .sedentary, goal: .maintain
        )
        let athlete = MacroCalculator.calculate(
            sex: .male, weightLbs: 170, heightInches: 70,
            age: 25, activityLevel: .athlete, goal: .maintain
        )
        XCTAssertGreaterThan(athlete.tdee, sedentary.tdee)
        XCTAssertGreaterThan(athlete.calories, sedentary.calories)
    }
}

private func XCTAssertEqual(_ a: Int, _ b: Int, accuracy: Int, _ message: String) {
    XCTAssertTrue(abs(a - b) <= accuracy, "\(message): \(a) vs \(b)")
}
