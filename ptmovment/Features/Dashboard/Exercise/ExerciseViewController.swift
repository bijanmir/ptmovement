import UIKit
import AVFoundation
import Vision

// MARK: - Enhanced Exercise View Controller
class ExerciseViewController: UIViewController {
    // Camera components
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoOutput: AVCaptureVideoDataOutput!
    
    // Analysis components
    private let visionService = VisionService()
    private var movementAnalyzer: EnhancedMovementAnalyzer
    private var currentExercise: Exercise
    private var currentSession: MovementSession?
    private var currentAssignment: ExerciseAssignment?
    
    // UI Components
    private let overlayView = UIView()
    private let skeletonView = SkeletonOverlayView()
    private let feedbackLabel = UILabel()
    private let repCountLabel = UILabel()
    private let formScoreView = FormScoreView()
    private let startButton = UIButton(type: .system)
    private let exerciseTitleLabel = UILabel()
    private let progressLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let guidanceView = ExerciseGuidanceView()
    
    // Visual Feedback Components
    private let angleDisplayView = AngleDisplayView()
    private let progressRing = CircularProgressView()
    
    // MARK: - Initialization
    init(exercise: Exercise, assignment: ExerciseAssignment? = nil) {
        self.currentExercise = exercise
        self.movementAnalyzer = EnhancedMovementAnalyzer(exercise: exercise)
        super.init(nibName: nil, bundle: nil)
        self.currentAssignment = assignment
    }

    required init?(coder: NSCoder) {
        self.currentExercise = Exercise.shoulderRaise
        self.movementAnalyzer = EnhancedMovementAnalyzer(exercise: Exercise.shoulderRaise)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkCameraPermissions()
        setupExerciseInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
    
    // MARK: - Camera Permissions
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.showCameraPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "PT Movement needs camera access to analyze your exercises. Please enable camera access in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func setupExerciseInfo() {
        exerciseTitleLabel.text = currentExercise.name
        if let assignment = currentAssignment {
            progressLabel.text = "Target: \(assignment.prescribedReps) reps"
            progressRing.setProgress(0, total: Double(assignment.prescribedReps))
        } else {
            progressLabel.text = "Target: \(currentExercise.defaultReps) reps"
            progressRing.setProgress(0, total: Double(currentExercise.defaultReps))
        }
        
        // Setup guidance for specific exercise
        guidanceView.configure(for: currentExercise)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Setup close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // Setup overlay view
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .clear
        view.addSubview(overlayView)
        
        // Setup skeleton view
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        skeletonView.backgroundColor = .clear
        overlayView.addSubview(skeletonView)
        
        // Setup guidance view
        guidanceView.translatesAutoresizingMaskIntoConstraints = false
        guidanceView.alpha = 0.7
        overlayView.addSubview(guidanceView)
        
        // Setup angle display
        angleDisplayView.translatesAutoresizingMaskIntoConstraints = false
        angleDisplayView.isHidden = true
        overlayView.addSubview(angleDisplayView)
        
        // Setup exercise title label
        exerciseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        exerciseTitleLabel.text = "Exercise"
        exerciseTitleLabel.textColor = .white
        exerciseTitleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        exerciseTitleLabel.textAlignment = .center
        exerciseTitleLabel.layer.cornerRadius = 8
        exerciseTitleLabel.clipsToBounds = true
        exerciseTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        view.addSubview(exerciseTitleLabel)
        
        // Setup progress label
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.text = "Target: 10 reps"
        progressLabel.textColor = .white
        progressLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.7)
        progressLabel.textAlignment = .center
        progressLabel.layer.cornerRadius = 8
        progressLabel.clipsToBounds = true
        progressLabel.font = .systemFont(ofSize: 16, weight: .medium)
        view.addSubview(progressLabel)
        
        // Setup form score view
        formScoreView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(formScoreView)
        
