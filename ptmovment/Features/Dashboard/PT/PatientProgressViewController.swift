import UIKit

// MARK: - Patient Progress View Controller
class PatientProgressViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerView = ProgressHeaderView()
    private let chartContainerView = UIView()
    private let metricsStackView = UIStackView()
    private let sessionHistoryView = SessionHistoryView()
    private let complianceView = ComplianceOverviewView()
    
    // MARK: - Properties
    private let patient: User
    private let progressService = ProgressAnalyticsService.shared
    private var progressData: PatientProgressData?
    
    init(patient: User) {
        self.patient = patient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadProgressData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "\(patient.fullName) - Progress"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareProgress)
        )
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup components
        setupProgressHeader()
        setupChartContainer()
        setupMetricsStack()
        setupSessionHistory()
        setupComplianceView()
    }
    
    private func setupProgressHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .systemBackground
        headerView.layer.cornerRadius = 12
        headerView.layer.shadowColor = UIColor.label.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerView.layer.shadowOpacity = 0.1
        headerView.layer.shadowRadius = 4
        contentView.addSubview(headerView)
    }
    
    private func setupChartContainer() {
        chartContainerView.translatesAutoresizingMaskIntoConstraints = false
        chartContainerView.backgroundColor = .systemBackground
        chartContainerView.layer.cornerRadius = 12
        chartContainerView.layer.shadowColor = UIColor.label.cgColor
        chartContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        chartContainerView.layer.shadowOpacity = 0.1
        chartContainerView.layer.shadowRadius = 4
        contentView.addSubview(chartContainerView)
        
        let chartTitleLabel = UILabel()
        chartTitleLabel.text = "Progress Over Time"
        chartTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        chartTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        chartContainerView.addSubview(chartTitleLabel)
        
        let progressChartView = ProgressChartView()
        progressChartView.translatesAutoresizingMaskIntoConstraints = false
        chartContainerView.addSubview(progressChartView)
        
        NSLayoutConstraint.activate([
            chartTitleLabel.topAnchor.constraint(equalTo: chartContainerView.topAnchor, constant: 20),
            chartTitleLabel.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor, constant: 20),
            chartTitleLabel.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor, constant: -20),
            
            progressChartView.topAnchor.constraint(equalTo: chartTitleLabel.bottomAnchor, constant: 20),
            progressChartView.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor, constant: 20),
            progressChartView.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor, constant: -20),
            progressChartView.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor, constant: -20),
            progressChartView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupMetricsStack() {
        metricsStackView.translatesAutoresizingMaskIntoConstraints = false
        metricsStackView.axis = .horizontal
        metricsStackView.distribution = .fillEqually
        metricsStackView.spacing = 16 // Better spacing between cards
        contentView.addSubview(metricsStackView)
        
        let repMetric = createMetricCard(title: "Total Reps", value: "1,247", subtitle: "Last 30 days", color: .systemBlue)
        let formMetric = createMetricCard(title: "Form Score", value: "87%", subtitle: "Average", color: .systemGreen)
        let streakMetric = createMetricCard(title: "Streak", value: "12 days", subtitle: "Current", color: .systemOrange)
        
        metricsStackView.addArrangedSubview(repMetric)
        metricsStackView.addArrangedSubview(formMetric)
        metricsStackView.addArrangedSubview(streakMetric)
    }
    
    private func setupSessionHistory() {
        sessionHistoryView.translatesAutoresizingMaskIntoConstraints = false
        sessionHistoryView.backgroundColor = .systemBackground
        sessionHistoryView.layer.cornerRadius = 12
        sessionHistoryView.layer.shadowColor = UIColor.label.cgColor
        sessionHistoryView.layer.shadowOffset = CGSize(width: 0, height: 2)
        sessionHistoryView.layer.shadowOpacity = 0.1
        sessionHistoryView.layer.shadowRadius = 4
        contentView.addSubview(sessionHistoryView)
    }
    
    private func setupComplianceView() {
        complianceView.translatesAutoresizingMaskIntoConstraints = false
        complianceView.backgroundColor = .systemBackground
        complianceView.layer.cornerRadius = 12
        complianceView.layer.shadowColor = UIColor.label.cgColor
        complianceView.layer.shadowOffset = CGSize(width: 0, height: 2)
        complianceView.layer.shadowOpacity = 0.1
        complianceView.layer.shadowRadius = 4
        contentView.addSubview(complianceView)
    }
    
    private func createMetricCard(title: String, value: String, subtitle: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.label.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.1
        card.layer.shadowRadius = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 28, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        card.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            subtitleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        return card
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header with better spacing
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 140),
            
            // Chart with proper spacing
            chartContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            chartContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartContainerView.heightAnchor.constraint(equalToConstant: 280),
            
            // Metrics with better spacing
            metricsStackView.topAnchor.constraint(equalTo: chartContainerView.bottomAnchor, constant: 24),
            metricsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            metricsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            metricsStackView.heightAnchor.constraint(equalToConstant: 120),
            
            // Session history with proper spacing
            sessionHistoryView.topAnchor.constraint(equalTo: metricsStackView.bottomAnchor, constant: 24),
            sessionHistoryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sessionHistoryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sessionHistoryView.heightAnchor.constraint(equalToConstant: 350),
            
            // Compliance with proper spacing
            complianceView.topAnchor.constraint(equalTo: sessionHistoryView.bottomAnchor, constant: 24),
            complianceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            complianceView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            complianceView.heightAnchor.constraint(equalToConstant: 180),
            complianceView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func loadProgressData() {
        progressService.getPatientProgress(patientId: patient.id) { [weak self] progressData in
            DispatchQueue.main.async {
                self?.progressData = progressData
                self?.updateUI(with: progressData)
            }
        }
    }
    
    private func updateUI(with data: PatientProgressData) {
        headerView.configure(with: data)
        sessionHistoryView.configure(sessions: data.recentSessions)
        complianceView.configure(with: data.complianceData)
    }
    
    @objc private func shareProgress() {
        // Generate progress report and share
        let progressReport = generateProgressReport()
        let activityVC = UIActivityViewController(activityItems: [progressReport], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func generateProgressReport() -> String {
        guard let data = progressData else { return "No progress data available" }
        
        return """
        Progress Report - \(patient.fullName)
        Generated: \(Date().formatted())
        
        📊 Summary:
        • Total Sessions: \(data.totalSessions)
        • Average Form Score: \(data.averageFormScore)%
        • Completion Rate: \(data.completionRate)%
        • Current Streak: \(data.currentStreak) days
        
        🎯 Recent Performance:
        \(data.recentSessions.prefix(5).map { "• \($0.exerciseName): \($0.completedReps) reps (\($0.formScore)% form)" }.joined(separator: "\n"))
        
        📈 Trends:
        • Form improvement: +\(data.formImprovement)% this month
        • Consistency: \(data.complianceData.weeklyCompletionRate)% weekly completion
        """
    }
}

// MARK: - Progress Data Models

struct PatientProgressData {
    let patientId: String
    let totalSessions: Int
    let averageFormScore: Double
    let completionRate: Double
    let currentStreak: Int
    let formImprovement: Double
    let recentSessions: [SessionSummary]
    let complianceData: ComplianceData
    let progressChart: [ProgressPoint]
}

struct SessionSummary {
    let id: String
    let date: Date
    let exerciseName: String
    let completedReps: Int
    let targetReps: Int
    let formScore: Double
    let duration: TimeInterval
    let notes: String?
}


struct ProgressPoint {
    let date: Date
    let formScore: Double
    let repsCompleted: Int
    let exerciseType: String
}

// MARK: - Progress Analytics Service

class ProgressAnalyticsService {
    static let shared = ProgressAnalyticsService()
    
    private init() {}
    
    func getPatientProgress(patientId: String, completion: @escaping (PatientProgressData) -> Void) {
        // Simulate API call with mock data
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let mockData = self.generateMockProgressData(for: patientId)
            completion(mockData)
        }
    }
    
    private func generateMockProgressData(for patientId: String) -> PatientProgressData {
        let recentSessions = [
            SessionSummary(id: "1", date: Date().addingTimeInterval(-86400), exerciseName: "Shoulder Raises", completedReps: 12, targetReps: 10, formScore: 92.0, duration: 120, notes: "Great improvement"),
            SessionSummary(id: "2", date: Date().addingTimeInterval(-172800), exerciseName: "Squats", completedReps: 8, targetReps: 10, formScore: 78.0, duration: 180, notes: "Keep knees aligned"),
            SessionSummary(id: "3", date: Date().addingTimeInterval(-259200), exerciseName: "Shoulder Raises", completedReps: 10, targetReps: 10, formScore: 85.0, duration: 115, notes: nil),
            SessionSummary(id: "4", date: Date().addingTimeInterval(-345600), exerciseName: "Balance Stand", completedReps: 1, targetReps: 1, formScore: 94.0, duration: 60, notes: "Excellent balance"),
            SessionSummary(id: "5", date: Date().addingTimeInterval(-432000), exerciseName: "Squats", completedReps: 9, targetReps: 10, formScore: 72.0, duration: 165, notes: "Focus on depth")
        ]
        
        let complianceData = ComplianceData(
            weeklyCompletionRate: 85.7,
            monthlyCompletionRate: 78.3,
            missedSessions: 3,
            consistencyScore: 82.0,
            lastActiveDate: Date().addingTimeInterval(-86400)
        )
        
        let progressChart = generateMockChartData()
        
        return PatientProgressData(
            patientId: patientId,
            totalSessions: 47,
            averageFormScore: 84.2,
            completionRate: 89.4,
            currentStreak: 12,
            formImprovement: 15.3,
            recentSessions: recentSessions,
            complianceData: complianceData,
            progressChart: progressChart
        )
    }
    
    private func generateMockChartData() -> [ProgressPoint] {
        var points: [ProgressPoint] = []
        let calendar = Calendar.current
        
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let formScore = 70.0 + Double.random(in: -10...20) + Double(i) * 0.5 // Gradual improvement
            let reps = Int.random(in: 8...15)
            let exercises = ["Shoulder Raises", "Squats", "Balance Stand"]
            let exercise = exercises.randomElement() ?? "Shoulder Raises"
            
            points.append(ProgressPoint(date: date, formScore: formScore, repsCompleted: reps, exerciseType: exercise))
        }
        
        return points.reversed()
    }
}

