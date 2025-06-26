import UIKit

class PTDashboardViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerView = UIView()
    private let welcomeLabel = UILabel()
    private let clinicLabel = UILabel()
    
    private let statsStackView = UIStackView()
    private let patientsCardView = DashboardCardView()
    private let assignmentsCardView = DashboardCardView()
    private let completionCardView = DashboardCardView()
    
    private let sectionStackView = UIStackView()
    private let recentPatientsView = DashboardSectionView()
    private let recentAssignmentsView = DashboardSectionView()
    
    private let quickActionsView = QuickActionsView()
    
    // MARK: - Properties
    private let authService = AuthenticationService.shared
    private let assignmentService = AssignmentService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        loadDashboardData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup header
        setupHeader()
        
        // Setup stats cards
        setupStatsCards()
        
        // Setup sections
        setupSections()
        
        // Setup quick actions
        setupQuickActions()
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .systemBlue
        headerView.layer.cornerRadius = 16
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contentView.addSubview(headerView)
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.text = "Welcome back, Dr. Smith"
        welcomeLabel.font = .systemFont(ofSize: 24, weight: .bold)
        welcomeLabel.textColor = .white
        headerView.addSubview(welcomeLabel)
        
        clinicLabel.translatesAutoresizingMaskIntoConstraints = false
        clinicLabel.text = "Central Physical Therapy"
        clinicLabel.font = .systemFont(ofSize: 16, weight: .medium)
        clinicLabel.textColor = .white.withAlphaComponent(0.9)
        headerView.addSubview(clinicLabel)
    }
    
    private func setupStatsCards() {
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 12
        contentView.addSubview(statsStackView)
        
        // Patients card
        patientsCardView.configure(title: "Active Patients", value: "24", icon: "person.3.fill", color: .systemBlue)
        
        // Assignments card
        assignmentsCardView.configure(title: "Active Plans", value: "18", icon: "list.bullet.clipboard.fill", color: .systemGreen)
        
        // Completion rate card
        completionCardView.configure(title: "Completion Rate", value: "87%", icon: "chart.line.uptrend.xyaxis", color: .systemOrange)
        
        statsStackView.addArrangedSubview(patientsCardView)
        statsStackView.addArrangedSubview(assignmentsCardView)
        statsStackView.addArrangedSubview(completionCardView)
    }
    
    private func setupSections() {
        sectionStackView.translatesAutoresizingMaskIntoConstraints = false
        sectionStackView.axis = .vertical
        sectionStackView.spacing = 20
        contentView.addSubview(sectionStackView)
        
        // Recent patients section
        recentPatientsView.configure(
            title: "Recent Patients",
            items: [
                "Sarah Johnson - Completed shoulder exercise",
                "Mike Chen - Missed knee therapy session",
                "Emma Davis - Excellent progress on balance training"
            ],
            actionTitle: "View All Patients"
        ) { [weak self] in
            self?.showPatientList()
        }
        
        // Recent assignments section
        recentAssignmentsView.configure(
            title: "Recent Assignments",
            items: [
                "Shoulder Raise - Assigned to Sarah J.",
                "Squats - Updated for Mike C.",
                "Balance Training - New plan for Emma D."
            ],
            actionTitle: "Manage Assignments"
        ) { [weak self] in
            self?.showAssignmentManagement()
        }
        
        sectionStackView.addArrangedSubview(recentPatientsView)
        sectionStackView.addArrangedSubview(recentAssignmentsView)
    }
    
    private func setupQuickActions() {
        quickActionsView.translatesAutoresizingMaskIntoConstraints = false
        quickActionsView.configure { [weak self] action in
            switch action {
            case .addPatient:
                self?.addNewPatient()
            case .createAssignment:
                self?.createAssignment()
            case .viewAnalytics:
                self?.viewAnalytics()
            case .testExercise:
                self?.testExercise()
            }
        }
        contentView.addSubview(quickActionsView)
    }
    
    private func setupNavigationBar() {
        title = "PT Dashboard"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Profile button
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        
        // Notifications button
        let notificationButton = UIBarButtonItem(
            image: UIImage(systemName: "bell"),
            style: .plain,
            target: self,
            action: #selector(notificationsTapped)
        )
        
        navigationItem.rightBarButtonItems = [profileButton, notificationButton]
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header view
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            // Welcome label
            welcomeLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30),
            welcomeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            // Clinic label
            clinicLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 4),
            clinicLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            clinicLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            // Stats stack view
            statsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsStackView.heightAnchor.constraint(equalToConstant: 100),
            
            // Section stack view
            sectionStackView.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 30),
            sectionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sectionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Quick actions view
            quickActionsView.topAnchor.constraint(equalTo: sectionStackView.bottomAnchor, constant: 30),
            quickActionsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quickActionsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            quickActionsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Data Loading
    private func loadDashboardData() {
        // Load current user info
        if let user = authService.currentUser {
            welcomeLabel.text = "Welcome back, \(user.fullName)"
        }
        
        // Load dashboard statistics
        // In a real app, this would be an API call
        updateStats()
    }
    
    private func refreshData() {
        // Refresh dashboard data
        updateStats()
    }
    
    private func updateStats() {
        // Mock data - in real app, fetch from API
        patientsCardView.updateValue("24")
        assignmentsCardView.updateValue("18")
        completionCardView.updateValue("87%")
    }
    
    // MARK: - Actions
    @objc private func profileTapped() {
        let alert = UIAlertController(title: "Profile", message: "Profile management coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            self?.signOut()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func notificationsTapped() {
        let alert = UIAlertController(title: "Notifications", message: "You have 3 new patient updates", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "View All", style: .default))
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    private func signOut() {
        authService.signOut()
        
        // Navigate back to login
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        view.window?.rootViewController = navController
    }
    
    // MARK: - Navigation
    private func showPatientList() {
        let patientListVC = PatientListViewController()
        navigationController?.pushViewController(patientListVC, animated: true)
    }
    
    private func showAssignmentManagement() {
        let alert = UIAlertController(title: "Assignment Management", message: "Assignment interface coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func addNewPatient() {
        let alert = UIAlertController(title: "Add Patient", message: "Patient registration coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func createAssignment() {
        let assignmentVC = ExerciseAssignmentViewController()
        let navController = UINavigationController(rootViewController: assignmentVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    private func viewAnalytics() {
        let alert = UIAlertController(title: "Analytics", message: "Analytics dashboard coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func testExercise() {
        // Navigate to exercise testing
        let exerciseVC = ExerciseViewController(exercise: Exercise.shoulderRaise)
        exerciseVC.modalPresentationStyle = .fullScreen
        present(exerciseVC, animated: true)
    }
}

// MARK: - Dashboard Components

class DashboardCardView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textAlignment = .center
        addSubview(valueLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            valueLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(title: String, value: String, icon: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = color
    }
    
    func updateValue(_ newValue: String) {
        valueLabel.text = newValue
    }
}

class DashboardSectionView: UIView {
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    private let actionButton = UIButton(type: .system)
    private var actionHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        addSubview(titleLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        addSubview(stackView)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            actionButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(title: String, items: [String], actionTitle: String, actionHandler: @escaping () -> Void) {
        titleLabel.text = title
        actionButton.setTitle(actionTitle, for: .normal)
        self.actionHandler = actionHandler
        
        // Clear previous items
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new items
        for item in items {
            let label = UILabel()
            label.text = "• \(item)"
            label.font = .systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }
    }
    
    @objc private func actionTapped() {
        actionHandler?()
    }
}

class QuickActionsView: UIView {
    private let titleLabel = UILabel()
    private let buttonStackView = UIStackView()
    private var actionHandler: ((QuickAction) -> Void)?
    
    enum QuickAction {
        case addPatient, createAssignment, viewAnalytics, testExercise
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Quick Actions"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        addSubview(titleLabel)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 12
        addSubview(buttonStackView)
        
        // Create action buttons
        let addPatientButton = createActionButton(title: "Add Patient", icon: "person.badge.plus", action: .addPatient)
        let createAssignmentButton = createActionButton(title: "Create Plan", icon: "doc.badge.plus", action: .createAssignment)
        let analyticsButton = createActionButton(title: "Analytics", icon: "chart.bar", action: .viewAnalytics)
        let testButton = createActionButton(title: "Test Exercise", icon: "play.circle", action: .testExercise)
        
        buttonStackView.addArrangedSubview(addPatientButton)
        buttonStackView.addArrangedSubview(createAssignmentButton)
        buttonStackView.addArrangedSubview(analyticsButton)
        buttonStackView.addArrangedSubview(testButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            buttonStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func createActionButton(title: String, icon: String, action: QuickAction) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.tintColor = .systemBlue
        button.imageView?.contentMode = .scaleAspectFit
        
        // Arrange image and title vertically
        button.titleEdgeInsets = UIEdgeInsets(top: 40, left: -button.imageView!.frame.size.width, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: -button.titleLabel!.intrinsicContentSize.width)
        
        button.addAction(UIAction { [weak self] _ in
            self?.actionHandler?(action)
        }, for: .touchUpInside)
        
        return button
    }
    
    func configure(actionHandler: @escaping (QuickAction) -> Void) {
        self.actionHandler = actionHandler
    }
}
