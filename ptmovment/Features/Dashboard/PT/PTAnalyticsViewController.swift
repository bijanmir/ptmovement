import UIKit

// MARK: - PT Analytics Dashboard
class PTAnalyticsViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerView = AnalyticsHeaderView()
    private let metricsGridView = UIStackView()
    private let trendsChartView = TrendsChartView()
    private let patientInsightsView = PatientInsightsView()
    private let exercisePerformanceView = ExercisePerformanceView()
    private let alertsView = AlertsAndNotificationsView()
    
    // MARK: - Properties
    private let analyticsService = PTAnalyticsService.shared
    private var analyticsData: PTAnalyticsData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadAnalyticsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Analytics Dashboard"
        
        // Add filter and export buttons
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        
        let exportButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(exportTapped)
        )
        
        navigationItem.rightBarButtonItems = [exportButton, filterButton]
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup components
        setupHeader()
        setupMetricsGrid()
        setupTrendsChart()
        setupPatientInsights()
        setupExercisePerformance()
        setupAlerts()
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .systemBackground
        headerView.layer.cornerRadius = 16
        headerView.layer.shadowColor = UIColor.label.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerView.layer.shadowOpacity = 0.1
        headerView.layer.shadowRadius = 4
        contentView.addSubview(headerView)
    }
    
    private func setupMetricsGrid() {
        metricsGridView.translatesAutoresizingMaskIntoConstraints = false
        metricsGridView.axis = .vertical
        metricsGridView.spacing = 16
        contentView.addSubview(metricsGridView)
        
        // Create 2x2 grid of key metrics
        let topRow = createMetricsRow([
            ("Active Patients", "127", "+8 this week", .systemBlue),
            ("Avg Compliance", "78%", "+5% vs last month", .systemGreen)
        ])
        
        let bottomRow = createMetricsRow([
            ("Sessions Today", "34", "Peak: 2-4 PM", .systemOrange),
            ("Form Quality", "84%", "+2% improvement", .systemPurple)
        ])
        
        metricsGridView.addArrangedSubview(topRow)
        metricsGridView.addArrangedSubview(bottomRow)
    }
    
    private func setupTrendsChart() {
        trendsChartView.translatesAutoresizingMaskIntoConstraints = false
        trendsChartView.backgroundColor = .systemBackground
        trendsChartView.layer.cornerRadius = 16
        trendsChartView.layer.shadowColor = UIColor.label.cgColor
        trendsChartView.layer.shadowOffset = CGSize(width: 0, height: 2)
        trendsChartView.layer.shadowOpacity = 0.1
        trendsChartView.layer.shadowRadius = 4
        contentView.addSubview(trendsChartView)
    }
    
    private func setupPatientInsights() {
        patientInsightsView.translatesAutoresizingMaskIntoConstraints = false
        patientInsightsView.backgroundColor = .systemBackground
        patientInsightsView.layer.cornerRadius = 16
        patientInsightsView.layer.shadowColor = UIColor.label.cgColor
        patientInsightsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        patientInsightsView.layer.shadowOpacity = 0.1
        patientInsightsView.layer.shadowRadius = 4
        contentView.addSubview(patientInsightsView)
    }
    
    private func setupExercisePerformance() {
        exercisePerformanceView.translatesAutoresizingMaskIntoConstraints = false
        exercisePerformanceView.backgroundColor = .systemBackground
        exercisePerformanceView.layer.cornerRadius = 16
        exercisePerformanceView.layer.shadowColor = UIColor.label.cgColor
        exercisePerformanceView.layer.shadowOffset = CGSize(width: 0, height: 2)
        exercisePerformanceView.layer.shadowOpacity = 0.1
        exercisePerformanceView.layer.shadowRadius = 4
        contentView.addSubview(exercisePerformanceView)
    }
    
    private func setupAlerts() {
        alertsView.translatesAutoresizingMaskIntoConstraints = false
        alertsView.backgroundColor = .systemBackground
        alertsView.layer.cornerRadius = 16
        alertsView.layer.shadowColor = UIColor.label.cgColor
        alertsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        alertsView.layer.shadowOpacity = 0.1
        alertsView.layer.shadowRadius = 4
        contentView.addSubview(alertsView)
    }
    
    private func createMetricsRow(_ metrics: [(String, String, String, UIColor)]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 16
        
        for (title, value, subtitle, color) in metrics {
            let card = createMetricCard(title: title, value: value, subtitle: subtitle, color: color)
            row.addArrangedSubview(card)
        }
        
        return row
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
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 32, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        card.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            subtitleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            
            card.heightAnchor.constraint(equalToConstant: 140)
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
            
            // Header
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            // Metrics grid
            metricsGridView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            metricsGridView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            metricsGridView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Trends chart
            trendsChartView.topAnchor.constraint(equalTo: metricsGridView.bottomAnchor, constant: 24),
            trendsChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trendsChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trendsChartView.heightAnchor.constraint(equalToConstant: 300),
            
            // Patient insights
            patientInsightsView.topAnchor.constraint(equalTo: trendsChartView.bottomAnchor, constant: 24),
            patientInsightsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            patientInsightsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            patientInsightsView.heightAnchor.constraint(equalToConstant: 250),
            
            // Exercise performance
            exercisePerformanceView.topAnchor.constraint(equalTo: patientInsightsView.bottomAnchor, constant: 24),
            exercisePerformanceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            exercisePerformanceView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            exercisePerformanceView.heightAnchor.constraint(equalToConstant: 280),
            
            // Alerts
            alertsView.topAnchor.constraint(equalTo: exercisePerformanceView.bottomAnchor, constant: 24),
            alertsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            alertsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            alertsView.heightAnchor.constraint(equalToConstant: 200),
            alertsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func loadAnalyticsData() {
        analyticsService.getAnalyticsData { [weak self] data in
            DispatchQueue.main.async {
                self?.analyticsData = data
                self?.updateUI(with: data)
            }
        }
    }
    
    private func refreshData() {
        loadAnalyticsData()
    }
    
    private func updateUI(with data: PTAnalyticsData) {
        headerView.configure(with: data)
        trendsChartView.configure(with: data.trendsData)
        patientInsightsView.configure(with: data.patientInsights)
        exercisePerformanceView.configure(with: data.exercisePerformance)
        alertsView.configure(with: data.alerts)
    }
    
    @objc private func filterTapped() {
        let filterVC = AnalyticsFilterViewController()
        filterVC.delegate = self
        let navController = UINavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    @objc private func exportTapped() {
        guard let data = analyticsData else { return }
        let reportGenerator = AnalyticsReportGenerator()
        let report = reportGenerator.generateReport(from: data)
        
        let activityVC = UIActivityViewController(activityItems: [report], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

// MARK: - Analytics Data Models

struct PTAnalyticsData {
    let clinicName: String
    let dateRange: DateInterval
    let totalPatients: Int
    let activePatients: Int
    let averageCompliance: Double
    let sessionsToday: Int
    let averageFormQuality: Double
    let trendsData: TrendsData
    let patientInsights: PatientInsightsData
    let exercisePerformance: ExercisePerformanceData
    let alerts: [AnalyticsAlert]
}

struct TrendsData {
    let complianceOverTime: [TrendPoint]
    let formQualityOverTime: [TrendPoint]
    let sessionVolumeOverTime: [TrendPoint]
}

struct TrendPoint {
    let date: Date
    let value: Double
}

struct PatientInsightsData {
    let topPerformers: [PatientPerformance]
    let needsAttention: [PatientPerformance]
    let newPatients: [PatientPerformance]
    let averageAge: Double
    let genderDistribution: [String: Int]
}

struct PatientPerformance {
    let patient: User
    let complianceRate: Double
    let formScore: Double
    let lastActive: Date
    let trend: PerformanceTrend
}

enum PerformanceTrend {
    case improving, stable, declining
    
    var color: UIColor {
        switch self {
        case .improving: return .systemGreen
        case .stable: return .systemOrange
        case .declining: return .systemRed
        }
    }
    
    var icon: String {
        switch self {
        case .improving: return "arrow.up.circle.fill"
        case .stable: return "minus.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        }
    }
}

struct ExercisePerformanceData {
    let popularExercises: [ExerciseStats]
    let difficultExercises: [ExerciseStats]
    let formQualityByExercise: [ExerciseStats]
}

struct ExerciseStats {
    let exerciseName: String
    let totalSessions: Int
    let averageFormScore: Double
    let completionRate: Double
    let trend: PerformanceTrend
}

struct AnalyticsAlert {
    let id: String
    let type: AlertType
    let title: String
    let message: String
    let severity: AlertSeverity
    let patientId: String?
    let createdAt: Date
}

enum AlertType {
    case lowCompliance, formDeclining, missedSessions, achievement
}

enum AlertSeverity {
    case low, medium, high
    
    var color: UIColor {
        switch self {
        case .low: return .systemBlue
        case .medium: return .systemOrange
        case .high: return .systemRed
        }
    }
}

// MARK: - Analytics Service

class PTAnalyticsService {
    static let shared = PTAnalyticsService()
    
    private init() {}
    
    func getAnalyticsData(completion: @escaping (PTAnalyticsData) -> Void) {
        // Simulate API call with mock data
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let mockData = self.generateMockAnalyticsData()
            completion(mockData)
        }
    }
    
    private func generateMockAnalyticsData() -> PTAnalyticsData {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        
        let dateRange = DateInterval(start: startDate, end: endDate)
        
        let trendsData = TrendsData(
            complianceOverTime: generateTrendData(days: 30, baseValue: 75, variance: 15),
            formQualityOverTime: generateTrendData(days: 30, baseValue: 82, variance: 10),
            sessionVolumeOverTime: generateTrendData(days: 30, baseValue: 28, variance: 12)
        )
        
        let patientInsights = PatientInsightsData(
            topPerformers: [
                PatientPerformance(patient: User(id: "p1", email: "sarah@demo.com", firstName: "Sarah", lastName: "Johnson", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true), complianceRate: 96, formScore: 94, lastActive: Date(), trend: .improving),
                PatientPerformance(patient: User(id: "p2", email: "mike@demo.com", firstName: "Mike", lastName: "Chen", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true), complianceRate: 92, formScore: 89, lastActive: Date(), trend: .stable)
            ],
            needsAttention: [
                PatientPerformance(patient: User(id: "p3", email: "emma@demo.com", firstName: "Emma", lastName: "Davis", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true), complianceRate: 45, formScore: 67, lastActive: calendar.date(byAdding: .day, value: -5, to: Date()) ?? Date(), trend: .declining)
            ],
            newPatients: [],
            averageAge: 52.3,
            genderDistribution: ["Female": 68, "Male": 59]
        )
        
        let exercisePerformance = ExercisePerformanceData(
            popularExercises: [
                ExerciseStats(exerciseName: "Shoulder Raises", totalSessions: 342, averageFormScore: 84.2, completionRate: 89.1, trend: .improving),
                ExerciseStats(exerciseName: "Squats", totalSessions: 298, averageFormScore: 78.9, completionRate: 76.3, trend: .stable),
                ExerciseStats(exerciseName: "Balance Stand", totalSessions: 156, averageFormScore: 91.2, completionRate: 94.7, trend: .improving)
            ],
            difficultExercises: [
                ExerciseStats(exerciseName: "Squats", totalSessions: 298, averageFormScore: 68.4, completionRate: 65.2, trend: .declining)
            ],
            formQualityByExercise: []
        )
        
        let alerts = [
            AnalyticsAlert(id: "1", type: .lowCompliance, title: "Low Compliance Alert", message: "Emma Davis hasn't completed exercises in 5 days", severity: .high, patientId: "p3", createdAt: Date()),
            AnalyticsAlert(id: "2", type: .achievement, title: "Milestone Reached", message: "Sarah Johnson completed 50 sessions!", severity: .low, patientId: "p1", createdAt: Date()),
            AnalyticsAlert(id: "3", type: .formDeclining, title: "Form Quality Declining", message: "3 patients showing decreased form scores", severity: .medium, patientId: nil, createdAt: Date())
        ]
        
        return PTAnalyticsData(
            clinicName: "Downtown Physical Therapy",
            dateRange: dateRange,
            totalPatients: 127,
            activePatients: 89,
            averageCompliance: 78.4,
            sessionsToday: 34,
            averageFormQuality: 84.2,
            trendsData: trendsData,
            patientInsights: patientInsights,
            exercisePerformance: exercisePerformance,
            alerts: alerts
        )
    }
    
    private func generateTrendData(days: Int, baseValue: Double, variance: Double) -> [TrendPoint] {
        var points: [TrendPoint] = []
        let calendar = Calendar.current
        
        for i in 0..<days {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let randomVariation = Double.random(in: -variance...variance)
            let trend = Double(i) * 0.2 // Slight upward trend
            let value = max(0, baseValue + randomVariation + trend)
            points.append(TrendPoint(date: date, value: value))
        }
        
        return points.reversed()
    }
}

// MARK: - Analytics Components

class AnalyticsHeaderView: UIView {
    private let clinicNameLabel = UILabel()
    private let dateRangeLabel = UILabel()
    private let summaryLabel = UILabel()
    private let refreshButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        clinicNameLabel.translatesAutoresizingMaskIntoConstraints = false
        clinicNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        addSubview(clinicNameLabel)
        
        dateRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateRangeLabel.font = .systemFont(ofSize: 16)
        dateRangeLabel.textColor = .secondaryLabel
        addSubview(dateRangeLabel)
        
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = .systemFont(ofSize: 14)
        summaryLabel.textColor = .tertiaryLabel
        summaryLabel.numberOfLines = 2
        addSubview(summaryLabel)
        
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            clinicNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            clinicNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            clinicNameLabel.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -12),
            
            dateRangeLabel.topAnchor.constraint(equalTo: clinicNameLabel.bottomAnchor, constant: 4),
            dateRangeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            summaryLabel.topAnchor.constraint(equalTo: dateRangeLabel.bottomAnchor, constant: 8),
            summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            summaryLabel.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -12),
            
            refreshButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            refreshButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 32),
            refreshButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(with data: PTAnalyticsData) {
        clinicNameLabel.text = data.clinicName
        dateRangeLabel.text = "Last 30 Days"
        summaryLabel.text = "\(data.activePatients) active patients • \(Int(data.averageCompliance))% avg compliance • \(data.sessionsToday) sessions today"
    }
    
    @objc private func refreshTapped() {
        // Add refresh animation
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 1.0
        refreshButton.layer.add(rotation, forKey: "rotation")
        
        // Notify parent to refresh data
        NotificationCenter.default.post(name: .analyticsRefreshRequested, object: nil)
    }
}

class TrendsChartView: UIView {
    private let titleLabel = UILabel()
    private let chartView = UIView()
    private var trendsData: TrendsData?
    
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
        titleLabel.text = "Compliance & Performance Trends"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        addSubview(titleLabel)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .systemGray6
        chartView.layer.cornerRadius = 12
        addSubview(chartView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with data: TrendsData) {
        self.trendsData = data
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let data = trendsData, !data.complianceOverTime.isEmpty else { return }
        
        let chartRect = chartView.frame
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw compliance trend line
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(3)
        
        let points = data.complianceOverTime
        let maxValue = points.map { $0.value }.max() ?? 100
        let minValue = points.map { $0.value }.min() ?? 0
        
        for (index, point) in points.enumerated() {
            let x = chartRect.minX + (chartRect.width * CGFloat(index) / CGFloat(points.count - 1))
            let normalizedValue = (point.value - minValue) / (maxValue - minValue)
            let y = chartRect.maxY - (chartRect.height * normalizedValue)
            
            if index == 0 {
                context.move(to: CGPoint(x: x, y: y))
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.strokePath()
    }
}

class PatientInsightsView: UIView {
    private let titleLabel = UILabel()
    private let topPerformersSection = UIStackView()
    private let needsAttentionSection = UIStackView()
    
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
        titleLabel.text = "Patient Insights"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        addSubview(titleLabel)
        
        topPerformersSection.translatesAutoresizingMaskIntoConstraints = false
        topPerformersSection.axis = .vertical
        topPerformersSection.spacing = 8
        addSubview(topPerformersSection)
        
        needsAttentionSection.translatesAutoresizingMaskIntoConstraints = false
        needsAttentionSection.axis = .vertical
        needsAttentionSection.spacing = 8
        addSubview(needsAttentionSection)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            topPerformersSection.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            topPerformersSection.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            topPerformersSection.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            topPerformersSection.heightAnchor.constraint(equalToConstant: 80),
            
            needsAttentionSection.topAnchor.constraint(equalTo: topPerformersSection.bottomAnchor, constant: 16),
            needsAttentionSection.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            needsAttentionSection.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            needsAttentionSection.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with data: PatientInsightsData) {
        // Clear existing views
        topPerformersSection.arrangedSubviews.forEach { $0.removeFromSuperview() }
        needsAttentionSection.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add top performers header
        let topLabel = UILabel()
        topLabel.text = "🏆 Top Performers"
        topLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        topLabel.textColor = .systemGreen
        topPerformersSection.addArrangedSubview(topLabel)
        
        // Add needs attention header
        let attentionLabel = UILabel()
        attentionLabel.text = "⚠️ Needs Attention"
        attentionLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        attentionLabel.textColor = .systemRed
        needsAttentionSection.addArrangedSubview(attentionLabel)
        
        // Add patient performance items
        for performance in data.topPerformers.prefix(2) {
            let item = createPatientPerformanceItem(performance)
            topPerformersSection.addArrangedSubview(item)
        }
        
        for performance in data.needsAttention.prefix(2) {
            let item = createPatientPerformanceItem(performance)
            needsAttentionSection.addArrangedSubview(item)
        }
    }
    
    private func createPatientPerformanceItem(_ performance: PatientPerformance) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8
        
        let nameLabel = UILabel()
        nameLabel.text = performance.patient.fullName
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let metricsLabel = UILabel()
        metricsLabel.text = "\(Int(performance.complianceRate))% compliance • \(Int(performance.formScore))% form"
        metricsLabel.font = .systemFont(ofSize: 12)
        metricsLabel.textColor = .secondaryLabel
        metricsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let trendIcon = UIImageView(image: UIImage(systemName: performance.trend.icon))
        trendIcon.tintColor = performance.trend.color
        trendIcon.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(nameLabel)
        container.addSubview(metricsLabel)
        container.addSubview(trendIcon)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trendIcon.leadingAnchor, constant: -8),
            
            metricsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            metricsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            metricsLabel.trailingAnchor.constraint(equalTo: trendIcon.leadingAnchor, constant: -8),
            metricsLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            
            trendIcon.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            trendIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            trendIcon.widthAnchor.constraint(equalToConstant: 20),
            trendIcon.heightAnchor.constraint(equalToConstant: 20),
            
            container.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
}

class ExercisePerformanceView: UIView {
    private let titleLabel = UILabel()
    private let exercisesStackView = UIStackView()
    
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
        titleLabel.text = "Exercise Performance"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        addSubview(titleLabel)
        
        exercisesStackView.translatesAutoresizingMaskIntoConstraints = false
        exercisesStackView.axis = .vertical
        exercisesStackView.spacing = 12
        addSubview(exercisesStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            exercisesStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            exercisesStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            exercisesStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            exercisesStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with data: ExercisePerformanceData) {
        exercisesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for exerciseStats in data.popularExercises {
            let item = createExerciseStatsItem(exerciseStats)
            exercisesStackView.addArrangedSubview(item)
        }
    }
    
    private func createExerciseStatsItem(_ stats: ExerciseStats) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12
        
        let nameLabel = UILabel()
        nameLabel.text = stats.exerciseName
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let statsLabel = UILabel()
        statsLabel.text = "\(stats.totalSessions) sessions • \(Int(stats.averageFormScore))% avg form • \(Int(stats.completionRate))% completion"
        statsLabel.font = .systemFont(ofSize: 12)
        statsLabel.textColor = .secondaryLabel
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let progressBar = UIProgressView()
        progressBar.progressTintColor = stats.trend.color
        progressBar.progress = Float(stats.averageFormScore / 100.0)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(nameLabel)
        container.addSubview(statsLabel)
        container.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            statsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            statsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            statsLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            progressBar.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            progressBar.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            
            container.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        return container
    }
}

