import UIKit

class PatientListViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchController = UISearchController(searchResultsController: nil)
    private let addPatientButton = UIBarButtonItem()
    
    // MARK: - Properties
    private var patients: [User] = []
    private var filteredPatients: [User] = []
    private var patientAssignments: [String: [ExerciseAssignment]] = [:]
    
    // Mock data
    private let mockPatients = [
        User(id: "p1", email: "sarah@demo.com", firstName: "Sarah", lastName: "Johnson", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true),
        User(id: "p2", email: "mike@demo.com", firstName: "Mike", lastName: "Chen", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true),
        User(id: "p3", email: "emma@demo.com", firstName: "Emma", lastName: "Davis", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true),
        User(id: "p4", email: "john@demo.com", firstName: "John", lastName: "Smith", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true),
        User(id: "p5", email: "alice@demo.com", firstName: "Alice", lastName: "Brown", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        loadPatients()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "My Patients"
        
        // Setup navigation bar
        addPatientButton.image = UIImage(systemName: "person.badge.plus")
        addPatientButton.target = self
        addPatientButton.action = #selector(addPatientTapped)
        navigationItem.rightBarButtonItem = addPatientButton
        
        // Setup table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PatientListCell.self, forCellReuseIdentifier: "PatientListCell")
        tableView.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search patients..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func loadPatients() {
        // Load mock data
        patients = mockPatients
        filteredPatients = patients
        
        // Load assignments for each patient
        for patient in patients {
            patientAssignments[patient.id] = AssignmentService.shared.getAssignmentsForPatient(patient.id)
        }
        
        tableView.reloadData()
    }
    
    private func refreshData() {
        loadPatients()
    }
    
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPatients = patients.filter { patient in
            return patient.fullName.lowercased().contains(searchText.lowercased()) ||
                   patient.email.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addPatientTapped() {
        showAddPatientAlert()
    }
    
    private func showAddPatientAlert() {
        let alert = UIAlertController(title: "Add New Patient", message: "Patient registration coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func viewPatientDetails(_ patient: User) {
        let detailVC = PatientDetailViewController(patient: patient)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func assignExercise(to patient: User) {
        let assignmentVC = ExerciseAssignmentViewController(preselectedPatient: patient)
        let navController = UINavigationController(rootViewController: assignmentVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
}

// MARK: - Table View Data Source & Delegate
extension PatientListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredPatients.count : patients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientListCell", for: indexPath) as! PatientListCell
        let patient = isSearching ? filteredPatients[indexPath.row] : patients[indexPath.row]
        let assignments = patientAssignments[patient.id] ?? []
        cell.configure(patient: patient, assignments: assignments)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let patient = isSearching ? filteredPatients[indexPath.row] : patients[indexPath.row]
        viewPatientDetails(patient)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let patient = isSearching ? filteredPatients[indexPath.row] : patients[indexPath.row]
        
        let assignAction = UIContextualAction(style: .normal, title: "Assign") { [weak self] _, _, completion in
            self?.assignExercise(to: patient)
            completion(true)
        }
        assignAction.backgroundColor = .systemBlue
        assignAction.image = UIImage(systemName: "plus.circle")
        
        let configuration = UISwipeActionsConfiguration(actions: [assignAction])
        return configuration
    }
}

// MARK: - Search Results Updating
extension PatientListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

// MARK: - Patient List Cell Delegate
extension PatientListViewController: PatientListCellDelegate {
    func didTapAssignExercise(for patient: User) {
        assignExercise(to: patient)
    }
    
    func didTapViewProgress(for patient: User) {
        viewPatientDetails(patient)
    }
}

// MARK: - Patient List Cell
protocol PatientListCellDelegate: AnyObject {
    func didTapAssignExercise(for patient: User)
    func didTapViewProgress(for patient: User)
}

class PatientListCell: UITableViewCell {
    
    // MARK: - UI Components
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let assignmentsLabel = UILabel()
    private let progressLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    // MARK: - Properties
    private var patient: User?
    weak var delegate: PatientListCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Avatar
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemBlue
        avatarImageView.contentMode = .scaleAspectFit
        contentView.addSubview(avatarImageView)
        
        // Name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(nameLabel)
        
        // Email
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emailLabel.textColor = .secondaryLabel
        contentView.addSubview(emailLabel)
        
        // Assignments
        assignmentsLabel.translatesAutoresizingMaskIntoConstraints = false
        assignmentsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        assignmentsLabel.textColor = .systemBlue
        contentView.addSubview(assignmentsLabel)
        
        // Progress
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.font = .systemFont(ofSize: 12, weight: .medium)
        progressLabel.textColor = .systemGreen
        contentView.addSubview(progressLabel)
        
        // Action button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        actionButton.tintColor = .systemBlue
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        contentView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12),
            
            emailLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            emailLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12),
            
            assignmentsLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            assignmentsLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            
            progressLabel.leadingAnchor.constraint(equalTo: assignmentsLabel.trailingAnchor, constant: 12),
            progressLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            progressLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12),
            
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 30),
            actionButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(patient: User, assignments: [ExerciseAssignment]) {
        self.patient = patient
        nameLabel.text = patient.fullName
        emailLabel.text = patient.email
        
        let activeAssignments = assignments.filter { !$0.isCompleted }
        assignmentsLabel.text = "\(activeAssignments.count) active plans"
        
        // Calculate completion rate (mock data)
        let completionRate = Int.random(in: 60...95)
        progressLabel.text = "\(completionRate)% completed"
    }
    
    @objc private func actionButtonTapped() {
        guard let patient = patient else { return }
        delegate?.didTapAssignExercise(for: patient)
    }
}

