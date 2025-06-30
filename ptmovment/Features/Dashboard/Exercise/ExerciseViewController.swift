import UIKit
import AVFoundation
import Vision

// MARK: - Exercise View Controller (Camera Interface)

class ExerciseViewController: UIViewController {
    // Camera components
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoOutput: AVCaptureVideoDataOutput!
    
    // Analysis components
    private let visionService = VisionService()
    private var movementAnalyzer: EnhancedMovementAnalyzer
    private var currentExercise: Exercise = Exercise.shoulderRaise
    private var currentSession: MovementSession?
    private var currentAssignment: ExerciseAssignment?
    
    // UI Components
    private let overlayView = UIView()
    private let feedbackLabel = UILabel()
    private let repCountLabel = UILabel()
    private let startButton = UIButton(type: .system)
    private let exerciseTitleLabel = UILabel()
    private let progressLabel = UILabel()
    
    // Initialization
    init(exercise: Exercise, assignment: ExerciseAssignment? = nil) {
        self.movementAnalyzer = EnhancedMovementAnalyzer(exercise: exercise)
        super.init(nibName: nil, bundle: nil)
        self.currentExercise = exercise
        self.currentAssignment = assignment
    }

    required init?(coder: NSCoder) {
        self.movementAnalyzer = EnhancedMovementAnalyzer(exercise: Exercise.shoulderRaise)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
        setupExerciseInfo()
    }
    
    private func setupExerciseInfo() {
        exerciseTitleLabel.text = currentExercise.name
        if let assignment = currentAssignment {
            progressLabel.text = "Target: \(assignment.prescribedReps) reps"
        } else {
            progressLabel.text = "Target: \(currentExercise.defaultReps) reps"
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Setup overlay view
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .clear
        view.addSubview(overlayView)
        
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
        
        // Setup rep count label
        repCountLabel.translatesAutoresizingMaskIntoConstraints = false
        repCountLabel.text = "Reps: 0"
        repCountLabel.textColor = .white
        repCountLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        repCountLabel.textAlignment = .center
        repCountLabel.layer.cornerRadius = 25
        repCountLabel.clipsToBounds = true
        repCountLabel.font = .systemFont(ofSize: 24, weight: .bold)
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
            overlayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            exerciseTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            exerciseTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exerciseTitleLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            exerciseTitleLabel.heightAnchor.constraint(equalToConstant: 44),
            
            progressLabel.topAnchor.constraint(equalTo: exerciseTitleLabel.bottomAnchor, constant: 8),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.6),
            progressLabel.heightAnchor.constraint(equalToConstant: 32),
            
            feedbackLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 20),
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            feedbackLabel.heightAnchor.constraint(equalToConstant: 44),
            
            repCountLabel.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 20),
            repCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            repCountLabel.widthAnchor.constraint(equalToConstant: 100),
            repCountLabel.heightAnchor.constraint(equalToConstant: 50),
            
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
    
    private func startExercise() {
        currentSession = MovementSession(
            id: UUID(),
            exercise: currentExercise,
            startTime: Date()
        )
        movementAnalyzer.resetSession()
        startButton.setTitle("Stop Exercise", for: .normal)
        startButton.backgroundColor = .systemRed
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
    }
    
    private func showExerciseCompletion(session: MovementSession) {
        let alert = UIAlertController(
            title: "Exercise Complete!",
            message: "You completed \(session.repetitions) reps in \(Int(session.duration)) seconds. Great work!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            // Could navigate back or to next exercise
        })
        
        alert.addAction(UIAlertAction(title: "View Progress", style: .default) { _ in
            // Navigate to progress view
        })
        
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
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
        // Update UI
        feedbackLabel.text = result.feedback
        feedbackLabel.backgroundColor = result.feedbackType.color.withAlphaComponent(0.8)
        repCountLabel.text = "Reps: \(result.repCount)"
        
        // Update progress based on target
        if let assignment = currentAssignment {
            let progress = min(Double(result.repCount) / Double(assignment.prescribedReps), 1.0)
            progressLabel.text = "Progress: \(result.repCount)/\(assignment.prescribedReps) (\(Int(progress * 100))%)"
        } else {
            let progress = min(Double(result.repCount) / Double(currentExercise.defaultReps), 1.0)
            progressLabel.text = "Progress: \(result.repCount)/\(currentExercise.defaultReps) (\(Int(progress * 100))%)"
        }
        
        // Draw skeleton overlay
        drawSkeletonOverlay(observations: observations)
    }
    
    private func drawSkeletonOverlay(observations: [VNHumanBodyPoseObservation]) {
        // Clear previous drawings
        overlayView.layer.sublayers?.removeAll()
        
        guard let observation = observations.first else { return }
        
        // Draw pose points
        let layer = CALayer()
        overlayView.layer.addSublayer(layer)
        
        do {
            let recognizedPoints = try observation.recognizedPoints(.all)
            
            for (key, point) in recognizedPoints {
                guard point.confidence > 0.3 else { continue }
                
                let convertedPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: point.location)
                
                let pointLayer = CAShapeLayer()
                pointLayer.path = UIBezierPath(ovalIn: CGRect(x: convertedPoint.x - 4, y: convertedPoint.y - 4, width: 8, height: 8)).cgPath
                pointLayer.fillColor = UIColor.systemGreen.cgColor
                layer.addSublayer(pointLayer)
            }
        } catch {
            print("Error drawing pose points: \(error)")
        }
    }
}