class AlertsAndNotificationsView: UIView {
    private let titleLabel = UILabel()
    private let alertsStackView = UIStackView()
    
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
        titleLabel.text = "Alerts & Notifications"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        addSubview(titleLabel)
        
        alertsStackView.translatesAutoresizingMaskIntoConstraints = false
        alertsStackView.axis = .vertical
        alertsStackView.spacing = 8
        addSubview(alertsStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            alertsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            alertsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            alertsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            alertsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with alerts: [AnalyticsAlert]) {
        alertsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for alert in alerts.prefix(3) {
            let item = createAlertItem(alert)
            alertsStackView.addArrangedSubview(item)
        }
    }
    
    private func createAlertItem(_ alert: AnalyticsAlert) -> UIView {
        let container = UIView()
        container.backgroundColor = alert.severity.color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = alert.severity.color.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = alert.title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let messageLabel = UILabel()
        messageLabel.text = alert.message
        messageLabel.font = .systemFont(ofSize: 12)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
        return container
    }
}

// MARK: - Analytics Filter & Export

class AnalyticsFilterViewController: UIViewController {
    weak var delegate: AnalyticsFilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Filter Analytics"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Apply",
            style: .done,
            target: self,
            action: #selector(applyTapped)
        )
        
        // Add filter options UI here
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func applyTapped() {
        // Apply filters and notify delegate
        dismiss(animated: true)
    }
}