// MARK: - Progress Components

class ProgressHeaderView: UIView {
    private let nameLabel = UILabel()
    private let summaryLabel = UILabel()
    private let progressRing = ProgressRingView()
    private let achievementBadge = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        addSubview(nameLabel)
        
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = .systemFont(ofSize: 16)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 2
        addSubview(summaryLabel)
        
        progressRing.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressRing)
        
        achievementBadge.translatesAutoresizingMaskIntoConstraints = false
        achievementBadge.image = UIImage(systemName: "star.circle.fill")
        achievementBadge.tintColor = .systemYellow
        addSubview(achievementBadge)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: progressRing.leadingAnchor, constant: -20),
            
            summaryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            summaryLabel.trailingAnchor.constraint(equalTo: progressRing.leadingAnchor, constant: -20),
            
            achievementBadge.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 12),
            achievementBadge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            achievementBadge.widthAnchor.constraint(equalToConstant: 24),
            achievementBadge.heightAnchor.constraint(equalToConstant: 24),
            
            progressRing.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            progressRing.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressRing.widthAnchor.constraint(equalToConstant: 80),
            progressRing.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func configure(with data: PatientProgressData) {
        nameLabel.text = "Progress Overview"
        summaryLabel.text = "\(data.totalSessions) sessions completed\n\(Int(data.averageFormScore))% average form score"
        progressRing.setProgress(data.completionRate / 100.0, animated: true)
    }
}

