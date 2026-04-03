import SwiftUI
import SwiftData
import FirebaseCore

@main
struct AchillesApp: App {
    init() {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            UserProfile.self,
            DailyLog.self,
            FoodEntry.self,
            SupplementLogEntry.self,
            CustomFood.self,
            WorkoutSession.self,
            ExerciseSet.self,
            WeightEntry.self
        ])
    }
}
