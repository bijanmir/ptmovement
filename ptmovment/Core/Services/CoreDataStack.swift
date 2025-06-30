import CoreData
import Foundation

// MARK: - Core Data Stack with Programmatic Model
class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        // Create the model programmatically
        let model = createManagedObjectModel()
        
        // Create container with the model
        let container = NSPersistentContainer(name: "ptmovment", managedObjectModel: model)
        
        // Enable automatic migration
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Core Data failed to load: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Create Model Programmatically
    private func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // CDUser Entity
        let userEntity = NSEntityDescription()
        userEntity.name = "CDUser"
        userEntity.managedObjectClassName = "CDUser"
        
        let userAttributes: [(String, NSAttributeType, Bool)] = [
            ("id", .stringAttributeType, false),
            ("email", .stringAttributeType, false),
            ("firstName", .stringAttributeType, false),
            ("lastName", .stringAttributeType, false),
            ("role", .stringAttributeType, false),
            ("clinicId", .stringAttributeType, true),
            ("assignedTherapistId", .stringAttributeType, true),
            ("createdAt", .dateAttributeType, false),
            ("isActive", .booleanAttributeType, false),
            ("lastSyncedAt", .dateAttributeType, true)
        ]
        
        userEntity.properties = userAttributes.map { name, type, isOptional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            return attribute
        }
        
        // CDExerciseSession Entity
        let sessionEntity = NSEntityDescription()
        sessionEntity.name = "CDExerciseSession"
        sessionEntity.managedObjectClassName = "CDExerciseSession"
        
        let sessionAttributes: [(String, NSAttributeType, Bool)] = [
            ("id", .stringAttributeType, false),
            ("exerciseId", .stringAttributeType, false),
            ("exerciseName", .stringAttributeType, false),
            ("userId", .stringAttributeType, false),
            ("startTime", .dateAttributeType, false),
            ("endTime", .dateAttributeType, true),
            ("repetitions", .integer32AttributeType, false),
            ("targetReps", .integer32AttributeType, false),
            ("averageFormScore", .doubleAttributeType, false),
            ("peakFormScore", .doubleAttributeType, false),
            ("duration", .doubleAttributeType, false),
            ("caloriesBurned", .doubleAttributeType, false),
            ("notes", .stringAttributeType, true),
            ("isSynced", .booleanAttributeType, false),
            ("assignmentId", .stringAttributeType, true)
        ]
        
        sessionEntity.properties = sessionAttributes.map { name, type, isOptional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            if type == .booleanAttributeType && name == "isSynced" {
                attribute.defaultValue = false
            }
            return attribute
        }
        
        // CDRepDetail Entity
        let repEntity = NSEntityDescription()
        repEntity.name = "CDRepDetail"
        repEntity.managedObjectClassName = "CDRepDetail"
        
        let repAttributes: [(String, NSAttributeType, Bool)] = [
            ("repNumber", .integer32AttributeType, false),
            ("formScore", .doubleAttributeType, false),
            ("timestamp", .dateAttributeType, false),
            ("duration", .doubleAttributeType, false),
            ("angleData", .binaryDataAttributeType, true)
        ]
        
        repEntity.properties = repAttributes.map { name, type, isOptional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            return attribute
        }
        
        // CDFormFeedback Entity
        let feedbackEntity = NSEntityDescription()
        feedbackEntity.name = "CDFormFeedback"
        feedbackEntity.managedObjectClassName = "CDFormFeedback"
        
        let feedbackAttributes: [(String, NSAttributeType, Bool)] = [
            ("id", .stringAttributeType, false),
            ("timestamp", .dateAttributeType, false),
            ("message", .stringAttributeType, false),
            ("feedbackType", .stringAttributeType, false),
            ("mistakeType", .stringAttributeType, true),
            ("severity", .doubleAttributeType, false)
        ]
        
        feedbackEntity.properties = feedbackAttributes.map { name, type, isOptional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            return attribute
        }
        
        // CDAchievement Entity
        let achievementEntity = NSEntityDescription()
        achievementEntity.name = "CDAchievement"
        achievementEntity.managedObjectClassName = "CDAchievement"
        
        let achievementAttributes: [(String, NSAttributeType, Bool)] = [
            ("id", .stringAttributeType, false),
            ("type", .stringAttributeType, false),
            ("name", .stringAttributeType, false),
            ("descriptionText", .stringAttributeType, false),
            ("iconName", .stringAttributeType, false),
            ("unlockedAt", .dateAttributeType, true),
            ("progress", .doubleAttributeType, false),
            ("targetValue", .doubleAttributeType, false),
            ("currentValue", .doubleAttributeType, false)
        ]
        
        achievementEntity.properties = achievementAttributes.map { name, type, isOptional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            if type == .doubleAttributeType && (name == "progress" || name == "currentValue") {
                attribute.defaultValue = 0.0
            }
            return attribute
        }
        
        // CDExerciseAssignment Entity
        let assignmentEntity = NSEntityDescription()
        assignmentEntity.name = "CDExerciseAssignment"
        assignmentEntity.managedObjectClassName = "CDExerciseAssignment"
        
        let assignmentAttributes: [(String, NSAttributeType, Bool)] = [
            ("id", .stringAttributeType, false),
            ("exerciseId", .stringAttributeType, false),
            ("exerciseName", .stringAttributeType, false),
            ("prescribedReps", .integer32AttributeType, false),
            ("prescribedDuration", .doubleAttributeType, false),
            ("frequencyPerWeek", .integer32AttributeType, false),
            ("startDate", .dateAttributeType, false),
            ("endDate", .dateAttributeType, true),
            ("priority", .stringAttributeType, false),
            ("notes", .stringAttributeType, true),
            ("isActive", .booleanAttributeType, false),
            ("completionRate", .doubleAttributeType, false),
            ("lastCompletedAt", .dateAttributeType, true)
        ]
        
        assignmentEntity.properties = assignmentAttributes.map { name, type, isOptional in
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            if type == .booleanAttributeType && name == "isActive" {
                attribute.defaultValue = true
            } else if type == .doubleAttributeType && name == "completionRate" {
                attribute.defaultValue = 0.0
            }
            return attribute
        }
        
        // Setup Relationships
        
        // User -> Sessions (One to Many)
        let userToSessions = NSRelationshipDescription()
        userToSessions.name = "sessions"
        userToSessions.destinationEntity = sessionEntity
        userToSessions.isOptional = true
        userToSessions.maxCount = 0
        userToSessions.deleteRule = .cascadeDeleteRule
        
        // Session -> User (Many to One)
        let sessionToUser = NSRelationshipDescription()
        sessionToUser.name = "user"
        sessionToUser.destinationEntity = userEntity
        sessionToUser.isOptional = true
        sessionToUser.maxCount = 1
        sessionToUser.inverseRelationship = userToSessions
        userToSessions.inverseRelationship = sessionToUser
        
        // Session -> RepDetails (One to Many)
        let sessionToReps = NSRelationshipDescription()
        sessionToReps.name = "repDetails"
        sessionToReps.destinationEntity = repEntity
        sessionToReps.isOptional = true
        sessionToReps.maxCount = 0
        sessionToReps.deleteRule = .cascadeDeleteRule
        
        // RepDetail -> Session (Many to One)
        let repToSession = NSRelationshipDescription()
        repToSession.name = "session"
        repToSession.destinationEntity = sessionEntity
        repToSession.isOptional = true
        repToSession.maxCount = 1
        repToSession.inverseRelationship = sessionToReps
        sessionToReps.inverseRelationship = repToSession
        
        // Session -> FormFeedback (One to Many)
        let sessionToFeedback = NSRelationshipDescription()
        sessionToFeedback.name = "formFeedback"
        sessionToFeedback.destinationEntity = feedbackEntity
        sessionToFeedback.isOptional = true
        sessionToFeedback.maxCount = 0
        sessionToFeedback.deleteRule = .cascadeDeleteRule
        
        // FormFeedback -> Session (Many to One)
        let feedbackToSession = NSRelationshipDescription()
        feedbackToSession.name = "session"
        feedbackToSession.destinationEntity = sessionEntity
        feedbackToSession.isOptional = true
        feedbackToSession.maxCount = 1
        feedbackToSession.inverseRelationship = sessionToFeedback
        sessionToFeedback.inverseRelationship = feedbackToSession
        
        // User -> Achievements (One to Many)
        let userToAchievements = NSRelationshipDescription()
        userToAchievements.name = "achievements"
        userToAchievements.destinationEntity = achievementEntity
        userToAchievements.isOptional = true
        userToAchievements.maxCount = 0
        userToAchievements.deleteRule = .cascadeDeleteRule
        
        // Achievement -> User (Many to One)
        let achievementToUser = NSRelationshipDescription()
        achievementToUser.name = "user"
        achievementToUser.destinationEntity = userEntity
        achievementToUser.isOptional = true
        achievementToUser.maxCount = 1
        achievementToUser.inverseRelationship = userToAchievements
        userToAchievements.inverseRelationship = achievementToUser
        
        // User -> Assignments (One to Many)
        let userToAssignments = NSRelationshipDescription()
        userToAssignments.name = "assignments"
        userToAssignments.destinationEntity = assignmentEntity
        userToAssignments.isOptional = true
        userToAssignments.maxCount = 0
        userToAssignments.deleteRule = .cascadeDeleteRule
        
        // Assignment -> User (Many to One)
        let assignmentToUser = NSRelationshipDescription()
        assignmentToUser.name = "user"
        assignmentToUser.destinationEntity = userEntity
        assignmentToUser.isOptional = true
        assignmentToUser.maxCount = 1
        assignmentToUser.inverseRelationship = userToAssignments
        userToAssignments.inverseRelationship = assignmentToUser
        
        // Add relationships to entities
        userEntity.properties.append(contentsOf: [userToSessions, userToAchievements, userToAssignments])
        sessionEntity.properties.append(contentsOf: [sessionToUser, sessionToReps, sessionToFeedback])
        repEntity.properties.append(repToSession)
        feedbackEntity.properties.append(feedbackToSession)
        achievementEntity.properties.append(achievementToUser)
        assignmentEntity.properties.append(assignmentToUser)
        
        // Add all entities to model
        model.entities = [userEntity, sessionEntity, repEntity, feedbackEntity, achievementEntity, assignmentEntity]
        
        return model
    }
}

