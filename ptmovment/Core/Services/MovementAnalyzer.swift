import Foundation
import Vision
import UIKit

// MARK: - Enhanced Movement Analyzer
class EnhancedMovementAnalyzer {
    private var previousPoses: [VNHumanBodyPoseObservation] = []
    private var exerciseAnalyzer: ExerciseAnalyzer
    private var sessionData: ExerciseSessionData
    
    init(exercise: Exercise) {
        self.exerciseAnalyzer = ExerciseAnalyzerFactory.createAnalyzer(for: exercise)
        self.sessionData = ExerciseSessionData(exerciseId: exercise.id)
    }
    
    func analyzeMovement(poses: [VNHumanBodyPoseObservation]) -> AnalysisResult {
        guard let currentPose = poses.first else {
            return AnalysisResult(repCount: sessionData.repCount, feedback: "Position yourself in view", feedbackType: .needsImprovement)
        }
        
        // Store pose history for trend analysis
        previousPoses.append(currentPose)
        if previousPoses.count > 30 { // Keep last 30 frames (1 second at 30fps)
            previousPoses.removeFirst()
        }
        
        // Analyze with specific exercise logic
        let result = exerciseAnalyzer.analyze(currentPose: currentPose, poseHistory: previousPoses, sessionData: &sessionData)
        
        return result
    }
    
    func resetSession() {
        sessionData.reset()
        previousPoses.removeAll()
        exerciseAnalyzer.reset()
    }
    
    func getSessionSummary() -> ExerciseSessionSummary {
        return ExerciseSessionSummary(
            exerciseId: sessionData.exerciseId,
            totalReps: sessionData.repCount,
            averageFormScore: sessionData.getAverageFormScore(),
            duration: sessionData.getDuration(),
            peakPerformance: sessionData.getPeakPerformance(),
            commonMistakes: sessionData.getCommonMistakes()
        )
    }
}

// MARK: - Exercise Session Data
class ExerciseSessionData {
    let exerciseId: String
    let startTime: Date
    var repCount: Int = 0
    var formScores: [Double] = []
    var detectedMistakes: [FormMistake] = []
    var currentPhase: ExercisePhase = .ready
    var lastPhaseChange: Date = Date()
    var isInCorrectPosition: Bool = false
    var timeInCorrectPosition: TimeInterval = 0
    
    init(exerciseId: String) {
        self.exerciseId = exerciseId
        self.startTime = Date()
    }
    
    func addFormScore(_ score: Double) {
        formScores.append(score)
    }
    
    func addMistake(_ mistake: FormMistake) {
        detectedMistakes.append(mistake)
    }
    
    func getAverageFormScore() -> Double {
        return formScores.isEmpty ? 0 : formScores.reduce(0, +) / Double(formScores.count)
    }
    
    func getDuration() -> TimeInterval {
        return Date().timeIntervalSince(startTime)
    }
    
    func getPeakPerformance() -> Double {
        return formScores.max() ?? 0
    }
    
    func getCommonMistakes() -> [FormMistake] {
        let mistakeCounts = Dictionary(grouping: detectedMistakes) { $0.type }
        return mistakeCounts.compactMap { (type, mistakes) in
            mistakes.count >= 3 ? mistakes.first : nil
        }
    }
    
    func reset() {
        repCount = 0
        formScores.removeAll()
        detectedMistakes.removeAll()
        currentPhase = .ready
        isInCorrectPosition = false
        timeInCorrectPosition = 0
    }
}

// MARK: - Exercise Types & Phases
enum ExercisePhase {
    case ready, starting, midMovement, peak, returning, completed
}

enum FormMistakeType: String {
    case kneesCaveIn = "knees_cave_in"
    case forwardLean = "forward_lean"
    case shallowDepth = "shallow_depth"
    case armPosition = "arm_position"
    case asymmetricMovement = "asymmetric_movement"
    case speedTooFast = "speed_too_fast"
    case balanceIssue = "balance_issue"
}

struct FormMistake {
    let type: FormMistakeType
    let severity: Double // 0.0 to 1.0
    let timestamp: Date
    let description: String
    let correction: String
}

// MARK: - Exercise Analyzer Protocol
protocol ExerciseAnalyzer {
    func analyze(currentPose: VNHumanBodyPoseObservation, poseHistory: [VNHumanBodyPoseObservation], sessionData: inout ExerciseSessionData) -> AnalysisResult
    func reset()
}

