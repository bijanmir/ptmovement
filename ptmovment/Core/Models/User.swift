import Foundation
import UIKit

// MARK: - User Management Models

enum UserRole: String, CaseIterable {
    case clinicAdmin = "clinic_admin"
    case physicalTherapist = "physical_therapist"
    case patient = "patient"
    
    var displayName: String {
        switch self {
        case .clinicAdmin: return "Clinic Administrator"
        case .physicalTherapist: return "Physical Therapist"
        case .patient: return "Patient"
        }
    }
}

struct User {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let role: UserRole
    let clinicId: String?
    let assignedTherapistId: String? // For patients
    let createdAt: Date
    let isActive: Bool
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password"
        case .userNotFound: return "User account not found"
        case .networkError: return "Network connection error"
        case .unknownError: return "An unknown error occurred"
        }
    }
}
