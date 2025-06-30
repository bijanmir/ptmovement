// MARK: - Updated Exercise.swift
import Foundation
import Vision

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
    
    // Static exercise definitions with consistent IDs
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
    
    // Additional exercises to expand the library
    static let lunges = Exercise(
        id: "lunges",
        name: "Forward Lunges",
        description: "Strengthen legs and improve balance with alternating lunges",
        category: .lowerBody,
        difficulty: .intermediate,
        targetBodyParts: [.legs, .glutes, .core],
        instructions: [
            "Stand with feet hip-width apart",
            "Step forward with right leg",
            "Lower hips until both knees are at 90 degrees",
            "Push through front heel to return to start",
            "Alternate legs for each rep"
        ],
        defaultDuration: 120,
        defaultReps: 20,
        videoURL: nil,
        thumbnailURL: nil,
        isActive: true,
        createdAt: Date()
    )
    
    static let plank = Exercise(
        id: "plank",
        name: "Plank Hold",
        description: "Core strengthening exercise holding a plank position",
        category: .core,
        difficulty: .intermediate,
        targetBodyParts: [.core, .shoulders, .back],
        instructions: [
            "Start in forearm plank position",
            "Keep body in straight line from head to heels",
            "Engage core and avoid sagging hips",
            "Hold position for prescribed duration",
            "Breathe normally throughout"
        ],
        defaultDuration: 30,
        defaultReps: 3,
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


// MARK: - Additional Exercise Analyzers

class LungeAnalyzer: ExerciseAnalyzer {
    private var isInLungePosition = false
    private var lastLungeSide: LungeSide = .none
    private var lastStateChange = Date()
    private let minimumHoldTime: TimeInterval = 0.5
    
    enum LungeSide {
        case left, right, none
    }
    
    func analyze(
        currentPose: VNHumanBodyPoseObservation,
        poseHistory: [VNHumanBodyPoseObservation],
        sessionData: inout ExerciseSessionData
    ) -> AnalysisResult {
        guard let recognizedPoints = try? currentPose.recognizedPoints(forGroupKey: .all) else {
            return AnalysisResult(repCount: sessionData.repCount, feedback: "Position yourself in view", feedbackType: .needsImprovement)
        }
        
        guard let leftHip = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftHip.rawValue],
              let rightHip = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightHip.rawValue],
              let leftKnee = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftKnee.rawValue],
              let rightKnee = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightKnee.rawValue],
              let leftAnkle = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftAnkle.rawValue],
              let rightAnkle = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightAnkle.rawValue] else {
            return AnalysisResult(repCount: sessionData.repCount, feedback: "Stand facing the camera", feedbackType: .needsImprovement)
        }
        
        // Calculate angles
        let leftKneeAngle = calculateAngle(point1: leftHip.location, point2: leftKnee.location, point3: leftAnkle.location)
        let rightKneeAngle = calculateAngle(point1: rightHip.location, point2: rightKnee.location, point3: rightAnkle.location)
        
        // Determine forward leg
        let leftForward = leftKnee.location.y < rightKnee.location.y
        let rightForward = rightKnee.location.y < leftKnee.location.y
        let inLungePosition = (leftForward && leftKneeAngle < 110 && leftKneeAngle > 70) ||
                              (rightForward && rightKneeAngle < 110 && rightKneeAngle > 70)
        
        let currentSide: LungeSide = leftForward ? .left : (rightForward ? .right : .none)
        
        if inLungePosition && !isInLungePosition && currentSide != .none && currentSide != lastLungeSide {
            if lastLungeSide != .none {
                sessionData.repCount += 1
            }
            lastLungeSide = currentSide
        }
        
        isInLungePosition = inLungePosition
        
        // Feedback
        var feedback = "Keep alternating lunges"
        var feedbackType = FeedbackType.good
        
        if inLungePosition {
            let activeAngle = leftForward ? leftKneeAngle : rightKneeAngle
            if activeAngle > 100 {
                feedback = "Go deeper - 90° knee angle"
                feedbackType = .needsImprovement
            } else if activeAngle < 80 {
                feedback = "Don't go too low"
                feedbackType = .needsImprovement
            } else {
                feedback = "Perfect depth! Switch legs"
                feedbackType = .excellent
            }
        }
        
        sessionData.addFormScore(feedbackType.score * 25)
        return AnalysisResult(repCount: sessionData.repCount, feedback: feedback, feedbackType: feedbackType)
    }
    
    func reset() {
        isInLungePosition = false
        lastLungeSide = .none
        lastStateChange = Date()
    }
}


class PlankAnalyzer: ExerciseAnalyzer {
    private var plankStartTime: Date?
    private var currentPlankTime: TimeInterval = 0
    private let targetPlankTime: TimeInterval = 30.0
    