// MARK: - Exercise Analyzer Factory
class ExerciseAnalyzerFactory {
    static func createAnalyzer(for exercise: Exercise) -> ExerciseAnalyzer {
        switch exercise.id {
        case "squats":
            return SquatAnalyzer()
        case "shoulder-raise":
            return ShoulderRaiseAnalyzer()
        case "balance-stand":
            return BalanceAnalyzer()
        case "arm-circles":
            return ArmCircleAnalyzer()
        default:
            return ShoulderRaiseAnalyzer() // Default fallback
        }
    }
}

// MARK: - Squat Analyzer
class SquatAnalyzer: ExerciseAnalyzer {
    private var isInSquatPosition = false
    private var deepestPoint: Double = 0
    private var lastStateChange = Date()
    private let minimumHoldTime: TimeInterval = 0.3
    private let minimumTransitionTime: TimeInterval = 0.5
    
    func analyze(currentPose: VNHumanBodyPoseObservation, poseHistory: [VNHumanBodyPoseObservation], sessionData: inout ExerciseSessionData) -> AnalysisResult {
        
        guard let recognizedPoints = try? currentPose.recognizedPoints(forGroupKey: .all) else {
            return AnalysisResult(repCount: sessionData.repCount, feedback: "Position yourself in view", feedbackType: .needsImprovement)
        }
        
        // Extract key points for squat analysis
        guard let leftHip = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftHip.rawValue],
              let rightHip = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightHip.rawValue],
              let leftKnee = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftKnee.rawValue],
              let rightKnee = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightKnee.rawValue],
              let leftAnkle = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftAnkle.rawValue],
              let rightAnkle = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightAnkle.rawValue],
              let leftShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftShoulder.rawValue],
              let rightShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightShoulder.rawValue]
        else {
            return AnalysisResult(
                repCount: sessionData.repCount,
                feedback: "Stand facing the camera",
                feedbackType: .needsImprovement
            )
        }



        
        // Check confidence levels
        let requiredConfidence: Float = 0.4
        guard leftHip.confidence > requiredConfidence && rightHip.confidence > requiredConfidence &&
              leftKnee.confidence > requiredConfidence && rightKnee.confidence > requiredConfidence &&
              leftAnkle.confidence > requiredConfidence && rightAnkle.confidence > requiredConfidence else {
            return AnalysisResult(repCount: sessionData.repCount, feedback: "Move closer to camera", feedbackType: .needsImprovement)
        }
        
        // Calculate squat metrics
        let squatMetrics = calculateSquatMetrics(
            leftHip: leftHip, rightHip: rightHip,
            leftKnee: leftKnee, rightKnee: rightKnee,
            leftAnkle: leftAnkle, rightAnkle: rightAnkle,
            leftShoulder: leftShoulder, rightShoulder: rightShoulder
        )
        
        // Analyze form and detect mistakes
        let formAnalysis = analyzeSquatForm(metrics: squatMetrics, sessionData: &sessionData)
        
        // Determine squat phase and count reps
        let phaseAnalysis = analyzeSquatPhase(metrics: squatMetrics, sessionData: &sessionData)
        
        // Generate feedback
        let feedback = generateSquatFeedback(formAnalysis: formAnalysis, phaseAnalysis: phaseAnalysis, metrics: squatMetrics, sessionData: sessionData)

        return feedback
    }
    
    private func calculateSquatMetrics(
        leftHip: VNRecognizedPoint, rightHip: VNRecognizedPoint,
        leftKnee: VNRecognizedPoint, rightKnee: VNRecognizedPoint,
        leftAnkle: VNRecognizedPoint, rightAnkle: VNRecognizedPoint,
        leftShoulder: VNRecognizedPoint, rightShoulder: VNRecognizedPoint
    ) -> SquatMetrics {
        
        // Calculate knee angles (hip-knee-ankle)
        let leftKneeAngle = calculateAngle(
            point1: leftHip.location,
            point2: leftKnee.location,
            point3: leftAnkle.location
        )
        
        let rightKneeAngle = calculateAngle(
            point1: rightHip.location,
            point2: rightKnee.location,
            point3: rightAnkle.location
        )
        
        // Calculate hip depth (how low the hips are)
        let avgHipHeight = (leftHip.location.y + rightHip.location.y) / 2
        let avgKneeHeight = (leftKnee.location.y + rightKnee.location.y) / 2
        let hipToKneeRatio = avgHipHeight / avgKneeHeight
        
        // Calculate torso lean (shoulder to hip angle)
        let avgShoulderPos = CGPoint(
            x: (leftShoulder.location.x + rightShoulder.location.x) / 2,
            y: (leftShoulder.location.y + rightShoulder.location.y) / 2
        )
        let avgHipPos = CGPoint(
            x: (leftHip.location.x + rightHip.location.x) / 2,
            y: (leftHip.location.y + rightHip.location.y) / 2
        )
        
        let torsoAngle = calculateVerticalAngle(top: avgShoulderPos, bottom: avgHipPos)
        
        // Calculate knee tracking (are knees caving in?)
        let kneeDistance = abs(leftKnee.location.x - rightKnee.location.x)
        let hipDistance = abs(leftHip.location.x - rightHip.location.x)
        let kneeTrackingRatio = kneeDistance / hipDistance
        
        return SquatMetrics(
            leftKneeAngle: leftKneeAngle,
            rightKneeAngle: rightKneeAngle,
            hipDepth: hipToKneeRatio,
            torsoLean: torsoAngle,
            kneeTracking: kneeTrackingRatio,
            symmetry: abs(leftKneeAngle - rightKneeAngle)
        )
    }
    
    private func analyzeSquatForm(metrics: SquatMetrics, sessionData: inout ExerciseSessionData) -> SquatFormAnalysis {
        var mistakes: [FormMistake] = []
        var formScore: Double = 100.0
        
        // Check knee cave-in (knees should track over toes)
        if metrics.kneeTracking < 0.8 {
            let severity = (0.8 - metrics.kneeTracking) * 2
            mistakes.append(FormMistake(
                type: .kneesCaveIn,
                severity: severity,
                timestamp: Date(),
                description: "Knees are caving inward",
                correction: "Push knees out over your toes"
            ))
            formScore -= severity * 20
        }
        
        // Check squat depth
        if metrics.hipDepth > 1.1 {
            let severity = min(1.0, (metrics.hipDepth - 1.1) * 3)
            mistakes.append(FormMistake(
                type: .shallowDepth,
                severity: severity,
                timestamp: Date(),
                description: "Squat depth too shallow",
                correction: "Lower your hips below knee level"
            ))
            formScore -= severity * 15
        }
        
        // Check forward lean
        if metrics.torsoLean > 30 {
            let severity = min(1.0, (metrics.torsoLean - 30) / 30)
            mistakes.append(FormMistake(
                type: .forwardLean,
                severity: severity,
                timestamp: Date(),
                description: "Leaning too far forward",
                correction: "Keep chest up and back straight"
            ))
            formScore -= severity * 25
        }
        
        // Check symmetry
        if metrics.symmetry > 15 {
            let severity = min(1.0, (metrics.symmetry - 15) / 30)
            mistakes.append(FormMistake(
                type: .asymmetricMovement,
                severity: severity,
                timestamp: Date(),
                description: "Asymmetric movement",
                correction: "Keep both sides moving evenly"
            ))
            formScore -= severity * 20
        }
        
        // Add mistakes to session data
        mistakes.forEach { sessionData.addMistake($0) }
        
        formScore = max(0, formScore)
        sessionData.addFormScore(formScore)
        
        return SquatFormAnalysis(
            formScore: formScore,
            mistakes: mistakes,
            depth: metrics.hipDepth,
            symmetry: metrics.symmetry
        )
    }
    
    private func analyzeSquatPhase(metrics: SquatMetrics, sessionData: inout ExerciseSessionData) -> SquatPhaseAnalysis {
        let avgKneeAngle = (metrics.leftKneeAngle + metrics.rightKneeAngle) / 2
        let timeSinceLastChange = Date().timeIntervalSince(lastStateChange)
        
        // Determine if currently in squat position (knee angle < 120 degrees = squatting)
        let currentlySquatting = avgKneeAngle < 120
        
        var repCounted = false
        var currentPhase: ExercisePhase = sessionData.currentPhase
        
        // State machine for squat phases
        if currentlySquatting && !isInSquatPosition && timeSinceLastChange > minimumTransitionTime {
            // Entering squat position
            isInSquatPosition = true
            lastStateChange = Date()
            currentPhase = .midMovement
            deepestPoint = avgKneeAngle
        } else if !currentlySquatting && isInSquatPosition && timeSinceLastChange > minimumHoldTime {
            // Exiting squat position - count rep if depth was sufficient
            if deepestPoint < 110 { // Good squat depth
                sessionData.repCount += 1
                repCounted = true
                currentPhase = .completed
            }
            isInSquatPosition = false
            lastStateChange = Date()
            deepestPoint = 0
        } else if currentlySquatting && isInSquatPosition {
            // Track deepest point during squat
            deepestPoint = min(deepestPoint, avgKneeAngle)
            currentPhase = avgKneeAngle < 100 ? .peak : .midMovement
        }
        
        sessionData.currentPhase = currentPhase
        
        return SquatPhaseAnalysis(
            currentPhase: currentPhase,
            isSquatting: currentlySquatting,
            depth: deepestPoint,
            repCounted: repCounted
        )
    }
    
    private func generateSquatFeedback(formAnalysis: SquatFormAnalysis, phaseAnalysis: SquatPhaseAnalysis, metrics: SquatMetrics, sessionData: ExerciseSessionData) -> AnalysisResult {
        var feedback = "Keep going!"
        var feedbackType = FeedbackType.good
        
        // Priority feedback based on current mistakes
        if let primaryMistake = formAnalysis.mistakes.max(by: { $0.severity < $1.severity }) {
            feedback = primaryMistake.correction
            feedbackType = primaryMistake.severity > 0.7 ? .poor : .needsImprovement
        } else if phaseAnalysis.isSquatting {
            if phaseAnalysis.currentPhase == .peak {
                feedback = "Perfect depth! Now stand up"
                feedbackType = .excellent
            } else {
                feedback = "Keep lowering - go deeper"
                feedbackType = .good
            }
        } else if formAnalysis.formScore > 85 {
            feedback = "Excellent form!"
            feedbackType = .excellent
        }
        
        return AnalysisResult(
            repCount: sessionData.repCount,
            feedback: feedback,
            feedbackType: feedbackType
        )
    }
    
    func reset() {
        isInSquatPosition = false
        deepestPoint = 0
        lastStateChange = Date()
    }
}