        // Setup feedback label
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackLabel.text = "Position yourself in view"
        feedbackLabel.textColor = .white
        feedbackLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        feedbackLabel.textAlignment = .center
        feedbackLabel.layer.cornerRadius = 8
        feedbackLabel.clipsToBounds = true
        feedbackLabel.font = .systemFont(ofSize: 18, weight: .medium)
        view.addSubview(feedbackLabel)
        
        // Setup progress ring
        progressRing.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressRing)
        
        // Setup rep count label
        repCountLabel.translatesAutoresizingMaskIntoConstraints = false
        repCountLabel.text = "0"
        repCountLabel.textColor = .white
        repCountLabel.textAlignment = .center
        repCountLabel.font = .systemFont(ofSize: 48, weight: .bold)
        view.addSubview(repCountLabel)
        
        // Setup start button
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start Exercise", for: .normal)
        startButton.backgroundColor = .systemGreen
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 25
        startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Overlay and skeleton view
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            skeletonView.topAnchor.constraint(equalTo: overlayView.topAnchor),
            skeletonView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            skeletonView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            skeletonView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),
            
            guidanceView.topAnchor.constraint(equalTo: overlayView.topAnchor),
            guidanceView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            guidanceView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            guidanceView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),
            
            angleDisplayView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            angleDisplayView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            angleDisplayView.widthAnchor.constraint(equalToConstant: 200),
            angleDisplayView.heightAnchor.constraint(equalToConstant: 100),
            
            // Exercise title
            exerciseTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            exerciseTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exerciseTitleLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            exerciseTitleLabel.heightAnchor.constraint(equalToConstant: 44),
            
            // Progress label
            progressLabel.topAnchor.constraint(equalTo: exerciseTitleLabel.bottomAnchor, constant: 8),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.6),
            progressLabel.heightAnchor.constraint(equalToConstant: 32),
            
            // Form score view
            formScoreView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 20),
            formScoreView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            formScoreView.widthAnchor.constraint(equalToConstant: 100),
            formScoreView.heightAnchor.constraint(equalToConstant: 100),
            
            // Feedback label
            feedbackLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 20),
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            feedbackLabel.heightAnchor.constraint(equalToConstant: 44),
            
            // Progress ring and rep count
            progressRing.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressRing.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 20),
            progressRing.widthAnchor.constraint(equalToConstant: 120),
            progressRing.heightAnchor.constraint(equalToConstant: 120),
            
            repCountLabel.centerXAnchor.constraint(equalTo: progressRing.centerXAnchor),
            repCountLabel.centerYAnchor.constraint(equalTo: progressRing.centerYAnchor),
            
            // Start button
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("Could not create camera input")
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        // Setup video output
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Setup preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    @objc private func startButtonTapped() {
        if currentSession == nil {
            startExercise()
        } else {
            stopExercise()
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    private func startExercise() {
        currentSession = MovementSession(
            id: UUID(),
            exercise: currentExercise,
            startTime: Date()
        )
        movementAnalyzer.resetSession()
        startButton.setTitle("Stop Exercise", for: .normal)
        startButton.backgroundColor = .systemRed
        
        // Show guidance overlay briefly
        UIView.animate(withDuration: 0.3) {
            self.guidanceView.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0) {
                self.guidanceView.alpha = 0.3
            }
        }
        
        // Show angle display for relevant exercises
        if ["squats", "shoulder_raise"].contains(currentExercise.id) {
            angleDisplayView.isHidden = false
        }
    }
    
    private func stopExercise() {
        currentSession?.endTime = Date()
        
        // Show completion summary
        if let session = currentSession {
            showExerciseCompletion(session: session)
        }
        
        currentSession = nil
        startButton.setTitle("Start Exercise", for: .normal)
        startButton.backgroundColor = .systemGreen
        angleDisplayView.isHidden = true
    }
    
    private func showExerciseCompletion(session: MovementSession) {
        let summary = movementAnalyzer.getSessionSummary()
        
        let completionVC = ExerciseCompletionViewController(
            session: session,
            summary: summary,
            exercise: currentExercise
        )
        completionVC.modalPresentationStyle = .pageSheet
        present(completionVC, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
}

// MARK: - Video Capture Delegate
extension ExerciseViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              currentSession != nil else { return }

        visionService.detectPose(in: pixelBuffer) { [weak self] observations in
            self?.processPoseObservations(observations)
        }
    }

    private func processPoseObservations(_ observations: [VNHumanBodyPoseObservation]) {
        let result = movementAnalyzer.analyzeMovement(poses: observations)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Update UI
            self.feedbackLabel.text = result.feedback
            self.feedbackLabel.backgroundColor = result.feedbackType.color.withAlphaComponent(0.8)
            self.repCountLabel.text = "\(result.repCount)"

            // Update progress ring
            let target = Double(self.currentAssignment?.prescribedReps ?? self.currentExercise.defaultReps)
            self.progressRing.setProgress(Double(result.repCount), total: target)

            // Update form score
            let summary = self.movementAnalyzer.getSessionSummary()
            self.formScoreView.updateScore(summary.averageFormScore)


            // Update progress label
            let progress = min(Double(result.repCount) / target, 1.0)
            self.progressLabel.text = "Progress: \(result.repCount)/\(Int(target)) (\(Int(progress * 100))%)"

            // Draw skeleton with color coding
            self.skeletonView.updateSkeleton(
                observations: observations,
                feedbackType: result.feedbackType,
                previewLayer: self.previewLayer
            )

            // Update angle display if visible
            if !self.angleDisplayView.isHidden, let observation = observations.first {
                self.updateAngleDisplay(observation: observation)
            }

            // Check for completion
            if result.repCount >= Int(target), self.currentSession != nil {
                self.handleExerciseCompletion()
            }
        }
    }

    private func updateAngleDisplay(observation: VNHumanBodyPoseObservation) {
        guard let recognizedPoints = try? observation.recognizedPoints(.all) else { return }

        switch currentExercise.id {
        case "squats":
            if let leftHip = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftHip],
               let leftKnee = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftKnee],
               let leftAnkle = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftAnkle] {

                let angle = calculateAngle(
                    point1: leftHip.location,
                    point2: leftKnee.location,
                    point3: leftAnkle.location
                )
                angleDisplayView.updateAngle(angle, label: "Knee Angle")
            }

        case "shoulder_raise":
            if let leftShoulder = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftShoulder],
               let leftElbow = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftElbow],
               let leftWrist = recognizedPoints[VNHumanBodyPoseObservation.JointName.leftWrist] {

                let shoulderToWrist = CGPoint(
                    x: leftWrist.location.x - leftShoulder.location.x,
                    y: leftWrist.location.y - leftShoulder.location.y
                )
                let angle = atan2(shoulderToWrist.y, shoulderToWrist.x) * 180 / .pi
                angleDisplayView.updateAngle(angle, label: "Arm Elevation")
            }

        default:
            break
        }
    }

    private func handleExerciseCompletion() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Visual celebration
        showCompletionAnimation()

        // Auto-stop after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.stopExercise()
        }
    }

    private func showCompletionAnimation() {
        let celebrationView = UIView()
        celebrationView.backgroundColor = .systemGreen
        celebrationView.alpha = 0
        celebrationView.frame = view.bounds
        view.addSubview(celebrationView)

        UIView.animate(withDuration: 0.3, animations: {
            celebrationView.alpha = 0.3
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.2, options: []) {
                celebrationView.alpha = 0
            } completion: { _ in
                celebrationView.removeFromSuperview()
            }
        }
    }

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
}


