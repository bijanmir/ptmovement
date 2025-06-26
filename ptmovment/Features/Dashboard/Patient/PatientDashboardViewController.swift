//
//  PatientDashboardViewController.swift
//  ptmovment
//
//  Created by Bijan Mirfakhrai on 6/24/25.
//

import UIKit

class PatientDashboardViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerView = UIView()
    private let welcomeLabel = UILabel()
    private let motivationLabel = UILabel()
    
    private let progressCardView = ProgressCardView()
    private let todaysExercisesView = TodaysExercisesView()
    private let recentActivityView = RecentActivityView()
    private let achievementsView = AchievementsView()
    
    // MARK: - Properties
    private let authService = AuthenticationService.shared
    private let assignmentService = AssignmentService.shared
    private var assignments: [ExerciseAssignment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        loadPatientData()
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
        
        // Setup components
        progressCardView.translatesAutoresizingMaskIntoConstraints = false
        todaysExercisesView.translatesAutoresizingMaskIntoConstraints = false
        recentActivityView.translatesAutoresizingMaskIntoConstraints = false
        achievementsView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(progressCardView)
        contentView.addSubview(todaysExercisesView)
        contentView.addSubview(recentActivityView)
        contentView.addSubview(achievementsView)
        
        // Configure components
        todaysExercisesView.delegate = self
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .systemGreen
        headerView.layer.cornerRadius = 16
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contentView.addSubview(headerView)
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.text = "Hello, Sarah!"
        welcomeLabel.font = .systemFont(ofSize: 24, weight: .bold)
        welcomeLabel.textColor = .white
        headerView.addSubview(welcomeLabel)
        
        motivationLabel.translatesAutoresizingMaskIntoConstraints = false
        motivationLabel.text = "Ready for today's exercises?"
        motivationLabel.font = .systemFont(ofSize: 16, weight: .medium)
        motivationLabel.textColor = .white.withAlphaComponent(0.9)
        headerView.addSubview(motivationLabel)
    }
    
    private func setupNavigationBar() {
        title = "My Exercises"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Profile button
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        
        // Progress button
        let progressButton = UIBarButtonItem(
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            style: .plain,
            target: self,
            action: #selector(progressTapped)
        )
        
        navigationItem.rightBarButtonItems = [profileButton, progressButton]
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
            
            // Motivation label
            motivationLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 4),
            motivationLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            motivationLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            // Progress card
            progressCardView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            progressCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            progressCardView.heightAnchor.constraint(equalToConstant: 120),
            
            // Today's exercises
            todaysExercisesView.topAnchor.constraint(equalTo: progressCardView.bottomAnchor, constant: 20),
            todaysExercisesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            todaysExercisesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Recent activity
            recentActivityView.topAnchor.constraint(equalTo: todaysExercisesView.bottomAnchor, constant: 20),
            recentActivityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recentActivityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Achievements
            achievementsView.topAnchor.constraint(equalTo: recentActivityView.bottomAnchor, constant: 20),
            achievementsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            achievementsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            achievementsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Data Loading
    private func loadPatientData() {
        // Load current user info
        if let user = authService.currentUser {
            welcomeLabel.text = "Hello, \(user.firstName)!"
        }
        
        // Load assignments
        if let user = authService.currentUser {
            assignments = assignmentService.getAssignmentsForPatient(user.id)
            updateUI()
        }
    }
    
    private func refreshData() {
        loadPatientData()
    }
    
    private func updateUI() {
        // Update progress card
        let completedToday = 2 // Mock data
        let totalToday = assignments.count
        progressCardView.configure(
            completedToday: completedToday,
            totalToday: totalToday,
            weeklyStreak: 5
        )
        
        // Update today's exercises
        todaysExercisesView.configure(assignments: assignments)
        
        // Update recent activity
        recentActivityView.configure(activities: [
            "Completed Shoulder Raises - 10 reps",
            "Missed Squats session",
            "Excellent form on Balance Training",
            "3-day streak achieved!"
        ])
        
        // Update achievements
        achievementsView.configure(achievements: [
            ("First Exercise", "trophy.fill", true),
            ("Week Streak", "flame.fill", true),
            ("Perfect Form", "star.fill", false),
            ("Month Milestone", "calendar", false)
        ])
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
    
    @objc private func progressTapped() {
        let alert = UIAlertController(title: "Progress", message: "Detailed progress tracking coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
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
}

// MARK: - Exercise Delegate
extension PatientDashboardViewController: TodaysExercisesViewDelegate {
    func didSelectExercise(_ assignment: ExerciseAssignment) {
        guard let exercise = ExerciseLibraryService.shared.getExerciseById(assignment.exerciseId) else { return }
        
        let exerciseVC = ExerciseViewController(exercise: exercise, assignment: assignment)
        exerciseVC.modalPresentationStyle = .fullScreen
        present(exerciseVC, animated: true)
    }
}

// MARK: - Patient Dashboard Components

class ProgressCardView: UIView {
    private let todayLabel = UILabel()
    private let todayProgressLabel = UILabel()
    private let streakLabel = UILabel()
    private let streakValueLabel = UILabel()
    private let progressBar = UIProgressView()
    
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
        
        todayLabel.translatesAutoresizingMaskIntoConstraints = false
        todayLabel.text = "Today's Progress"
        todayLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        addSubview(todayLabel)
        
        todayProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        todayProgressLabel.font = .systemFont(ofSize: 14, weight: .medium)
        todayProgressLabel.textColor = .secondaryLabel
        addSubview(todayProgressLabel)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = .systemGreen
        progressBar.trackTintColor = .systemGray5
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true
        addSubview(progressBar)
        
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.text = "🔥 Weekly Streak"
        streakLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(streakLabel)
        
        streakValueLabel.translatesAutoresizingMaskIntoConstraints = false
        streakValueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        streakValueLabel.textColor = .systemOrange
        addSubview(streakValueLabel)
        
        NSLayoutConstraint.activate([
            todayLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            todayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            todayProgressLabel.topAnchor.constraint(equalTo: todayLabel.bottomAnchor, constant: 4),
            todayProgressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            progressBar.topAnchor.constraint(equalTo: todayProgressLabel.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -10),
            progressBar.heightAnchor.constraint(equalToConstant: 6),
            
            streakLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            streakLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            streakValueLabel.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 4),
            streakValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    func configure(completedToday: Int, totalToday: Int, weeklyStreak: Int) {
        todayProgressLabel.text = "\(completedToday) of \(totalToday) exercises completed"
        let progress = totalToday > 0 ? Float(completedToday) / Float(totalToday) : 0
        progressBar.setProgress(progress, animated: true)
        streakValueLabel.text = "\(weeklyStreak) days"
    }
}

protocol TodaysExercisesViewDelegate: AnyObject {
    func didSelectExercise(_ assignment: ExerciseAssignment)
}

class TodaysExercisesView: UIView {
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    weak var delegate: TodaysExercisesViewDelegate?
    
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
        titleLabel.text = "Today's Exercises"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        addSubview(titleLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(assignments: [ExerciseAssignment]) {
        // Clear previous views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if assignments.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No exercises assigned for today"
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.textAlignment = .center
            stackView.addArrangedSubview(emptyLabel)
            return
        }
        
        for assignment in assignments {
            if let exercise = ExerciseLibraryService.shared.getExerciseById(assignment.exerciseId) {
                let exerciseView = ExerciseRowView()
                exerciseView.configure(exercise: exercise, assignment: assignment) { [weak self] in
                    self?.delegate?.didSelectExercise(assignment)
                }
                stackView.addArrangedSubview(exerciseView)
            }
        }
    }
}

class ExerciseRowView: UIView {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let startButton = UIButton(type: .system)
    private var tapHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        addSubview(iconImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        addSubview(titleLabel)
        
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        detailLabel.textColor = .secondaryLabel
        addSubview(detailLabel)
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 16
        startButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        addSubview(startButton)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: startButton.leadingAnchor, constant: -12),
            
            detailLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            detailLabel.trailingAnchor.constraint(equalTo: startButton.leadingAnchor, constant: -12),
            detailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            startButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 60),
            startButton.heightAnchor.constraint(equalToConstant: 32),
            
            heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configure(exercise: Exercise, assignment: ExerciseAssignment, tapHandler: @escaping () -> Void) {
        iconImageView.image = UIImage(systemName: "figure.strengthtraining.functional")
        titleLabel.text = exercise.name
        detailLabel.text = "\(assignment.prescribedReps) reps • \(assignment.frequencyPerWeek)x/week"
        self.tapHandler = tapHandler
    }
    
    @objc private func startTapped() {
        tapHandler?()
    }
}

class RecentActivityView: UIView {
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    
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
        titleLabel.text = "Recent Activity"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        addSubview(titleLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(activities: [String]) {
        // Clear previous views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for activity in activities {
            let label = UILabel()
            label.text = "• \(activity)"
            label.font = .systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }
    }
}

class AchievementsView: UIView {
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    
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
        titleLabel.text = "🏆 Achievements"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        addSubview(titleLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func configure(achievements: [(String, String, Bool)]) {
        // Clear previous views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (title, icon, isUnlocked) in achievements {
            let achievementView = AchievementBadgeView()
            achievementView.configure(title: title, icon: icon, isUnlocked: isUnlocked)
            stackView.addArrangedSubview(achievementView)
        }
    }
}

class AchievementBadgeView: UIView {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(title: String, icon: String, isUnlocked: Bool) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        
        if isUnlocked {
            iconImageView.tintColor = .systemYellow
            titleLabel.textColor = .label
            backgroundColor = .systemYellow.withAlphaComponent(0.1)
        } else {
            iconImageView.tintColor = .systemGray3
            titleLabel.textColor = .systemGray3
            backgroundColor = .systemGray6
        }
    }
}
