import Foundation
import Combine

// MARK: - Authentication Service

class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    static let shared = AuthenticationService()
    
    private init() {}
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Mock authentication logic
            if email.contains("@") && password.count >= 6 {
                let user = User(
                    id: UUID().uuidString,
                    email: email,
                    firstName: "John",
                    lastName: "Doe",
                    role: email.contains("pt") ? .physicalTherapist : .patient,
                    clinicId: "clinic_1",
                    assignedTherapistId: email.contains("pt") ? nil : "therapist_1",
                    createdAt: Date(),
                    isActive: true
                )
                
                self.currentUser = user
                self.isAuthenticated = true
                completion(.success(user))
            } else {
                completion(.failure(.invalidCredentials))
            }
            
            self.isLoading = false
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
    
    func createAccount(firstName: String, lastName: String, email: String, password: String, role: UserRole, completion: @escaping (Result<User, AuthError>) -> Void) {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = User(
                id: UUID().uuidString,
                email: email,
                firstName: firstName,
                lastName: lastName,
                role: role,
                clinicId: role == .patient ? "clinic_1" : "clinic_1",
                assignedTherapistId: role == .patient ? "therapist_1" : nil,
                createdAt: Date(),
                isActive: true
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            completion(.success(user))
            self.isLoading = false
        }
    }
}