// MARK: - Supporting Views

class SkeletonOverlayView: UIView {
    private var skeletonLayer = CAShapeLayer()
    private var jointLayers: [CAShapeLayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        layer.addSublayer(skeletonLayer)
        skeletonLayer.fillColor = UIColor.clear.cgColor
        skeletonLayer.lineWidth = 4.0
        skeletonLayer.lineCap = .round
    }
    
    func updateSkeleton(observations: [VNHumanBodyPoseObservation], feedbackType: FeedbackType, previewLayer: AVCaptureVideoPreviewLayer?) {
        // Clear previous joints
        jointLayers.forEach { $0.removeFromSuperlayer() }
        jointLayers.removeAll()
        
        guard let observation = observations.first,
              let previewLayer = previewLayer else {
            skeletonLayer.path = nil
            return
        }
        
        let path = UIBezierPath()
        
        do {
            let recognizedPoints = try observation.recognizedPoints(.all)
            
            // Define skeleton connections
            let connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
                // Spine
                (.neck, .root),
                // Left arm
                (.neck, .leftShoulder),
                (.leftShoulder, .leftElbow),
                (.leftElbow, .leftWrist),
                // Right arm
                (.neck, .rightShoulder),
                (.rightShoulder, .rightElbow),
                (.rightElbow, .rightWrist),
                // Left leg
                (.root, .leftHip),
                (.leftHip, .leftKnee),
                (.leftKnee, .leftAnkle),
                // Right leg
                (.root, .rightHip),
                (.rightHip, .rightKnee),
                (.rightKnee, .rightAnkle)
            ]
            
            // Draw connections
            for (joint1, joint2) in connections {
                guard let point1 = recognizedPoints[joint1],
                      let point2 = recognizedPoints[joint2],
                      point1.confidence > 0.3 && point2.confidence > 0.3 else { continue }
                
                let convertedPoint1 = previewLayer.layerPointConverted(fromCaptureDevicePoint: point1.location)
                let convertedPoint2 = previewLayer.layerPointConverted(fromCaptureDevicePoint: point2.location)
                
                path.move(to: convertedPoint1)
                path.addLine(to: convertedPoint2)
            }
            
            // Draw joints
            for (_, point) in recognizedPoints {
                guard point.confidence > 0.3 else { continue }
                
                let convertedPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: point.location)
                
                let jointLayer = CAShapeLayer()
                jointLayer.path = UIBezierPath(ovalIn: CGRect(x: convertedPoint.x - 6, y: convertedPoint.y - 6, width: 12, height: 12)).cgPath
                jointLayer.fillColor = feedbackType.color.cgColor
                layer.addSublayer(jointLayer)
                jointLayers.append(jointLayer)
            }
            
