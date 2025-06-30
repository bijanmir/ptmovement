import Foundation
import CoreData

// MARK: - Data Models

struct SessionData {
    let id: String
    let exerciseId: String
    let exerciseName: String
    let startTime: Date
    let endTime: Date?
    let repetitions: Int
    let targetReps: Int
    let averageFormScore: Double
    let duration: TimeInterval
    let caloriesBurned: Double
}

struct RepDetail {
    let formScore: Double
    let timestamp: Date
    let duration: TimeInterval
    let angleData: Data?
}

struct ProgressData {
    let totalSessions: Int
    let totalReps: Int
    let averageFormScore: Double
    let totalDuration: TimeInterval
    let totalCalories: Double
    let currentStreak: Int
    let chartData: [ChartDataPoint]
    
    static let empty = ProgressData(
        totalSessions: 0,
        totalReps: 0,
        averageFormScore: 0,
        totalDuration: 0,
        totalCalories: 0,
        currentStreak: 0,
        chartData: []
    )
}

struct ChartDataPoint {
    let date: Date
    let value: Double
    let count: Int
}

struct Achievement {
    let id: String
    let type: String
    let name: String
    let description: String
    let iconName: String
    let isUnlocked: Bool
    let unlockedAt: Date?
    let progress: Double
    let currentValue: Double
    let targetValue: Double
}

struct ComplianceData {
    let weeklyCompletionRate: Double
    let monthlyCompletionRate: Double
    let missedSessions: Int
    let consistencyScore: Double
    let lastActiveDate: Date
}

// MARK: - Data Persistence Service

class DataPersistenceService {
    static let shared = DataPersistenceService()
    private let coreDataStack = CoreDataStack.shared
    
    private init() {}
    
    // MARK: - User Management
    
    func saveUser(_ user: User) {
        let context = coreDataStack.context
        
        let cdUser = CDUser(context: context)
        cdUser.id = user.id
        cdUser.email = user.email
        cdUser.firstName = user.firstName
        cdUser.lastName = user.lastName
        cdUser.role = user.role.rawValue
        cdUser.clinicId = user.clinicId
        cdUser.assignedTherapistId = user.assignedTherapistId
        cdUser.createdAt = user.createdAt
        cdUser.isActive = user.isActive
        cdUser.lastSyncedAt = Date()
        
        coreDataStack.save()
    }
    
