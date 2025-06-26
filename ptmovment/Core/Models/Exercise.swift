import Foundation

// MARK: - Exercise System Models

struct Exercise {
    let id: String
    let name: String
    let description: String
    let category: ExerciseCategory
    let difficulty: ExerciseDifficulty
    let targetBodyParts: [BodyPart]
    let instructions: [String]
    let defaultDuration: TimeInterval
    let defaultReps: Int
    let videoURL: String?
    let thumbnailURL: String?
    let isActive: Bool
    let createdAt: Date
    
    // Static exercise definitions
    static let shoulderRaise = Exercise(
        id: "shoulder_raise",
        name: "Shoulder Lateral Raise",
        description: "Raise your arms to shoulder height to strengthen deltoids and improve shoulder mobility",
        category: .upperBody,
        difficulty: .beginner,
        targetBodyParts: [.shoulders, .arms],
        instructions: [
            "Stand with feet shoulder-width apart",
            "Keep your back straight and core engaged",
            "Slowly raise arms to shoulder height",
            "Hold for 2 seconds at the top",
            "Lower arms slowly and controlled"
        ],
        defaultDuration: 60,
        defaultReps: 10,
        videoURL: nil,
        thumbnailURL: nil,
        isActive: true,
        createdAt: Date()
    )
    
    static let squats = Exercise(
        id: "squats",
        name: "Bodyweight Squats",
        description: "Strengthen quadriceps, glutes, and improve lower body mobility",
        category: .lowerBody,
        difficulty: .beginner,
        targetBodyParts: [.legs, .glutes],
        instructions: [
            "Stand with feet hip-width apart",
            "Keep your back straight and core engaged",
            "Lower body as if sitting back into a chair",
            "Keep knees behind toes",
            "Lower until thighs are parallel to floor",
            "Push through heels to return to standing"
        ],
        defaultDuration: 90,
        defaultReps: 15,
        videoURL: nil,
        thumbnailURL: nil,
        isActive: true,
        createdAt: Date()
    )
    
    static let balanceStand = Exercise(
        id: "balance_stand",
        name: "Single Leg Balance",
        description: "Improve balance and stability while strengthening core muscles",
        category: .balance,
        difficulty: .intermediate,
        targetBodyParts: [.core, .legs],
        instructions: [
            "Stand on one foot with the other slightly raised",
            "Keep your core engaged and back straight",
            "Try to maintain balance for 30 seconds",
            "Use arms for stability if needed",
            "Switch legs and repeat"
        ],
        defaultDuration: 60,
        defaultReps: 5,
        videoURL: nil,
        thumbnailURL: nil,
        isActive: true,
        createdAt: Date()
    )
    
    static let armCircles = Exercise(
        id: "arm_circles",
        name: "Arm Circles",
        description: "Gentle shoulder mobility exercise to improve range of motion",
        category: .flexibility,
        difficulty: .beginner,
        targetBodyParts: [.shoulders, .arms],
        instructions: [
            "Stand with feet shoulder-width apart",
            "Extend arms straight out to the sides",
            "Make small circles with your arms",
            "Gradually increase circle size",
            "Reverse direction after 10 circles"
        ],
        defaultDuration: 45,
        defaultReps: 20,
        videoURL: nil,
        thumbnailURL: nil,
        isActive: true,
        createdAt: Date()
    )
}

enum ExerciseCategory: String, CaseIterable {
    case upperBody = "upper_body"
    case lowerBody = "lower_body"
    case core = "core"
    case balance = "balance"
    case flexibility = "flexibility"
    case cardio = "cardio"
    
    var displayName: String {
        switch self {
        case .upperBody: return "Upper Body"
        case .lowerBody: return "Lower Body"
        case .core: return "Core"
        case .balance: return "Balance"
        case .flexibility: return "Flexibility"
        case .cardio: return "Cardio"
        }
    }
}

enum ExerciseDifficulty: String, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    var displayName: String {
        return rawValue.capitalized
    }
}

enum BodyPart: String, CaseIterable {
    case shoulders = "shoulders"
    case arms = "arms"
    case chest = "chest"
    case back = "back"
    case core = "core"
    case legs = "legs"
    case glutes = "glutes"
    case ankles = "ankles"
    
    var displayName: String {
        return rawValue.capitalized
    }
}