            // Update skeleton color based on feedback
            skeletonLayer.strokeColor = feedbackType.color.cgColor
            skeletonLayer.path = path.cgPath
            
        } catch {
            print("Error processing pose points: \(error)")
        }
    }
}

class FormScoreView: UIView {
    private let scoreLabel = UILabel()
    private let titleLabel = UILabel()
    private let progressLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 12
        
        titleLabel.text = "Form Score"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        scoreLabel.text = "0%"
        scoreLabel.textColor = .white
        scoreLabel.font = .systemFont(ofSize: 24, weight: .bold)
        scoreLabel.textAlignment = .center
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scoreLabel)
        
        // Setup progress ring
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: 50, y: 50),
            radius: 35,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )
        
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backgroundLayer.lineWidth = 6
        layer.addSublayer(backgroundLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemGreen.cgColor
        progressLayer.lineWidth = 6
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 5)
        ])
    }
    
    func updateScore(_ score: Double) {
        scoreLabel.text = "\(Int(score))%"
        
        // Update color based on score
        let color: UIColor
        switch score {
        case 80...100:
            color = .systemGreen
        case 60..<80:
            color = .systemYellow
        case 40..<60:
            color = .systemOrange
        default:
            color = .systemRed
        }
        
        progressLayer.strokeColor = color.cgColor
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = CGFloat(score / 100)
        CATransaction.commit()
    }
}

