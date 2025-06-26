import Foundation
import UIKit

// MARK: - Assignment & Progress Models

struct ExerciseAssignment {
    let id: String
    let patientId: String
    let therapistId: String
    let exerciseId: String
    let prescribedReps: Int
    let prescribedDuration: TimeInterval
    let frequencyPerWeek: Int
    let startDate: Date
    let endDate: Date?
    let notes: String?
    let priority: AssignmentPriority
    let isCompleted: Bool
    let createdAt: Date
}

enum AssignmentPriority: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var color: UIColor {
        switch self {
        case .low: return .systemGray
        case .medium: return .systemBlue
        case .high: return .systemOrange
        case .critical: return .systemRed
        }
    }
}
