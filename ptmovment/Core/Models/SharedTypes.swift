import Foundation
import UIKit
import Vision

// MARK: - Core Enums

enum FeedbackType {
    case excellent, good, needsImprovement, poor
    
    var color: UIColor {
        switch self {
        case .excellent: return .systemGreen
        case .good: return .systemBlue
        case .needsImprovement: return .systemOrange
        case .poor: return .systemRed
        }
    }
    
    var score: Double {
        switch self {
        case .excellent: return 4.0
        case .good: return 3.0
        case .needsImprovement: return 2.0
        case .poor: return 1.0
        }
    }
}

enum JointType: String, CaseIterable {
    case nose, leftEye, rightEye, leftEar, rightEar
    case leftShoulder, rightShoulder
    case leftElbow, rightElbow
    case leftWrist, rightWrist
    case leftHip, rightHip
    case leftKnee, rightKnee
    case leftAnkle, rightAnkle
}

// MARK: - Result Models

struct AnalysisResult {
    let repCount: Int
    let feedback: String
    let feedbackType: FeedbackType
}

// MARK: - Feedback Models

struct SessionFeedback {
    let timestamp: Date
    let message: String
    let type: FeedbackType
    let formScore: Double
    let jointAccuracy: [String: Double]
}

struct FormFeedback {
    let timestamp: Date
    let message: String
    let type: FeedbackType
    let jointAngles: [String: Double]
}

// MARK: - Session Models

struct MovementSession {
    let id: UUID
    let exercise: Exercise
    let startTime: Date
    var endTime: Date?
    var repetitions: Int = 0
    var formScore: Double = 0.0
    var feedback: [FormFeedback] = []
    
    var duration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
}