// MARK: - Enhanced Shoulder Raise Analyzer
class ShoulderRaiseAnalyzer: ExerciseAnalyzer {
    private var isInUpPosition = false
    private var timeInUpPosition: TimeInterval = 0
    private var timeInDownPosition: TimeInterval = 0
    private var lastStateChange = Date()
    private let minimumHoldTime: TimeInterval = 0.5
    private let minimumTransitionTime: TimeInterval = 0.3
    
    func analyze(currentPose: VNHumanBodyPoseObservation, poseHistory: [VNHumanBodyPoseObservation], sessionData: inout ExerciseSessionData) -> AnalysisResult {
        
        guard let recognizedPoints = try? currentPose.recognizedPoints(forGroupKey: .all) else {
            return AnalysisResult(repCount: sessionData.repCount, feedback: "Position yourself in view", feedbackType: .needsImprovement)
        }
        
        // Enhanced shoulder raise analysis with better form checking
        let shoulderMetrics = calculateShoulderMetrics(recognizedPoints: recognizedPoints)
        let phaseAnalysis = analyzeShoulderPhase(metrics: shoulderMetrics, sessionData: &sessionData)
        let feedback = generateShoulderFeedback(metrics: shoulderMetrics, phase: phaseAnalysis)
        
        return AnalysisResult(
            repCount: sessionData.repCount,
            feedback: feedback.message,
            feedbackType: feedback.type
        )
    }
    
