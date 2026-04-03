import Foundation
import SwiftData

@Model
final class ExerciseSet {
    var exerciseName: String
    var setNumber: Int
    var reps: Int
    var weight: Double
    var rpe: Double?
    var workoutSession: WorkoutSession?

    init(
        exerciseName: String,
        setNumber: Int = 1,
        reps: Int = 0,
        weight: Double = 0,
        rpe: Double? = nil
    ) {
        self.exerciseName = exerciseName
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.rpe = rpe
    }
}