class ProgressChartView: UIView {
    // Simplified chart implementation - in production you'd use a proper charting library
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw background grid
        context.setStrokeColor(UIColor.systemGray5.cgColor)
        context.setLineWidth(1)
        
        // Horizontal grid lines
        for i in 0...5 {
            let y = rect.height * CGFloat(i) / 5
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            context.strokePath()
        }
        
        // Draw sample progress line
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(3)
        
        let points = [
            CGPoint(x: 0, y: rect.height * 0.8),
            CGPoint(x: rect.width * 0.2, y: rect.height * 0.7),
            CGPoint(x: rect.width * 0.4, y: rect.height * 0.5),
            CGPoint(x: rect.width * 0.6, y: rect.height * 0.4),
            CGPoint(x: rect.width * 0.8, y: rect.height * 0.3),
            CGPoint(x: rect.width, y: rect.height * 0.2)
        ]
        
        context.move(to: points[0])
        for point in points.dropFirst() {
            context.addLine(to: point)
        }
        context.strokePath()
        
        // Draw data points
        context.setFillColor(UIColor.systemBlue.cgColor)
        for point in points {
            context.fillEllipse(in: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8))
        }
    }
}

class ProgressRingView: UIView {
    private var progress: Double = 0.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 10
        
        // Background circle
        let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        UIColor.systemGray5.setStroke()
        backgroundPath.lineWidth = 8
        backgroundPath.stroke()
        
        // Progress arc
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: -.pi / 2 + .pi * 2 * progress, clockwise: true)
        UIColor.systemGreen.setStroke()
        progressPath.lineWidth = 8
        progressPath.stroke()
        
        // Progress text
        let text = "\(Int(progress * 100))%"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(x: center.x - textSize.width / 2, y: center.y - textSize.height / 2, width: textSize.width, height: textSize.height)
        text.draw(in: textRect, withAttributes: attributes)
    }
    
    func setProgress(_ progress: Double, animated: Bool) {
        self.progress = max(0, min(1, progress))
        if animated {
            UIView.animate(withDuration: 1.0) {
                self.setNeedsDisplay()
            }
        } else {
            setNeedsDisplay()
        }
    }
}

class SessionHistoryView: UIView {
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private var sessions: [SessionSummary] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Recent Sessions"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        addSubview(titleLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SessionHistoryCell.self, forCellReuseIdentifier: "SessionHistoryCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func configure(sessions: [SessionSummary]) {
        self.sessions = sessions
        tableView.reloadData()
    }
}