    func getUser(by id: String) -> User? {
        let context = coreDataStack.context
        let request: NSFetchRequest<CDUser> = NSFetchRequest(entityName: "CDUser")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(request)
            return results.first.map { mapToUser($0) }
        } catch {
            print("Failed to fetch user: \(error)")
            return nil
        }
    }
    
    private func mapToUser(_ cdUser: CDUser) -> User {
        return User(
            id: cdUser.id,
            email: cdUser.email,
            firstName: cdUser.firstName,
            lastName: cdUser.lastName,
            role: UserRole(rawValue: cdUser.role) ?? .patient,
            clinicId: cdUser.clinicId,
            assignedTherapistId: cdUser.assignedTherapistId,
            createdAt: cdUser.createdAt,
            isActive: cdUser.isActive
        )
    }
    
    // MARK: - Session Management
    
    func saveSession(_ session: MovementSession, summary: ExerciseSessionSummary, repDetails: [RepDetail]) {
        let context = coreDataStack.context
        
        let cdSession = CDExerciseSession(context: context)
        cdSession.id = session.id.uuidString
        cdSession.exerciseId = session.exercise.id
        cdSession.exerciseName = session.exercise.name
        cdSession.userId = AuthenticationService.shared.currentUser?.id ?? ""
        cdSession.startTime = session.startTime
        cdSession.endTime = session.endTime
        cdSession.repetitions = Int32(session.repetitions)
        cdSession.targetReps = Int32(session.exercise.defaultReps)
        cdSession.averageFormScore = summary.averageFormScore
        cdSession.peakFormScore = summary.peakPerformance
        cdSession.duration = summary.duration
        cdSession.caloriesBurned = calculateCaloriesBurned(exercise: session.exercise, duration: summary.duration)
        cdSession.isSynced = false
        
        // Save rep details
        for (index, repDetail) in repDetails.enumerated() {
            let cdRep = CDRepDetail(context: context)
            cdRep.repNumber = Int32(index + 1)
            cdRep.formScore = repDetail.formScore
            cdRep.timestamp = repDetail.timestamp
            cdRep.duration = repDetail.duration
            cdRep.angleData = repDetail.angleData
            cdRep.session = cdSession
        }
        
        // Save form feedback
        for mistake in summary.commonMistakes {
            let cdFeedback = CDFormFeedback(context: context)
            cdFeedback.id = UUID().uuidString
            cdFeedback.timestamp = mistake.timestamp
            cdFeedback.message = mistake.description
            cdFeedback.feedbackType = "mistake"
            cdFeedback.mistakeType = mistake.type.rawValue
            cdFeedback.severity = mistake.severity
            cdFeedback.session = cdSession
        }
        
        // Update achievement progress
        updateAchievementProgress(for: session)
        
        coreDataStack.save()
    }
    
    func getSessions(for userId: String, limit: Int = 50) -> [SessionData] {
        let context = coreDataStack.context
        let request: NSFetchRequest<CDExerciseSession> = NSFetchRequest(entityName: "CDExerciseSession")
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        request.fetchLimit = limit
        
        do {
            let results = try context.fetch(request)
            return results.map { mapToSessionData($0) }
        } catch {
            print("Failed to fetch sessions: \(error)")
            return []
        }
    }
    
    func getSessionsForExercise(_ exerciseId: String, userId: String) -> [SessionData] {
        let context = coreDataStack.context
        let request: NSFetchRequest<CDExerciseSession> = NSFetchRequest(entityName: "CDExerciseSession")
        request.predicate = NSPredicate(format: "userId == %@ AND exerciseId == %@", userId, exerciseId)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            return results.map { mapToSessionData($0) }
        } catch {
            print("Failed to fetch exercise sessions: \(error)")
            return []
        }
    }
    
    private func mapToSessionData(_ cdSession: CDExerciseSession) -> SessionData {
        return SessionData(
            id: cdSession.id,
            exerciseId: cdSession.exerciseId,
            exerciseName: cdSession.exerciseName,
            startTime: cdSession.startTime,
            endTime: cdSession.endTime,
            repetitions: Int(cdSession.repetitions),
            targetReps: Int(cdSession.targetReps),
            averageFormScore: cdSession.averageFormScore,
            duration: cdSession.duration,
            caloriesBurned: cdSession.caloriesBurned
        )
    }
    
    // MARK: - Progress Tracking
    
    func getProgressData(for userId: String, days: Int = 30) -> ProgressData {
        let context = coreDataStack.context
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        let request: NSFetchRequest<CDExerciseSession> = NSFetchRequest(entityName: "CDExerciseSession")
        request.predicate = NSPredicate(format: "userId == %@ AND startTime >= %@", userId, startDate as NSDate)
        
        do {
            let sessions = try context.fetch(request)
            
            // Calculate metrics
            let totalSessions = sessions.count
            let totalReps = sessions.reduce(0) { $0 + Int($1.repetitions) }
            let avgFormScore = sessions.isEmpty ? 0 : sessions.reduce(0) { $0 + $1.averageFormScore } / Double(sessions.count)
            let totalDuration = sessions.reduce(0) { $0 + $1.duration }
            let totalCalories = sessions.reduce(0) { $0 + $1.caloriesBurned }
            
            // Calculate streak
            let streak = calculateStreak(sessions: sessions)
            
            // Group by date for chart data
            let chartData = generateChartData(sessions: sessions)
            
            return ProgressData(
                totalSessions: totalSessions,
                totalReps: totalReps,
                averageFormScore: avgFormScore,
                totalDuration: totalDuration,
                totalCalories: totalCalories,
                currentStreak: streak,
                chartData: chartData
            )
        } catch {
            print("Failed to fetch progress data: \(error)")
            return ProgressData.empty
        }
    }
    
    private func calculateStreak(sessions: [CDExerciseSession]) -> Int {
        let calendar = Calendar.current
        let sortedSessions = sessions.sorted { $0.startTime > $1.startTime }
        
        var streak = 0
        var currentDate = Date()
        
        for session in sortedSessions {
            let sessionDate = calendar.startOfDay(for: session.startTime)
            let checkDate = calendar.startOfDay(for: currentDate)
            
            if sessionDate == checkDate {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if sessionDate < checkDate {
                break
            }
        }
        
        return streak
    }
    
    private func generateChartData(sessions: [CDExerciseSession]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        var dataByDate: [Date: (sessions: Int, formScore: Double)] = [:]
        
        for session in sessions {
            let date = calendar.startOfDay(for: session.startTime)
            var data = dataByDate[date] ?? (sessions: 0, formScore: 0)
            data.sessions += 1
            data.formScore = (data.formScore * Double(data.sessions - 1) + session.averageFormScore) / Double(data.sessions)
            dataByDate[date] = data
        }
        
        return dataByDate.map { ChartDataPoint(date: $0.key, value: $0.value.formScore, count: $0.value.sessions) }
            .sorted { $0.date < $1.date }
    }
    
    // MARK: - Achievement Management
    
    func initializeAchievements(for userId: String) {
        let context = coreDataStack.context
        
        let achievementTypes = [
            ("first_exercise", "First Steps", "Complete your first exercise", "star.fill", 1.0),
            ("week_streak", "Week Warrior", "Exercise for 7 days in a row", "flame.fill", 7.0),
            ("perfect_form", "Form Master", "Get 95%+ form score", "checkmark.seal.fill", 95.0),
            ("hundred_reps", "Century Club", "Complete 100 total reps", "100.circle.fill", 100.0),
            ("month_streak", "Dedicated", "Exercise for 30 days", "calendar.circle.fill", 30.0)
        ]
        
        for (type, name, description, icon, target) in achievementTypes {
            let cdAchievement = CDAchievement(context: context)
            cdAchievement.id = "\(userId)_\(type)"
            cdAchievement.type = type
            cdAchievement.name = name
            cdAchievement.descriptionText = description
            cdAchievement.iconName = icon
            cdAchievement.targetValue = target
            cdAchievement.currentValue = 0
            cdAchievement.progress = 0
        }
        
        coreDataStack.save()
    }
    
    func updateAchievementProgress(for session: MovementSession) {
        guard let userId = AuthenticationService.shared.currentUser?.id else { return }
        
        let context = coreDataStack.context
        let request: NSFetchRequest<CDAchievement> = NSFetchRequest(entityName: "CDAchievement")
        request.predicate = NSPredicate(format: "id CONTAINS %@", userId)
        
        do {
            let achievements = try context.fetch(request)
            
            for achievement in achievements {
                switch achievement.type {
                case "first_exercise":
                    if achievement.unlockedAt == nil {
                        achievement.currentValue = 1
                        achievement.progress = 1
                        achievement.unlockedAt = Date()
                    }
                    
                case "hundred_reps":
                    let totalReps = getTotalReps(for: userId)
                    achievement.currentValue = Double(totalReps)
                    achievement.progress = min(1.0, Double(totalReps) / achievement.targetValue)
                    if achievement.progress >= 1.0 && achievement.unlockedAt == nil {
                        achievement.unlockedAt = Date()
                    }
                    
                case "perfect_form":
                    if session.formScore >= 95 && achievement.unlockedAt == nil {
                        achievement.currentValue = session.formScore
                        achievement.progress = 1
                        achievement.unlockedAt = Date()
                    }
                    
                default:
                    break
                }
            }
            
            coreDataStack.save()
        } catch {
            print("Failed to update achievements: \(error)")
        }
    }
    
    func getAchievements(for userId: String) -> [Achievement] {
        let context = coreDataStack.context
        let request: NSFetchRequest<CDAchievement> = NSFetchRequest(entityName: "CDAchievement")
        request.predicate = NSPredicate(format: "id CONTAINS %@", userId)
        
        do {
            let results = try context.fetch(request)
            return results.map { mapToAchievement($0) }
        } catch {
            print("Failed to fetch achievements: \(error)")
            return []
        }
    }
    
    private func mapToAchievement(_ cdAchievement: CDAchievement) -> Achievement {
        return Achievement(
            id: cdAchievement.id,
            type: cdAchievement.type,
            name: cdAchievement.name,
            description: cdAchievement.descriptionText,
            iconName: cdAchievement.iconName,
            isUnlocked: cdAchievement.unlockedAt != nil,
            unlockedAt: cdAchievement.unlockedAt,
            progress: cdAchievement.progress,
            currentValue: cdAchievement.currentValue,
            targetValue: cdAchievement.targetValue
        )
    }
    
    // MARK: - Sync Management
    
    func syncPendingData(completion: @escaping (Bool) -> Void) {
        coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<CDExerciseSession> = NSFetchRequest(entityName: "CDExerciseSession")
            request.predicate = NSPredicate(format: "isSynced == NO")
            
            do {
                let unsyncedSessions = try context.fetch(request)
                
                // In a real app, this would upload to a server
                // For now, we'll just mark them as synced
                for session in unsyncedSessions {
                    session.isSynced = true
                }
                
                try context.save()
                
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Failed to sync data: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTotalReps(for userId: String) -> Int {
        let context = coreDataStack.context
        let request: NSFetchRequest<CDExerciseSession> = NSFetchRequest(entityName: "CDExerciseSession")
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let sessions = try context.fetch(request)
            return sessions.reduce(0) { $0 + Int($1.repetitions) }
        } catch {
            return 0
        }
    }
    
    private func calculateCaloriesBurned(exercise: Exercise, duration: TimeInterval) -> Double {
        // Simple calorie calculation based on MET values
        let metValues: [ExerciseCategory: Double] = [
            .upperBody: 3.5,
            .lowerBody: 5.0,
            .core: 3.0,
            .balance: 2.5,
            .flexibility: 2.0,
            .cardio: 7.0
        ]
        
        let met = metValues[exercise.category] ?? 3.0
        let weightKg = 70.0 // Default weight, should be user-specific
        let hours = duration / 3600
        
        return met * weightKg * hours
    }
}
