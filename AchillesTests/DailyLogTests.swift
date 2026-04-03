import XCTest
@testable import Achilles

final class DailyLogTests: XCTestCase {

    // MARK: - Date Key

    func testDateKeyFormat() {
        let components = DateComponents(year: 2026, month: 4, day: 3)
        let date = Calendar.current.date(from: components)!
        let key = DailyLog.dateKey(from: date)
        XCTAssertEqual(key, "2026-04-03")
    }

    func testDateKeyConsistency() {
        let date = Date.now
        let key1 = DailyLog.dateKey(from: date)
        let key2 = DailyLog.dateKey(from: date)
        XCTAssertEqual(key1, key2, "Same date should produce same key")
    }

    func testDifferentDatesProduceDifferentKeys() {
        let today = Date.now
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        XCTAssertNotEqual(
            DailyLog.dateKey(from: today),
            DailyLog.dateKey(from: tomorrow)
        )
    }

    // MARK: - Macro Totals

    func testEmptyLogHasZeroTotals() {
        let log = DailyLog(dateString: "2026-04-03")
        XCTAssertEqual(log.totalCalories, 0)
        XCTAssertEqual(log.totalProtein, 0)
        XCTAssertEqual(log.totalCarbs, 0)
        XCTAssertEqual(log.totalFat, 0)
        XCTAssertEqual(log.waterIntakeOz, 0)
    }

    // MARK: - Model Init Defaults

    func testDailyLogDefaults() {
        let log = DailyLog()
        XCTAssertEqual(log.dateString, "")
        XCTAssertEqual(log.notes, "")
        XCTAssertEqual(log.waterIntakeOz, 0)
        XCTAssertTrue(log.foodEntries.isEmpty)
        XCTAssertTrue(log.supplementEntries.isEmpty)
        XCTAssertTrue(log.workoutSessions.isEmpty)
    }

    // MARK: - UserProfile Defaults

    func testUserProfileDefaults() {
        let profile = UserProfile()
        XCTAssertEqual(profile.name, "")
        XCTAssertEqual(profile.age, 25)
        XCTAssertEqual(profile.sex, .male)
        XCTAssertEqual(profile.weightLbs, 170)
        XCTAssertEqual(profile.heightInches, 70)
        XCTAssertEqual(profile.goal, .recomp)
        XCTAssertEqual(profile.activityLevel, .moderate)
        XCTAssertEqual(profile.calorieTarget, 2400)
        XCTAssertEqual(profile.waterTargetOz, 128)
        XCTAssertFalse(profile.useMetric)
    }

    // MARK: - FoodEntry

    func testFoodEntryInit() {
        let entry = FoodEntry(
            name: "Chicken Breast",
            calories: 165,
            protein: 31,
            carbs: 0,
            fat: 3.6,
            servingSize: "100g",
            mealSlot: .lunch
        )
        XCTAssertEqual(entry.name, "Chicken Breast")
        XCTAssertEqual(entry.calories, 165)
        XCTAssertEqual(entry.protein, 31)
        XCTAssertEqual(entry.mealSlot, .lunch)
        XCTAssertFalse(entry.isFromCatalog)
    }

    // MARK: - MealSlot

    func testMealSlotSortOrder() {
        XCTAssertLessThan(MealSlot.breakfast.sortOrder, MealSlot.lunch.sortOrder)
        XCTAssertLessThan(MealSlot.lunch.sortOrder, MealSlot.dinner.sortOrder)
        XCTAssertLessThan(MealSlot.dinner.sortOrder, MealSlot.snack.sortOrder)
    }

    func testMealSlotHasIcons() {
        for slot in MealSlot.allCases {
            XCTAssertFalse(slot.icon.isEmpty, "\(slot.rawValue) should have an icon")
        }
    }

    // MARK: - FitnessGoal

    func testAllGoalsHaveTaglines() {
        for goal in FitnessGoal.allCases {
            XCTAssertFalse(goal.tagline.isEmpty, "\(goal.rawValue) should have a tagline")
        }
    }

    // MARK: - ActivityLevel

    func testActivityMultipliersIncrease() {
        let levels = ActivityLevel.allCases
        for i in 0..<(levels.count - 1) {
            XCTAssertLessThan(
                levels[i].multiplier,
                levels[i + 1].multiplier,
                "\(levels[i].rawValue) should have lower multiplier than \(levels[i + 1].rawValue)"
            )
        }
    }
}