    func analyze(currentPose: VNHumanBodyPoseObservation, poseHistory: [VNHumanBodyPoseObservation], sessionData: inout ExerciseSessionData) -> AnalysisResult {
        guard let recognizedPoints = try? currentPose.recognizedPoints(forGroupKey: .all) else {
            return AnalysisResult(repCount: sessionData.repCount, feedback: "Position yourself in view", feedbackType: .needsImprovement)
        }
        
        // Check plank form
        guard let leftShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftShoulder.rawValue],
              let rightShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightShoulder.rawValue],
              let leftHip = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftHip.rawValue],
              let rightHip = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightHip.rawValue],
              let leftAnkle = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftAnkle.rawValue],
              let rightAnkle = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightAnkle.rawValue] else {
            return AnalysisResult(repCount: sessionData.repCount, feedback: "Get in plank position", feedbackType: .needsImprovement)
        }
        
        // Calculate body alignment (should be relatively straight)
        let shoulderCenter = CGPoint(
            x: (leftShoulder.location.x + rightShoulder.location.x) / 2,
            y: (leftShoulder.location.y + rightShoulder.location.y) / 2
        )
        let hipCenter = CGPoint(
            x: (leftHip.location.x + rightHip.location.x) / 2,
            y: (leftHip.location.y + rightHip.location.y) / 2
        )
        let ankleCenter = CGPoint(
            x: (leftAnkle.location.x + rightAnkle.location.x) / 2,
            y: (leftAnkle.location.y + rightAnkle.location.y) / 2
        )
        
        // Check if body is horizontal (in plank position)
        let bodyAngle = calculateBodyAngle(shoulder: shoulderCenter, hip: hipCenter, ankle: ankleCenter)
        let isInPlankPosition = abs(bodyAngle - 180) < 30 // Allow some variance
        
        if isInPlankPosition {
            if plankStartTime == nil {
                plankStartTime = Date()
            }
            currentPlankTime = Date().timeIntervalSince(plankStartTime!)
            
            if currentPlankTime >= targetPlankTime && sessionData.repCount == 0 {
                sessionData.repCount = 1
            }
        } else {
            plankStartTime = nil
            currentPlankTime = 0
        }
        
        // Generate feedback
        var feedback = "Hold plank position"
        var feedbackType = FeedbackType.good
        
        if isInPlankPosition {
            let remainingTime = max(0, targetPlankTime - currentPlankTime)
            if abs(bodyAngle - 180) > 20 {
                feedback = "Keep body straight - don't sag"
                feedbackType = .needsImprovement
            } else if remainingTime > 0 {
                feedback = "Great form! Hold for \(Int(remainingTime))s"
                feedbackType = .excellent
            } else {
                feedback = "Plank complete! Well done!"
                feedbackType = .excellent
            }
        } else {
            feedback = "Get in plank position"
            feedbackType = .needsImprovement
        }
        
        let formScore = isInPlankPosition ? (180 - abs(bodyAngle - 180)) / 180 * 100 : 0
        sessionData.addFormScore(formScore)
        
        return AnalysisResult(repCount: sessionData.repCount, feedback: feedback, feedbackType: feedbackType)
    }
    
    private func calculateBodyAngle(shoulder: CGPoint, hip: CGPoint, ankle: CGPoint) -> Double {
        return calculateAngle(point1: shoulder, point2: hip, point3: ankle)
    }
    
    func reset() {
        plankStartTime = nil
        currentPlankTime = 0
    }
}

class GenericAnalyzer: ExerciseAnalyzer {
    // Fallback analyzer for exercises without specific implementation
    private var movementCount = 0
    private var lastMovementTime = Date()
    
    func analyze(currentPose: VNHumanBodyPoseObservation, poseHistory: [VNHumanBodyPoseObservation], sessionData: inout ExerciseSessionData) -> AnalysisResult {
        // Basic movement detection
        if poseHistory.count >= 2 {
            let currentTime = Date()
            if currentTime.timeIntervalSince(lastMovementTime) > 1.0 {
                movementCount += 1
                lastMovementTime = currentTime
                
                if movementCount % 2 == 0 {
                    sessionData.repCount += 1
                }
            }
        }
        
        return AnalysisResult(
            repCount: sessionData.repCount,
            feedback: "Continue exercise with good form",
            feedbackType: .good
        )
    }
    
    func reset() {
        movementCount = 0
        lastMovementTime = Date()
    }
}

// Helper function needed by analyzers
private func calculateAngle(point1: CGPoint, point2: CGPoint, point3: CGPoint) -> Double {
    let vector1 = CGPoint(x: point1.x - point2.x, y: point1.y - point2.y)
    let vector2 = CGPoint(x: point3.x - point2.x, y: point3.y - point2.y)
    
    let dotProduct = vector1.x * vector2.x + vector1.y * vector2.y
    let magnitude1 = sqrt(vector1.x * vector1.x + vector1.y * vector1.y)
    let magnitude2 = sqrt(vector2.x * vector2.x + vector2.y * vector2.y)
    
    let cosAngle = dotProduct / (magnitude1 * magnitude2)
    let angle = acos(max(-1, min(1, cosAngle)))
    
    return angle * 180.0 / Double.pi
}