// MARK: - NSManagedObject Subclasses
// These would normally be auto-generated, but we can define them here for convenience

@objc(CDUser)
public class CDUser: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var email: String
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var role: String
    @NSManaged public var clinicId: String?
    @NSManaged public var assignedTherapistId: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var isActive: Bool
    @NSManaged public var lastSyncedAt: Date?
    @NSManaged public var sessions: NSSet?
    @NSManaged public var assignments: NSSet?
    @NSManaged public var achievements: NSSet?
}

@objc(CDExerciseSession)
public class CDExerciseSession: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var exerciseId: String
    @NSManaged public var exerciseName: String
    @NSManaged public var userId: String
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date?
    @NSManaged public var repetitions: Int32
    @NSManaged public var targetReps: Int32
    @NSManaged public var averageFormScore: Double
    @NSManaged public var peakFormScore: Double
    @NSManaged public var duration: Double
    @NSManaged public var caloriesBurned: Double
    @NSManaged public var notes: String?
    @NSManaged public var isSynced: Bool
    @NSManaged public var assignmentId: String?
    @NSManaged public var user: CDUser?
    @NSManaged public var formFeedback: NSSet?
    @NSManaged public var repDetails: NSSet?
}

@objc(CDRepDetail)
public class CDRepDetail: NSManagedObject {
    @NSManaged public var repNumber: Int32
    @NSManaged public var formScore: Double
    @NSManaged public var timestamp: Date
    @NSManaged public var duration: Double
    @NSManaged public var angleData: Data?
    @NSManaged public var session: CDExerciseSession?
}

@objc(CDFormFeedback)
public class CDFormFeedback: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var timestamp: Date
    @NSManaged public var message: String
    @NSManaged public var feedbackType: String
    @NSManaged public var mistakeType: String?
    @NSManaged public var severity: Double
    @NSManaged public var session: CDExerciseSession?
}

@objc(CDAchievement)
public class CDAchievement: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var type: String
    @NSManaged public var name: String
    @NSManaged public var descriptionText: String
    @NSManaged public var iconName: String
    @NSManaged public var unlockedAt: Date?
    @NSManaged public var progress: Double
    @NSManaged public var targetValue: Double
    @NSManaged public var currentValue: Double
    @NSManaged public var user: CDUser?
}

@objc(CDExerciseAssignment)
public class CDExerciseAssignment: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var exerciseId: String
    @NSManaged public var exerciseName: String
    @NSManaged public var prescribedReps: Int32
    @NSManaged public var prescribedDuration: Double
    @NSManaged public var frequencyPerWeek: Int32
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var priority: String
    @NSManaged public var notes: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var completionRate: Double
    @NSManaged public var lastCompletedAt: Date?
    @NSManaged public var user: CDUser?
}