class AngleDisplayView: UIView {
    private let angleLabel = UILabel()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 12
        
        angleLabel.textColor = .white
        angleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        angleLabel.textAlignment = .center
        angleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(angleLabel)
        
        nameLabel.textColor = .white.withAlphaComponent(0.8)
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            angleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            angleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            
            nameLabel.topAnchor.constraint(equalTo: angleLabel.bottomAnchor, constant: 4),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func updateAngle(_ angle: Double, label: String) {
        angleLabel.text = "\(Int(angle))°"
        nameLabel.text = label
    }
}

class CircularProgressView: UIView {
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        let center = CGPoint(x: 60, y: 60)
        let radius: CGFloat = 50
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )
        
        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backgroundLayer.lineWidth = 8
        layer.addSublayer(backgroundLayer)
        
        progressLayer.path = path.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemGreen.cgColor
        progressLayer.lineWidth = 8
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    func setProgress(_ current: Double, total: Double) {
        let progress = min(current / total, 1.0)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        progressLayer.strokeEnd = CGFloat(progress)
        CATransaction.commit()
        
        // Update color based on progress
        if progress >= 1.0 {
            progressLayer.strokeColor = UIColor.systemGreen.cgColor
        } else if progress >= 0.5 {
            progressLayer.strokeColor = UIColor.systemBlue.cgColor
        } else {
            progressLayer.strokeColor = UIColor.systemOrange.cgColor
        }
    }
}

class ExerciseGuidanceView: UIView {
    private let imageView = UIImageView()
    private let instructionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        instructionLabel.textColor = .white
        instructionLabel.font = .systemFont(ofSize: 18, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        instructionLabel.layer.cornerRadius = 8
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            instructionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            instructionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
    }
    
    func configure(for exercise: Exercise) {
        // Set appropriate guidance image and text
        switch exercise.id {
        case "shoulder_raise":
            imageView.image = UIImage(systemName: "figure.arms.open")
            instructionLabel.text = "Stand straight, raise arms to shoulder height"
        case "squats":
            imageView.image = UIImage(systemName: "figure.strengthtraining.functional")
            instructionLabel.text = "Keep back straight, lower hips to knee level"
        case "balance_stand":
            imageView.image = UIImage(systemName: "figure.stand")
            instructionLabel.text = "Stand on one foot, maintain balance"
        default:
            imageView.image = UIImage(systemName: "figure.wave")
            instructionLabel.text = exercise.instructions.first ?? "Follow the exercise instructions"
        }
    }
}

// MARK: - Exercise Completion View Controller
class ExerciseCompletionViewController: UIViewController {
    private let session: MovementSession
    private let summary: ExerciseSessionSummary
    private let exercise: Exercise
    
    init(session: MovementSession, summary: ExerciseSessionSummary, exercise: Exercise) {
        self.session = session
        self.summary = summary
        self.exercise = exercise
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = "Exercise Complete! 🎉"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let statsStack = UIStackView()
        statsStack.axis = .vertical
        statsStack.spacing = 20
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statsStack)
        
        // Add stats
        statsStack.addArrangedSubview(createStatView(
            title: "Reps Completed",
            value: "\(summary.totalReps)",
            icon: "checkmark.circle.fill",
            color: .systemGreen
        ))
        
        statsStack.addArrangedSubview(createStatView(
            title: "Average Form Score",
            value: "\(Int(summary.averageFormScore))%",
            icon: "star.fill",
            color: .systemYellow
        ))
        
        statsStack.addArrangedSubview(createStatView(
            title: "Duration",
            value: formatDuration(summary.duration),
            icon: "clock.fill",
            color: .systemBlue
        ))
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = .systemBlue
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 12
        doneButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            statsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createStatView(title: String, value: String, icon: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = color
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = color
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconImageView)
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        return container
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true) {
            self.presentingViewController?.dismiss(animated: true)
        }
    }
}
