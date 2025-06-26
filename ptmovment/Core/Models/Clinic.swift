import Foundation

// MARK: - Clinic Management Models

struct Clinic {
    let id: String
    let name: String
    let address: String
    let phone: String
    let email: String
    let subscriptionTier: SubscriptionTier
    let subscriptionStatus: SubscriptionStatus
    let maxTherapists: Int
    let maxPatients: Int
    let createdAt: Date
    let adminUserId: String
}

enum SubscriptionTier: String, CaseIterable {
    case starter = "starter"
    case professional = "professional"
    case enterprise = "enterprise"
    
    var displayName: String {
        switch self {
        case .starter: return "Starter"
        case .professional: return "Professional"
        case .enterprise: return "Enterprise"
        }
    }
    
    var maxTherapists: Int {
        switch self {
        case .starter: return 2
        case .professional: return 10
        case .enterprise: return 50
        }
    }
    
    var maxPatients: Int {
        switch self {
        case .starter: return 25
        case .professional: return 250
        case .enterprise: return 1000
        }
    }
    
    var monthlyPrice: Double {
        switch self {
        case .starter: return 99.0
        case .professional: return 299.0
        case .enterprise: return 799.0
        }
    }
}

enum SubscriptionStatus: String {
    case active = "active"
    case pastDue = "past_due"
    case cancelled = "cancelled"
    case trialing = "trialing"
}