// MARK: - Patient Detail View Controller
class PatientDetailViewController: UIViewController {
    
    private let patient: User
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerView = UIView()

    // Simple placeholder views for now
    private let assignmentsView = UIView()
    private let progressView = UIView()
    private let activityView = UIView()
    
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
        loadPatientData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = patient.fullName
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(assignExerciseTapped)
        )
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup components
        headerView.translatesAutoresizingMaskIntoConstraints = false
        assignmentsView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        activityView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(headerView)
        contentView.addSubview(assignmentsView)
        contentView.addSubview(progressView)
        contentView.addSubview(activityView)
        
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
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            assignmentsView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            assignmentsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            assignmentsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            assignmentsView.heightAnchor.constraint(equalToConstant: 120),
            
            progressView.topAnchor.constraint(equalTo: assignmentsView.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 120),
            
            activityView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            activityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            activityView.heightAnchor.constraint(equalToConstant: 120),
            activityView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func loadPatientData() {
        setupPatientHeader()
        setupPlaceholderViews()
    }
    
    private func setupPatientHeader() {
        headerView.backgroundColor = .systemBackground
        headerView.layer.cornerRadius = 12
        headerView.layer.shadowColor = UIColor.label.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerView.layer.shadowOpacity = 0.1
        headerView.layer.shadowRadius = 4
        
        let nameLabel = UILabel()
        nameLabel.text = patient.fullName
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(nameLabel)
        
        let emailLabel = UILabel()
        emailLabel.text = patient.email
        emailLabel.font = .systemFont(ofSize: 16)
        emailLabel.textColor = .secondaryLabel
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            emailLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            
            headerView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupPlaceholderViews() {
        // Assignments placeholder
        assignmentsView.backgroundColor = .systemBackground
        assignmentsView.layer.cornerRadius = 12
        assignmentsView.layer.shadowColor = UIColor.label.cgColor
        assignmentsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        assignmentsView.layer.shadowOpacity = 0.1
        assignmentsView.layer.shadowRadius = 4
        
        let assignmentLabel = UILabel()
        assignmentLabel.text = "📋 Current Assignments"
        assignmentLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        assignmentLabel.textAlignment = .center
        assignmentLabel.translatesAutoresizingMaskIntoConstraints = false
        assignmentsView.addSubview(assignmentLabel)
        
        let assignmentDetail = UILabel()
        assignmentDetail.text = "2 active exercise plans\nDetailed view coming soon!"
        assignmentDetail.font = .systemFont(ofSize: 14)
        assignmentDetail.textColor = .secondaryLabel
        assignmentDetail.textAlignment = .center
        assignmentDetail.numberOfLines = 0
        assignmentDetail.translatesAutoresizingMaskIntoConstraints = false
        assignmentsView.addSubview(assignmentDetail)
        
        NSLayoutConstraint.activate([
            assignmentLabel.centerXAnchor.constraint(equalTo: assignmentsView.centerXAnchor),
            assignmentLabel.topAnchor.constraint(equalTo: assignmentsView.topAnchor, constant: 20),
            
            assignmentDetail.centerXAnchor.constraint(equalTo: assignmentsView.centerXAnchor),
            assignmentDetail.topAnchor.constraint(equalTo: assignmentLabel.bottomAnchor, constant: 12)
        ])
        
        // Progress placeholder
        progressView.backgroundColor = .systemBackground
        progressView.layer.cornerRadius = 12
        progressView.layer.shadowColor = UIColor.label.cgColor
        progressView.layer.shadowOffset = CGSize(width: 0, height: 2)
        progressView.layer.shadowOpacity = 0.1
        progressView.layer.shadowRadius = 4
        
        let progressLabel = UILabel()
        progressLabel.text = "📊 Progress Overview"
        progressLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(progressLabel)
        
        let progressDetail = UILabel()
        progressDetail.text = "87% completion rate • 5 day streak\nCharts and analytics coming soon!"
        progressDetail.font = .systemFont(ofSize: 14)
        progressDetail.textColor = .secondaryLabel
        progressDetail.textAlignment = .center
        progressDetail.numberOfLines = 0
        progressDetail.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(progressDetail)
        
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: progressView.topAnchor, constant: 20),
            
            progressDetail.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            progressDetail.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 12)
        ])
        
        // Activity placeholder
        activityView.backgroundColor = .systemBackground
        activityView.layer.cornerRadius = 12
        activityView.layer.shadowColor = UIColor.label.cgColor
        activityView.layer.shadowOffset = CGSize(width: 0, height: 2)
        activityView.layer.shadowOpacity = 0.1
        activityView.layer.shadowRadius = 4
        
        let activityLabel = UILabel()
        activityLabel.text = "🏃‍♀️ Recent Activity"
        activityLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        activityLabel.textAlignment = .center
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        activityView.addSubview(activityLabel)
        
        let activityDetail = UILabel()
        activityDetail.text = "Last session: Shoulder Raises\nCompleted 10 reps with great form!\nActivity feed coming soon!"
        activityDetail.font = .systemFont(ofSize: 14)
        activityDetail.textColor = .secondaryLabel
        activityDetail.textAlignment = .center
        activityDetail.numberOfLines = 0
        activityDetail.translatesAutoresizingMaskIntoConstraints = false
        activityView.addSubview(activityDetail)
        
        NSLayoutConstraint.activate([
            activityLabel.centerXAnchor.constraint(equalTo: activityView.centerXAnchor),
            activityLabel.topAnchor.constraint(equalTo: activityView.topAnchor, constant: 20),
            
            activityDetail.centerXAnchor.constraint(equalTo: activityView.centerXAnchor),
            activityDetail.topAnchor.constraint(equalTo: activityLabel.bottomAnchor, constant: 12)
        ])
    }
    
    @objc private func assignExerciseTapped() {
        let assignmentVC = ExerciseAssignmentViewController()
        let navController = UINavigationController(rootViewController: assignmentVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
}

// Note: The remaining detail view components (PatientAssignmentsView, etc.)
// should be in a separate file to keep this manageable.
// For now, they can be temporary placeholders or simple views.
