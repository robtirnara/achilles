import XCTest
@testable import Achilles

final class CatalogServiceTests: XCTestCase {

    private let service = CatalogService.shared

    // MARK: - Catalog Loading

    func testFoodCatalogLoads() {
        XCTAssertFalse(service.foods.isEmpty, "Food catalog should load from bundled JSON")
    }

    func testExerciseCatalogLoads() {
        XCTAssertFalse(service.exercises.isEmpty, "Exercise catalog should load from bundled JSON")
    }

    func testWorkoutTemplatesLoad() {
        XCTAssertFalse(service.workoutTemplates.isEmpty, "Workout templates should load from bundled JSON")
    }

    // MARK: - Food Search

    func testSearchFoodsReturnsAllWhenEmpty() {
        let results = service.searchFoods(query: "")
        XCTAssertEqual(results.count, service.foods.count)
    }

    func testSearchFoodsFilters() {
        let results = service.searchFoods(query: "chicken")
        XCTAssertTrue(results.allSatisfy { food in
            food.name.lowercased().contains("chicken") ||
            food.tags.contains(where: { $0.lowercased().contains("chicken") })
        })
    }

    func testSearchFoodsNoResults() {
        let results = service.searchFoods(query: "xyznonexistent123")
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Exercise Search

    func testSearchExercisesReturnsAllWhenEmpty() {
        let results = service.searchExercises(query: "")
        XCTAssertEqual(results.count, service.exercises.count)
    }

    func testSearchExercisesByMuscleGroup() {
        let results = service.searchExercises(query: "", muscleGroup: "Chest")
        XCTAssertFalse(results.isEmpty, "Should find chest exercises")
        XCTAssertTrue(results.allSatisfy { ex in
            ex.muscleGroup.lowercased().contains("chest")
        })
    }

    func testSearchExercisesAllGroupReturnsAll() {
        let all = service.searchExercises(query: "", muscleGroup: "All")
        XCTAssertEqual(all.count, service.exercises.count)
    }

    // MARK: - Food Suggestions

    func testFoodSuggestionsRespectCalorieLimit() {
        let suggestions = service.foodsForRemainingMacros(
            remainingCalories: 200,
            remainingProtein: 30,
            goal: .cut
        )
        XCTAssertTrue(suggestions.allSatisfy { $0.calories <= 200 })
    }

    // MARK: - Workout Templates for Goal

    func testWorkoutsForGoalReturnsMatches() {
        for goal in FitnessGoal.allCases {
            let templates = service.workoutsForGoal(goal)
            for t in templates {
                XCTAssertTrue(
                    t.goalTags.contains(where: { $0.lowercased() == goal.rawValue.lowercased() }),
                    "\(t.name) should match \(goal.rawValue)"
                )
            }
        }
    }

    // MARK: - Data Integrity

    func testFoodEntriesHaveRequiredFields() {
        for food in service.foods {
            XCTAssertFalse(food.id.isEmpty, "Food ID should not be empty")
            XCTAssertFalse(food.name.isEmpty, "Food name should not be empty")
            XCTAssertGreaterThanOrEqual(food.calories, 0, "\(food.name) has negative calories")
            XCTAssertGreaterThanOrEqual(food.protein, 0, "\(food.name) has negative protein")
            XCTAssertGreaterThanOrEqual(food.carbs, 0, "\(food.name) has negative carbs")
            XCTAssertGreaterThanOrEqual(food.fat, 0, "\(food.name) has negative fat")
        }
    }

    func testExerciseEntriesHaveRequiredFields() {
        for exercise in service.exercises {
            XCTAssertFalse(exercise.id.isEmpty)
            XCTAssertFalse(exercise.name.isEmpty)
            XCTAssertFalse(exercise.muscleGroup.isEmpty)
        }
    }
}