    private func calculateShoulderMetrics(recognizedPoints: [VNRecognizedPointKey: VNRecognizedPoint]) -> ShoulderMetrics {
        guard let leftShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftShoulder.rawValue],
              let rightShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightShoulder.rawValue],
              let leftElbow = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftElbow.rawValue],
              let rightElbow = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightElbow.rawValue],
              let leftWrist = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftWrist.rawValue],
              let rightWrist = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightWrist.rawValue] else {
            return ShoulderMetrics(leftArmElevation: 0, rightArmElevation: 0, symmetry: 0, formScore: 0)
        }
        
        // Calculate arm elevation angles
        let leftElevation = calculateArmElevation(shoulder: leftShoulder.location, elbow: leftElbow.location, wrist: leftWrist.location)
        let rightElevation = calculateArmElevation(shoulder: rightShoulder.location, elbow: rightElbow.location, wrist: rightWrist.location)
        
        // Calculate symmetry
        let symmetry = 100 - min(100, abs(leftElevation - rightElevation) * 2)
        
        // Calculate form score
        let targetElevation: Double = 90 // Ideal arm elevation
        let leftScore = max(0, 100 - abs(targetElevation - leftElevation) * 2)
        let rightScore = max(0, 100 - abs(targetElevation - rightElevation) * 2)
        let formScore = (leftScore + rightScore + symmetry) / 3
        
        return ShoulderMetrics(
            leftArmElevation: leftElevation,
            rightArmElevation: rightElevation,
            symmetry: symmetry,
            formScore: formScore
        )
    }
    
    private func calculateArmElevation(shoulder: CGPoint, elbow: CGPoint, wrist: CGPoint) -> Double {
        // Calculate the angle of arm elevation from horizontal
        let shoulderToWrist = CGPoint(x: wrist.x - shoulder.x, y: wrist.y - shoulder.y)
        let angle = atan2(shoulderToWrist.y, shoulderToWrist.x) * 180 / .pi
        return abs(angle)
    }
    
    private func analyzeShoulderPhase(metrics: ShoulderMetrics, sessionData: inout ExerciseSessionData) -> ShoulderPhaseAnalysis {
        let avgElevation = (metrics.leftArmElevation + metrics.rightArmElevation) / 2
        let timeSinceLastChange = Date().timeIntervalSince(lastStateChange)
        
        let currentlyRaised = avgElevation > 60 // Arms raised above 60 degrees
        
        var repCounted = false
        
        if currentlyRaised && !isInUpPosition && timeSinceLastChange > minimumTransitionTime {
            isInUpPosition = true
            lastStateChange = Date()
            timeInUpPosition = 0
        } else if !currentlyRaised && isInUpPosition && timeSinceLastChange > minimumHoldTime {
            sessionData.repCount += 1
            repCounted = true
            isInUpPosition = false
            lastStateChange = Date()
            timeInDownPosition = 0
        }
        
        if isInUpPosition {
            timeInUpPosition = Date().timeIntervalSince(lastStateChange)
        } else {
            timeInDownPosition = Date().timeIntervalSince(lastStateChange)
        }
        
        sessionData.addFormScore(metrics.formScore)
        
        return ShoulderPhaseAnalysis(
            isRaised: currentlyRaised,
            timeInPosition: isInUpPosition ? timeInUpPosition : timeInDownPosition,
            repCounted: repCounted
        )
    }
    
    private func generateShoulderFeedback(metrics: ShoulderMetrics, phase: ShoulderPhaseAnalysis) -> (message: String, type: FeedbackType) {
        if metrics.formScore > 90 {
            return ("Excellent form!", .excellent)
        } else if metrics.symmetry < 70 {
            return ("Keep arms level", .needsImprovement)
        } else if !phase.isRaised {
            return ("Raise your arms to shoulder height", .needsImprovement)
        } else if phase.timeInPosition < minimumHoldTime {
            return ("Hold the position", .good)
        } else {
            return ("Great! Now lower slowly", .good)
        }
    }
    
    func reset() {
        isInUpPosition = false
        timeInUpPosition = 0
        timeInDownPosition = 0
        lastStateChange = Date()
    }
}

