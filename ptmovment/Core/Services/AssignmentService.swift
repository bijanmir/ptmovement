import Foundation

// MARK: - Assignment Service

class AssignmentService {
    static let shared = AssignmentService()
    
    private init() {}
    
    func getAssignmentsForPatient(_ patientId: String) -> [ExerciseAssignment] {
        // Mock data - in real app, this would fetch from backend
        return [
            ExerciseAssignment(
                id: UUID().uuidString,
                patientId: patientId,
                therapistId: "therapist_1",
                exerciseId: Exercise.shoulderRaise.id,
                prescribedReps: 10,
                prescribedDuration: 60,
                frequencyPerWeek: 3,
                startDate: Date().addingTimeInterval(-7 * 24 * 60 * 60),
                endDate: Date().addingTimeInterval(14 * 24 * 60 * 60),
                notes: "Focus on form over speed. Stop if you feel pain.",
                priority: .medium,
                isCompleted: false,
                createdAt: Date()
            ),
            ExerciseAssignment(
                id: UUID().uuidString,
                patientId: patientId,
                therapistId: "therapist_1",
                exerciseId: Exercise.squats.id,
                prescribedReps: 15,
                prescribedDuration: 90,
                frequencyPerWeek: 4,
                startDate: Date().addingTimeInterval(-3 * 24 * 60 * 60),
                endDate: Date().addingTimeInterval(21 * 24 * 60 * 60),
                notes: "Start with shallow squats, gradually increase depth.",
                priority: .high,
                isCompleted: false,
                createdAt: Date()
            )
        ]
    }
    
    func getAssignmentsForTherapist(_ therapistId: String) -> [ExerciseAssignment] {
        // Mock data - would fetch all assignments created by this therapist
        return getAssignmentsForPatient("patient_1") // Simplified for now
    }
    
    func createAssignment(_ assignment: ExerciseAssignment, completion: @escaping (Bool) -> Void) {
        // Mock API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }
    
    func updateAssignment(_ assignment: ExerciseAssignment, completion: @escaping (Bool) -> Void) {
        // Mock API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }
    
    func completeAssignment(_ assignmentId: String, completion: @escaping (Bool) -> Void) {
        // Mock API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }
    
    func deleteAssignment(_ assignmentId: String, completion: @escaping (Bool) -> Void) {
        // Mock API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }
    
    
}
