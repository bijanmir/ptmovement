import Foundation
import Vision
import UIKit

// MARK: - Movement Analysis

class MovementAnalyzer {
    private var previousPoses: [VNHumanBodyPoseObservation] = []
    private var repCount = 0
    private var isInUpPosition = false
    private var timeInUpPosition: TimeInterval = 0
    private var timeInDownPosition: TimeInterval = 0
    private var lastStateChange: Date = Date()
    private let minimumHoldTime: TimeInterval = 0.5
    private let minimumTransitionTime: TimeInterval = 0.3
    private var sessionFeedback: [SessionFeedback] = []
    
    func analyzeMovement(poses: [VNHumanBodyPoseObservation], for exercise: Exercise) -> AnalysisResult {
        guard let pose = poses.first else {
            return AnalysisResult(repCount: repCount, feedback: "No person detected", feedbackType: .poor)
        }
        
        previousPoses.append(pose)
        if previousPoses.count > 10 {
            previousPoses.removeFirst()
        }
        
        switch exercise.id {
        case "shoulder_raise":
            return analyzeShoulderRaise(pose: pose)
        case "squats":
            return analyzeSquats(pose: pose)
        default:
            return AnalysisResult(repCount: repCount, feedback: "Exercise not implemented", feedbackType: .needsImprovement)
        }
    }
    
    private func analyzeShoulderRaise(pose: VNHumanBodyPoseObservation) -> AnalysisResult {
        do {
            let leftShoulder = try pose.recognizedPoint(.leftShoulder)
            let rightShoulder = try pose.recognizedPoint(.rightShoulder)
            let leftElbow = try pose.recognizedPoint(.leftElbow)
            let rightElbow = try pose.recognizedPoint(.rightElbow)
            let leftWrist = try pose.recognizedPoint(.leftWrist)
            let rightWrist = try pose.recognizedPoint(.rightWrist)
            
            guard leftShoulder.confidence > 0.3 && rightShoulder.confidence > 0.3 &&
                  leftElbow.confidence > 0.3 && rightElbow.confidence > 0.3 else {
                return AnalysisResult(repCount: repCount, feedback: "Position yourself fully in view", feedbackType: .needsImprovement)
            }
            
            let leftArmRaised = leftElbow.location.y < leftShoulder.location.y - 0.08
            let rightArmRaised = rightElbow.location.y < rightShoulder.location.y - 0.08
            let armsRaised = leftArmRaised && rightArmRaised

            let leftArmHeight = leftShoulder.location.y - leftElbow.location.y
            let rightArmHeight = rightShoulder.location.y - rightElbow.location.y
            let averageArmHeight = (leftArmHeight + rightArmHeight) / 2
            let armsHighEnough = averageArmHeight > 0.1

            let armHeightDifference = abs(leftArmHeight - rightArmHeight)
            let armsSymmetrical = armHeightDifference < 0.15

            let currentArmsRaised = armsRaised && armsHighEnough && armsSymmetrical
            let currentTime = Date()
            let timeSinceLastChange = currentTime.timeIntervalSince(lastStateChange)

            if currentArmsRaised && !isInUpPosition {
                if timeSinceLastChange > minimumTransitionTime {
                    timeInUpPosition += 0.1
                    if timeInUpPosition >= minimumHoldTime {
                        isInUpPosition = true
                        repCount += 1
                        lastStateChange = currentTime
                        timeInDownPosition = 0
                        
                        // Record feedback for this rep
                        let feedback = SessionFeedback(
                            timestamp: currentTime,
                            message: "Rep completed",
                            type: .excellent,
                            formScore: calculateFormScore(armsSymmetrical: armsSymmetrical, armsHighEnough: armsHighEnough),
                            jointAccuracy: [
                                "leftShoulder": Double(leftShoulder.confidence),
                                "rightShoulder": Double(rightShoulder.confidence)
                            ]
                        )
                        sessionFeedback.append(feedback)
                    }
                }
            } else if !currentArmsRaised && isInUpPosition {
                if timeSinceLastChange > minimumTransitionTime {
                    timeInDownPosition += 0.1
                    if timeInDownPosition >= minimumHoldTime {
                        isInUpPosition = false
                        lastStateChange = currentTime
                        timeInUpPosition = 0
                    }
                }
            } else if !currentArmsRaised && !isInUpPosition {
                timeInUpPosition = 0
            } else if currentArmsRaised && isInUpPosition {
                timeInDownPosition = 0
            }

            var feedback = "Keep going!"
            var feedbackType = FeedbackType.good

            if currentArmsRaised {
                if !armsSymmetrical {
                    feedback = "Keep arms level"
                    feedbackType = .needsImprovement
                } else if !armsHighEnough {
                    feedback = "Raise arms higher"
                    feedbackType = .needsImprovement
                } else {
                    feedback = "Great form! Hold it"
                    feedbackType = .excellent
                }
            } else {
                if isInUpPosition {
                    feedback = "Lower your arms to complete rep"
                    feedbackType = .good
                } else {
                    feedback = "Raise your arms"
                    feedbackType = .needsImprovement
                }
            }
            
            return AnalysisResult(repCount: repCount, feedback: feedback, feedbackType: feedbackType)
            
        } catch {
            return AnalysisResult(repCount: repCount, feedback: "Analysis error", feedbackType: .poor)
        }
    }
    
    private func analyzeSquats(pose: VNHumanBodyPoseObservation) -> AnalysisResult {
        // Placeholder for squat analysis - implement similar logic
        return AnalysisResult(repCount: repCount, feedback: "Squat analysis coming soon", feedbackType: .needsImprovement)
    }
    
    private func calculateFormScore(armsSymmetrical: Bool, armsHighEnough: Bool) -> Double {
        var score = 0.0
        if armsSymmetrical { score += 0.5 }
        if armsHighEnough { score += 0.5 }
        return score
    }
    
    func getSessionSummary() -> [SessionFeedback] {
        return sessionFeedback
    }
    
    func resetSession() {
        repCount = 0
        isInUpPosition = false
        timeInUpPosition = 0
        timeInDownPosition = 0
        lastStateChange = Date()
        previousPoses.removeAll()
        sessionFeedback.removeAll()
    }
}