// MARK: - Balance Analyzer
class BalanceAnalyzer: ExerciseAnalyzer {
    private var balanceStartTime: Date?
    private var currentBalanceTime: TimeInterval = 0
    private var centerOfGravityHistory: [CGPoint] = []
    private let targetBalanceTime: TimeInterval = 30.0 // 30 seconds
    
    func analyze(currentPose: VNHumanBodyPoseObservation, poseHistory: [VNHumanBodyPoseObservation], sessionData: inout ExerciseSessionData) -> AnalysisResult {
        
        guard let recognizedPoints = try? currentPose.recognizedPoints(forGroupKey: .all) else {
            return AnalysisResult(repCount: 0, feedback: "Position yourself in view", feedbackType: .needsImprovement)
        }
        
        // Calculate center of gravity and stability
        let stabilityMetrics = calculateStabilityMetrics(recognizedPoints: recognizedPoints)
        
        // Track balance duration
        if stabilityMetrics.isBalanced {
            if balanceStartTime == nil {
                balanceStartTime = Date()
            }
            currentBalanceTime = Date().timeIntervalSince(balanceStartTime!)
        } else {
            balanceStartTime = nil
            currentBalanceTime = 0
        }
        
        // Calculate progress percentage
        let progress = min(100, (currentBalanceTime / targetBalanceTime) * 100)
        
        // Generate feedback
        let feedback = generateBalanceFeedback(metrics: stabilityMetrics, progress: progress)
        
        // Update session data
        sessionData.addFormScore(stabilityMetrics.stabilityScore)
        if currentBalanceTime >= targetBalanceTime {
            sessionData.repCount = 1 // Balance exercise is binary - completed or not
        }
        
        return AnalysisResult(
            repCount: sessionData.repCount,
            feedback: feedback.message,
            feedbackType: feedback.type
        )
    }
    
