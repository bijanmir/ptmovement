import Foundation
import Vision
import AVFoundation

// MARK: - Vision Service

class VisionService {
    private var poseRequest: VNDetectHumanBodyPoseRequest
    
    init() {
        poseRequest = VNDetectHumanBodyPoseRequest()
        poseRequest.revision = VNDetectHumanBodyPoseRequestRevision1
    }
    
    func detectPose(in pixelBuffer: CVPixelBuffer, completion: @escaping ([VNHumanBodyPoseObservation]) -> Void) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        
        do {
            try handler.perform([poseRequest])
            let observations = poseRequest.results ?? []
            DispatchQueue.main.async {
                completion(observations)
            }
        } catch {
            print("Failed to perform pose detection: \(error)")
            DispatchQueue.main.async {
                completion([])
            }
        }
    }
}