extension SessionHistoryView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionHistoryCell", for: indexPath) as! SessionHistoryCell
        cell.configure(with: sessions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

class SessionHistoryCell: UITableViewCell {
    private let exerciseLabel = UILabel()
    private let dateLabel = UILabel()
    private let repsLabel = UILabel()
    private let formScoreLabel = UILabel()
    private let formProgressView = UIProgressView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 12
        selectionStyle = .none
        
        exerciseLabel.translatesAutoresizingMaskIntoConstraints = false
        exerciseLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        contentView.addSubview(exerciseLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        contentView.addSubview(dateLabel)
        
        repsLabel.translatesAutoresizingMaskIntoConstraints = false
        repsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        repsLabel.textAlignment = .right
        contentView.addSubview(repsLabel)
        
        formScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        formScoreLabel.font = .systemFont(ofSize: 12)
        formScoreLabel.textColor = .secondaryLabel
        formScoreLabel.textAlignment = .right
        contentView.addSubview(formScoreLabel)
        
        formProgressView.translatesAutoresizingMaskIntoConstraints = false
        formProgressView.progressTintColor = .systemGreen
        contentView.addSubview(formProgressView)
        
        NSLayoutConstraint.activate([
            exerciseLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            exerciseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            exerciseLabel.trailingAnchor.constraint(equalTo: repsLabel.leadingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            formProgressView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            formProgressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            formProgressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100),
            formProgressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            repsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            repsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            repsLabel.widthAnchor.constraint(equalToConstant: 80),
            
            formScoreLabel.topAnchor.constraint(equalTo: repsLabel.bottomAnchor, constant: 4),
            formScoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            formScoreLabel.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func configure(with session: SessionSummary) {
        exerciseLabel.text = session.exerciseName
        dateLabel.text = session.date.formatted(date: .abbreviated, time: .omitted)
        repsLabel.text = "\(session.completedReps)/\(session.targetReps)"
        formScoreLabel.text = "\(Int(session.formScore))% form"
        formProgressView.progress = Float(session.formScore / 100.0)
        
        // Color code based on performance
        if session.formScore >= 90 {
            formProgressView.progressTintColor = .systemGreen
        } else if session.formScore >= 75 {
            formProgressView.progressTintColor = .systemOrange
        } else {
            formProgressView.progressTintColor = .systemRed
        }
    }
}

class ComplianceOverviewView: UIView {
    private let titleLabel = UILabel()
    private let weeklyLabel = UILabel()
    private let monthlyLabel = UILabel()
    private let streakLabel = UILabel()
    private let weeklyProgressView = UIProgressView()
    private let monthlyProgressView = UIProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Compliance Overview"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        addSubview(titleLabel)
        
        weeklyLabel.translatesAutoresizingMaskIntoConstraints = false
        weeklyLabel.text = "This Week"
        weeklyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(weeklyLabel)
        
        weeklyProgressView.translatesAutoresizingMaskIntoConstraints = false
        weeklyProgressView.progressTintColor = .systemBlue
        addSubview(weeklyProgressView)
        
        monthlyLabel.translatesAutoresizingMaskIntoConstraints = false
        monthlyLabel.text = "This Month"
        monthlyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(monthlyLabel)
        
        monthlyProgressView.translatesAutoresizingMaskIntoConstraints = false
        monthlyProgressView.progressTintColor = .systemPurple
        addSubview(monthlyProgressView)
        
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.font = .systemFont(ofSize: 14)
        streakLabel.textColor = .secondaryLabel
        addSubview(streakLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            weeklyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            weeklyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            weeklyProgressView.topAnchor.constraint(equalTo: weeklyLabel.bottomAnchor, constant: 8),
            weeklyProgressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            weeklyProgressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            monthlyLabel.topAnchor.constraint(equalTo: weeklyProgressView.bottomAnchor, constant: 16),
            monthlyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            monthlyProgressView.topAnchor.constraint(equalTo: monthlyLabel.bottomAnchor, constant: 8),
            monthlyProgressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            monthlyProgressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            streakLabel.topAnchor.constraint(equalTo: monthlyProgressView.bottomAnchor, constant: 12),
            streakLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            streakLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            streakLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with data: ComplianceData) {
        weeklyLabel.text = "This Week: \(Int(data.weeklyCompletionRate))%"
        monthlyLabel.text = "This Month: \(Int(data.monthlyCompletionRate))%"
        streakLabel.text = "Last active: \(data.lastActiveDate.formatted(date: .abbreviated, time: .omitted))"
        
        weeklyProgressView.progress = Float(data.weeklyCompletionRate / 100.0)
        monthlyProgressView.progress = Float(data.monthlyCompletionRate / 100.0)
    }
}