    private func calculateStabilityMetrics(recognizedPoints: [VNRecognizedPointKey: VNRecognizedPoint]) -> StabilityMetrics {
        // Calculate center of gravity
        let centerOfGravity = calculateCenterOfGravity(recognizedPoints: recognizedPoints)
        
        // Track center of gravity movement
        centerOfGravityHistory.append(centerOfGravity)
        if centerOfGravityHistory.count > 60 { // Keep 2 seconds of history at 30fps
            centerOfGravityHistory.removeFirst()
        }
        
        // Calculate stability score based on movement variance
        let movement = calculateMovementVariance()
        let stabilityScore = max(0, 100 - (movement * 1000)) // Convert to percentage
        
        return StabilityMetrics(
            centerOfGravity: centerOfGravity,
            movementVariance: movement,
            stabilityScore: stabilityScore,
            isBalanced: stabilityScore > 70
        )
    }
    
    private func calculateCenterOfGravity(recognizedPoints: [VNRecognizedPointKey: VNRecognizedPoint]) -> CGPoint {
        // Simplified center of gravity calculation using key body points
        let keyPoints: [(VNRecognizedPointKey, Float)] = [
            (VNHumanBodyPoseObservation.JointName.neck.rawValue, 1.0),
            (VNHumanBodyPoseObservation.JointName.leftShoulder.rawValue, 0.8),
            (VNHumanBodyPoseObservation.JointName.rightShoulder.rawValue, 0.8),
            (VNHumanBodyPoseObservation.JointName.leftHip.rawValue, 1.2),
            (VNHumanBodyPoseObservation.JointName.rightHip.rawValue, 1.2),
            (VNHumanBodyPoseObservation.JointName.leftKnee.rawValue, 0.6),
            (VNHumanBodyPoseObservation.JointName.rightKnee.rawValue, 0.6)
        ]
        
        var weightedX: Float = 0
        var weightedY: Float = 0
        var totalWeight: Float = 0
        
        for (key, weight) in keyPoints {
            if let point = recognizedPoints[key], point.confidence > 0.3 {
                weightedX += Float(point.location.x) * weight
                weightedY += Float(point.location.y) * weight
                totalWeight += weight
            }
        }
        
        return CGPoint(
            x: CGFloat(weightedX / totalWeight),
            y: CGFloat(weightedY / totalWeight)
        )
    }
    
    private func calculateMovementVariance() -> Double {
        guard centerOfGravityHistory.count >= 10 else { return 1.0 }
        
        let recentPoints = Array(centerOfGravityHistory.suffix(10))
        let avgX = recentPoints.map { $0.x }.reduce(0, +) / CGFloat(recentPoints.count)
        let avgY = recentPoints.map { $0.y }.reduce(0, +) / CGFloat(recentPoints.count)
        
        let variance = recentPoints.map { point in
            let dx = point.x - avgX
            let dy = point.y - avgY
            return sqrt(dx * dx + dy * dy)
        }.reduce(0, +) / Double(recentPoints.count)
        
        return variance
    }
    