protocol AnalyticsFilterDelegate: AnyObject {
    func didApplyFilters(_ filters: AnalyticsFilters)
}

struct AnalyticsFilters {
    let dateRange: DateInterval
    let exerciseTypes: [String]
    let patientGroups: [String]
}

class AnalyticsReportGenerator {
    func generateReport(from data: PTAnalyticsData) -> String {
        return """
        📊 PT Analytics Report - \(data.clinicName)
        Generated: \(Date().formatted())
        Period: \(data.dateRange.start.formatted(date: .abbreviated, time: .omitted)) - \(data.dateRange.end.formatted(date: .abbreviated, time: .omitted))
        
        📈 Key Metrics:
        • Total Patients: \(data.totalPatients)
        • Active Patients: \(data.activePatients)
        • Average Compliance: \(Int(data.averageCompliance))%
        • Average Form Quality: \(Int(data.averageFormQuality))%
        • Sessions Today: \(data.sessionsToday)
        
        🏆 Top Performers:
        \(data.patientInsights.topPerformers.map { "• \($0.patient.fullName): \(Int($0.complianceRate))% compliance" }.joined(separator: "\n"))
        
        ⚠️ Needs Attention:
        \(data.patientInsights.needsAttention.map { "• \($0.patient.fullName): \(Int($0.complianceRate))% compliance" }.joined(separator: "\n"))
        
        🎯 Popular Exercises:
        \(data.exercisePerformance.popularExercises.map { "• \($0.exerciseName): \($0.totalSessions) sessions, \(Int($0.averageFormScore))% avg form" }.joined(separator: "\n"))
        """
    }
}

// MARK: - Extensions

extension Notification.Name {
    static let analyticsRefreshRequested = Notification.Name("analyticsRefreshRequested")
}

extension PTAnalyticsViewController: AnalyticsFilterDelegate {
    func didApplyFilters(_ filters: AnalyticsFilters) {
        // Reload data with filters applied
        loadAnalyticsData()
    }
}
