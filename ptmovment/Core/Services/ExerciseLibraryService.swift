import Foundation

// MARK: - Exercise Library Service

class ExerciseLibraryService {
    static let shared = ExerciseLibraryService()
    
    private init() {}
    
    func getAllExercises() -> [Exercise] {
        return [
            Exercise.shoulderRaise,
            Exercise.squats,
            Exercise.balanceStand,
            Exercise.armCircles
            // Add more exercises here as we build them
        ]
    }
    
    func getExercisesByCategory(_ category: ExerciseCategory) -> [Exercise] {
        return getAllExercises().filter { $0.category == category }
    }
    
    func getExerciseById(_ id: String) -> Exercise? {
        return getAllExercises().first { $0.id == id }
    }
    
    func getExercisesByDifficulty(_ difficulty: ExerciseDifficulty) -> [Exercise] {
        return getAllExercises().filter { $0.difficulty == difficulty }
    }
    
    func getExercisesByBodyPart(_ bodyPart: BodyPart) -> [Exercise] {
        return getAllExercises().filter { $0.targetBodyParts.contains(bodyPart) }
    }
    
    func searchExercises(query: String) -> [Exercise] {
        let lowercaseQuery = query.lowercased()
        return getAllExercises().filter { exercise in
            exercise.name.lowercased().contains(lowercaseQuery) ||
            exercise.description.lowercased().contains(lowercaseQuery) ||
            exercise.targetBodyParts.contains { $0.displayName.lowercased().contains(lowercaseQuery) }
        }
    }
}