    private func generateBalanceFeedback(metrics: StabilityMetrics, progress: Double) -> (message: String, type: FeedbackType) {
        if progress >= 100 {
            return ("Balance complete! Excellent!", .excellent)
        } else if metrics.isBalanced {
            let remainingTime = Int((targetBalanceTime * (100 - progress) / 100))
            return ("Great balance! \(remainingTime)s remaining", .good)
        } else if metrics.stabilityScore > 50 {
            return ("Almost balanced - stay steady", .needsImprovement)
        } else {
            return ("Find your balance - small adjustments", .poor)
        }
    }
    
    func reset() {
        balanceStartTime = nil
        currentBalanceTime = 0
        centerOfGravityHistory.removeAll()
    }
}

// MARK: - Arm Circle Analyzer
class ArmCircleAnalyzer: ExerciseAnalyzer {
    private var completedCircles = 0
    private var currentAngle: Double = 0
    private var previousAngle: Double = 0
    private var circleProgress: Double = 0
    
    func analyze(currentPose: VNHumanBodyPoseObservation, poseHistory: [VNHumanBodyPoseObservation], sessionData: inout ExerciseSessionData) -> AnalysisResult {
        
        guard let recognizedPoints = try? currentPose.recognizedPoints(forGroupKey: .all) else {
            return AnalysisResult(repCount: sessionData.repCount, feedback: "Position yourself in view", feedbackType: .needsImprovement)
        }
        
        // Analyze arm circle movement
        let circleMetrics = calculateArmCircleMetrics(recognizedPoints: recognizedPoints)
        let circleAnalysis = analyzeCircleProgress(metrics: circleMetrics, sessionData: &sessionData)
        let feedback = generateCircleFeedback(analysis: circleAnalysis, metrics: circleMetrics)
        
        return AnalysisResult(
            repCount: sessionData.repCount,
            feedback: feedback.message,
            feedbackType: feedback.type
        )
    }
    
    private func calculateArmCircleMetrics(recognizedPoints: [VNRecognizedPointKey: VNRecognizedPoint]) -> ArmCircleMetrics {
        // Extract arm points
        guard let leftShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftShoulder.rawValue],
              let rightShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightShoulder.rawValue],
              let leftWrist = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftWrist.rawValue],
              let rightWrist = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightWrist.rawValue] else {
            return ArmCircleMetrics(leftArmAngle: 0, rightArmAngle: 0, symmetry: 0, formScore: 0)
        }
        
        // Calculate arm angles relative to shoulders
        let leftArmAngle = calculateAngleFromShoulder(shoulder: leftShoulder.location, wrist: leftWrist.location)
        let rightArmAngle = calculateAngleFromShoulder(shoulder: rightShoulder.location, wrist: rightWrist.location)
        
        // Calculate symmetry (how well arms move together)
        let symmetry = 100 - min(100, abs(leftArmAngle - rightArmAngle) * 2)
        
        // Calculate form score based on arm extension and symmetry
        let armExtension = calculateArmExtension(recognizedPoints: recognizedPoints)
        let formScore = (symmetry + armExtension) / 2
        
        return ArmCircleMetrics(
            leftArmAngle: leftArmAngle,
            rightArmAngle: rightArmAngle,
            symmetry: symmetry,
            formScore: formScore
        )
    }
    
    private func calculateAngleFromShoulder(shoulder: CGPoint, wrist: CGPoint) -> Double {
        let dx = wrist.x - shoulder.x
        let dy = wrist.y - shoulder.y
        let angle = atan2(dy, dx) * 180 / .pi
        return angle < 0 ? angle + 360 : angle
    }
    
    private func calculateArmExtension(recognizedPoints: [VNRecognizedPointKey: VNRecognizedPoint]) -> Double {
        // Check if arms are properly extended (elbows not too bent)
        guard let leftShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftShoulder.rawValue],
              let rightShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightShoulder.rawValue],
              let leftElbow = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftElbow.rawValue],
              let rightElbow = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightElbow.rawValue],
              let leftWrist = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftWrist.rawValue],
              let rightWrist = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightWrist.rawValue] else {
            return 0
        }
        
        let leftArmExtension = calculateArmExtensionAngle(shoulder: leftShoulder.location, elbow: leftElbow.location, wrist: leftWrist.location)
        let rightArmExtension = calculateArmExtensionAngle(shoulder: rightShoulder.location, elbow: rightElbow.location, wrist: rightWrist.location)
        
        // Good extension is close to 180 degrees (straight arm)
        let leftScore = max(0, 100 - abs(180 - leftArmExtension) * 2)
        let rightScore = max(0, 100 - abs(180 - rightArmExtension) * 2)
        
        return (leftScore + rightScore) / 2
    }
    
    private func calculateArmExtensionAngle(shoulder: CGPoint, elbow: CGPoint, wrist: CGPoint) -> Double {
        return calculateAngle(point1: shoulder, point2: elbow, point3: wrist)
    }
    
    private func analyzeCircleProgress(metrics: ArmCircleMetrics, sessionData: inout ExerciseSessionData) -> CircleAnalysis {
        // Track circle completion using arm angle changes
        let currentAngle = (metrics.leftArmAngle + metrics.rightArmAngle) / 2
        let angleDifference = currentAngle - previousAngle
        
        // Handle angle wraparound (360 -> 0 degrees)
        let normalizedDifference = if angleDifference > 180 {
            angleDifference - 360
        } else if angleDifference < -180 {
            angleDifference + 360
        } else {
            angleDifference
        }
        
        // Accumulate circle progress
        circleProgress += abs(normalizedDifference)
        
        // Complete circle when we've accumulated 360 degrees of movement
        if circleProgress >= 350 { // Allow some tolerance
            sessionData.repCount += 1
            circleProgress = 0
        }
        
        previousAngle = currentAngle
        sessionData.addFormScore(metrics.formScore)
        
        return CircleAnalysis(
            circleProgress: circleProgress / 360.0,
            completedCircles: sessionData.repCount,
            currentAngle: currentAngle
        )
    }
    
    private func generateCircleFeedback(analysis: CircleAnalysis, metrics: ArmCircleMetrics) -> (message: String, type: FeedbackType) {
        if metrics.formScore > 85 {
            return ("Perfect circles! Keep it up", .excellent)
        } else if metrics.symmetry < 60 {
            return ("Keep arms moving together", .needsImprovement)
        } else if metrics.formScore < 50 {
            return ("Extend arms fully during circles", .needsImprovement)
        } else {
            let progressPercent = Int(analysis.circleProgress * 100)
            return ("Circle \(progressPercent)% complete", .good)
        }
    }
    
    func reset() {
        completedCircles = 0
        currentAngle = 0
        previousAngle = 0
        circleProgress = 0
    }
}

// MARK: - Utility Functions
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

private func calculateVerticalAngle(top: CGPoint, bottom: CGPoint) -> Double {
    let dx = top.x - bottom.x
    let dy = top.y - bottom.y
    let angle = atan2(abs(dx), abs(dy)) * 180 / .pi
    return angle
}

// MARK: - Analysis Result Structures
struct SquatMetrics {
    let leftKneeAngle: Double
    let rightKneeAngle: Double
    let hipDepth: Double
    let torsoLean: Double
    let kneeTracking: Double
    let symmetry: Double
}

struct SquatFormAnalysis {
    let formScore: Double
    let mistakes: [FormMistake]
    let depth: Double
    let symmetry: Double
}

struct SquatPhaseAnalysis {
    let currentPhase: ExercisePhase
    let isSquatting: Bool
    let depth: Double
    let repCounted: Bool
}

struct StabilityMetrics {
    let centerOfGravity: CGPoint
    let movementVariance: Double
    let stabilityScore: Double
    let isBalanced: Bool
}

struct ArmCircleMetrics {
    let leftArmAngle: Double
    let rightArmAngle: Double
    let symmetry: Double
    let formScore: Double
}

struct CircleAnalysis {
    let circleProgress: Double // 0.0 to 1.0
    let completedCircles: Int
    let currentAngle: Double
}

struct ShoulderMetrics {
    let leftArmElevation: Double
    let rightArmElevation: Double
    let symmetry: Double
    let formScore: Double
}

struct ShoulderPhaseAnalysis {
    let isRaised: Bool
    let timeInPosition: TimeInterval
    let repCounted: Bool
}

struct ExerciseSessionSummary {
    let exerciseId: String
    let totalReps: Int
    let averageFormScore: Double
    let duration: TimeInterval
    let peakPerformance: Double
    let commonMistakes: [FormMistake]
}
