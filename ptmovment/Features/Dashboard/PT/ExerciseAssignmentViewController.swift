import UIKit

class ExerciseAssignmentViewController: UIViewController {
    
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerLabel = UILabel()
    private let patientSelectorView = PatientSelectorView()
    private let exerciseSelectorView = ExerciseSelectorView()
    private let prescriptionView = PrescriptionDetailsView()
    private let notesView = NotesView()
    private let assignButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let assignmentService = AssignmentService.shared
    private let exerciseService = ExerciseLibraryService.shared
    private var selectedPatient: User?
    private var selectedExercise: Exercise?
    private let preselectedPatient: User?

    init(preselectedPatient: User? = nil) {
           self.preselectedPatient = preselectedPatient
           super.init(nibName: nil, bundle: nil)
       }
       
       required init?(coder: NSCoder) {
           self.preselectedPatient = nil
           super.init(coder: coder)
       }
    
    // Mock patients data
    private let mockPatients = [
        User(id: "p1", email: "sarah@demo.com", firstName: "Sarah", lastName: "Johnson", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true),
        User(id: "p2", email: "mike@demo.com", firstName: "Mike", lastName: "Chen", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true),
        User(id: "p3", email: "emma@demo.com", firstName: "Emma", lastName: "Davis", role: .patient, clinicId: "c1", assignedTherapistId: "t1", createdAt: Date(), isActive: true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDelegates()
        loadData()
    }
    
    // MARK: - UI Setup
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Create Assignment"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup header
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "Assign Exercise to Patient"
        headerLabel.font = .systemFont(ofSize: 24, weight: .bold)
        headerLabel.textAlignment = .center
        contentView.addSubview(headerLabel)
        
        // Setup components
        patientSelectorView.translatesAutoresizingMaskIntoConstraints = false
        exerciseSelectorView.translatesAutoresizingMaskIntoConstraints = false
        prescriptionView.translatesAutoresizingMaskIntoConstraints = false
        notesView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(patientSelectorView)
        contentView.addSubview(exerciseSelectorView)
        contentView.addSubview(prescriptionView)
        contentView.addSubview(notesView)
        
        // Setup assign button
        assignButton.translatesAutoresizingMaskIntoConstraints = false
        assignButton.setTitle("Create Assignment", for: .normal)
        assignButton.backgroundColor = .systemBlue
        assignButton.setTitleColor(.white, for: .normal)
        assignButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        assignButton.layer.cornerRadius = 12
        assignButton.isEnabled = false
        assignButton.alpha = 0.6
        assignButton.addTarget(self, action: #selector(assignButtonTapped), for: .touchUpInside)
        contentView.addSubview(assignButton)
        
        // Handle preselected patient
        if let preselectedPatient = preselectedPatient {
            // Update header to show specific patient
            headerLabel.text = "Assign Exercise to \(preselectedPatient.fullName)"
            
            // Configure patient selector for preselected patient
            configurePreselectedPatient(preselectedPatient)
            
            // Store the selected patient
            selectedPatient = preselectedPatient
            
            // Enable assign button if we have both patient and exercise
            updateAssignButtonState()
        }
      
    }

    // MARK: - Preselected Patient Configuration
    private func configurePreselectedPatient(_ patient: User) {
        // Hide the patient selector table completely
        patientSelectorView.subviews.forEach { $0.removeFromSuperview() }
        
        // Update the patient selector to show only the preselected patient
        patientSelectorView.backgroundColor = .systemBackground
        
        // Add a label to show this is the selected patient
        let selectedPatientLabel = UILabel()
        selectedPatientLabel.text = "Selected Patient:"
        selectedPatientLabel.font = .systemFont(ofSize: 16, weight: .medium)
        selectedPatientLabel.textColor = .secondaryLabel
        selectedPatientLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let patientCard = UIView()
        patientCard.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        patientCard.layer.cornerRadius = 12
        patientCard.layer.borderWidth = 2
        patientCard.layer.borderColor = UIColor.systemBlue.cgColor
        patientCard.translatesAutoresizingMaskIntoConstraints = false
        
        let patientNameLabel = UILabel()
        patientNameLabel.text = patient.fullName
        patientNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        patientNameLabel.textColor = .label
        patientNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let patientEmailLabel = UILabel()
        patientEmailLabel.text = patient.email
        patientEmailLabel.font = .systemFont(ofSize: 14)
        patientEmailLabel.textColor = .secondaryLabel
        patientEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmarkImageView.tintColor = .systemGreen
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let lockImageView = UIImageView(image: UIImage(systemName: "lock.fill"))
        lockImageView.tintColor = .systemGray
        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        
        patientSelectorView.addSubview(selectedPatientLabel)
        patientSelectorView.addSubview(patientCard)
        patientCard.addSubview(patientNameLabel)
        patientCard.addSubview(patientEmailLabel)
        patientCard.addSubview(checkmarkImageView)
        patientCard.addSubview(lockImageView)
        
        NSLayoutConstraint.activate([
            selectedPatientLabel.topAnchor.constraint(equalTo: patientSelectorView.topAnchor, constant: 16),
            selectedPatientLabel.leadingAnchor.constraint(equalTo: patientSelectorView.leadingAnchor, constant: 16),
            selectedPatientLabel.trailingAnchor.constraint(equalTo: patientSelectorView.trailingAnchor, constant: -16),
            
            patientCard.topAnchor.constraint(equalTo: selectedPatientLabel.bottomAnchor, constant: 12),
            patientCard.leadingAnchor.constraint(equalTo: patientSelectorView.leadingAnchor, constant: 16),
            patientCard.trailingAnchor.constraint(equalTo: patientSelectorView.trailingAnchor, constant: -16),
            patientCard.bottomAnchor.constraint(equalTo: patientSelectorView.bottomAnchor, constant: -16),
            patientCard.heightAnchor.constraint(equalToConstant: 80),
            
            patientNameLabel.topAnchor.constraint(equalTo: patientCard.topAnchor, constant: 12),
            patientNameLabel.leadingAnchor.constraint(equalTo: patientCard.leadingAnchor, constant: 16),
            patientNameLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -12),
            
            patientEmailLabel.topAnchor.constraint(equalTo: patientNameLabel.bottomAnchor, constant: 4),
            patientEmailLabel.leadingAnchor.constraint(equalTo: patientCard.leadingAnchor, constant: 16),
            patientEmailLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -12),
            patientEmailLabel.bottomAnchor.constraint(equalTo: patientCard.bottomAnchor, constant: -12),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: lockImageView.leadingAnchor, constant: -8),
            checkmarkImageView.centerYAnchor.constraint(equalTo: patientCard.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            lockImageView.trailingAnchor.constraint(equalTo: patientCard.trailingAnchor, constant: -16),
            lockImageView.centerYAnchor.constraint(equalTo: patientCard.centerYAnchor),
            lockImageView.widthAnchor.constraint(equalToConstant: 20),
            lockImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    // MARK: - Update Assign Button State
    private func updateAssignButtonState() {
        let hasPatient = selectedPatient != nil
        let hasExercise = selectedExercise != nil
        
        assignButton.isEnabled = hasPatient && hasExercise
        assignButton.alpha = (hasPatient && hasExercise) ? 1.0 : 0.6
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
            
            // Header
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Patient selector
            patientSelectorView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
            patientSelectorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            patientSelectorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Exercise selector
            exerciseSelectorView.topAnchor.constraint(equalTo: patientSelectorView.bottomAnchor, constant: 20),
            exerciseSelectorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            exerciseSelectorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Prescription details
            prescriptionView.topAnchor.constraint(equalTo: exerciseSelectorView.bottomAnchor, constant: 20),
            prescriptionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prescriptionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Notes
            notesView.topAnchor.constraint(equalTo: prescriptionView.bottomAnchor, constant: 20),
            notesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Assign button
            assignButton.topAnchor.constraint(equalTo: notesView.bottomAnchor, constant: 30),
            assignButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            assignButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            assignButton.heightAnchor.constraint(equalToConstant: 50),
            assignButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupDelegates() {
        patientSelectorView.delegate = self
        exerciseSelectorView.delegate = self
        prescriptionView.delegate = self
    }
    
    private func loadData() {
        patientSelectorView.configure(patients: mockPatients)
        exerciseSelectorView.configure(exercises: exerciseService.getAllExercises())
    }
    
    private func validateForm() {
        let isValid = selectedPatient != nil && selectedExercise != nil
        assignButton.isEnabled = isValid
        assignButton.alpha = isValid ? 1.0 : 0.6
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func assignButtonTapped() {
        guard let patient = selectedPatient,
              let exercise = selectedExercise else { return }
        
        let prescription = prescriptionView.getPrescriptionData()
        let notes = notesView.getNotes()
        
        let assignment = ExerciseAssignment(
            id: UUID().uuidString,
            patientId: patient.id,
            therapistId: AuthenticationService.shared.currentUser?.id ?? "therapist_1",
            exerciseId: exercise.id,
            prescribedReps: prescription.reps,
            prescribedDuration: TimeInterval(prescription.duration),
            frequencyPerWeek: prescription.frequency,
            startDate: prescription.startDate,
            endDate: prescription.endDate,
            notes: notes,
            priority: prescription.priority,
            isCompleted: false,
            createdAt: Date()
        )
        
        // Show loading
        assignButton.isEnabled = false
        assignButton.setTitle("Creating...", for: .normal)
        
        assignmentService.createAssignment(assignment) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.showSuccessAndDismiss(patientName: patient.fullName, exerciseName: exercise.name)
                } else {
                    self?.showError()
                    self?.assignButton.isEnabled = true
                    self?.assignButton.setTitle("Create Assignment", for: .normal)
                }
            }
        }
    }
    
    private func showSuccessAndDismiss(patientName: String, exerciseName: String) {
        let alert = UIAlertController(
            title: "Assignment Created!",
            message: "\(exerciseName) has been assigned to \(patientName)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to create assignment. Please try again.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Delegate Protocols

protocol PatientSelectorDelegate: AnyObject {
    func didSelectPatient(_ patient: User)
}

protocol ExerciseSelectorDelegate: AnyObject {
    func didSelectExercise(_ exercise: Exercise)
}

protocol PrescriptionDetailsDelegate: AnyObject {
    func prescriptionDidChange()
}

// MARK: - Delegate Extensions
extension ExerciseAssignmentViewController: PatientSelectorDelegate {
    func didSelectPatient(_ patient: User) {
        selectedPatient = patient
        validateForm()
    }
}

extension ExerciseAssignmentViewController: ExerciseSelectorDelegate {
    func didSelectExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        prescriptionView.updateForExercise(exercise)
        validateForm()
    }
}

extension ExerciseAssignmentViewController: PrescriptionDetailsDelegate {
    func prescriptionDidChange() {
        // Could add additional validation here if needed
    }
}

// MARK: - Component Views

class PatientSelectorView: UIView {
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private var patients: [User] = []
    private var selectedPatient: User?
    weak var delegate: PatientSelectorDelegate?
    
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
        titleLabel.text = "Select Patient"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        addSubview(titleLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PatientCell.self, forCellReuseIdentifier: "PatientCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configure(patients: [User]) {
        self.patients = patients
        tableView.reloadData()
    }
}

extension PatientSelectorView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as! PatientCell
        let patient = patients[indexPath.row]
        let isSelected = selectedPatient?.id == patient.id
        cell.configure(patient: patient, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPatient = patients[indexPath.row]
        delegate?.didSelectPatient(selectedPatient!)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

class PatientCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        contentView.addSubview(nameLabel)
        
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        detailLabel.textColor = .secondaryLabel
        contentView.addSubview(detailLabel)
        
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .systemBlue
        checkmarkImageView.isHidden = true
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -12),
            
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            detailLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -12),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(patient: User, isSelected: Bool) {
        nameLabel.text = patient.fullName
        detailLabel.text = patient.email
        checkmarkImageView.isHidden = !isSelected
        backgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.1) : .systemGray6
        layer.cornerRadius = 8
    }
}

class ExerciseSelectorView: UIView {
    private let titleLabel = UILabel()
    private let collectionView: UICollectionView
    private var exercises: [Exercise] = []
    private var selectedExercise: Exercise?
    weak var delegate: ExerciseSelectorDelegate?
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 120)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
        titleLabel.text = "Select Exercise"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        addSubview(titleLabel)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ExerciseCell.self, forCellWithReuseIdentifier: "ExerciseCell")
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    func configure(exercises: [Exercise]) {
        self.exercises = exercises
        collectionView.reloadData()
    }
}

extension ExerciseSelectorView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCell", for: indexPath) as! ExerciseCell
        let exercise = exercises[indexPath.item]
        let isSelected = selectedExercise?.id == exercise.id
        cell.configure(exercise: exercise, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedExercise = exercises[indexPath.item]
        delegate?.didSelectExercise(selectedExercise!)
        collectionView.reloadData()
    }
}

class ExerciseCell: UICollectionViewCell {
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let difficultyLabel = UILabel()
    
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
        layer.cornerRadius = 12
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "figure.strengthtraining.functional")
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        contentView.addSubview(nameLabel)
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = .systemFont(ofSize: 12, weight: .medium)
        categoryLabel.textColor = .secondaryLabel
        categoryLabel.textAlignment = .center
        contentView.addSubview(categoryLabel)
        
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyLabel.font = .systemFont(ofSize: 10, weight: .medium)
        difficultyLabel.textAlignment = .center
        difficultyLabel.layer.cornerRadius = 8
        difficultyLabel.clipsToBounds = true
        contentView.addSubview(difficultyLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            difficultyLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            difficultyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            difficultyLabel.widthAnchor.constraint(equalToConstant: 60),
            difficultyLabel.heightAnchor.constraint(equalToConstant: 16),
            difficultyLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(exercise: Exercise, isSelected: Bool) {
        nameLabel.text = exercise.name
        categoryLabel.text = exercise.category.displayName
        difficultyLabel.text = exercise.difficulty.displayName
        
        // Style based on difficulty
        switch exercise.difficulty {
        case .beginner:
            difficultyLabel.backgroundColor = .systemGreen
            difficultyLabel.textColor = .white
        case .intermediate:
            difficultyLabel.backgroundColor = .systemOrange
            difficultyLabel.textColor = .white
        case .advanced:
            difficultyLabel.backgroundColor = .systemRed
            difficultyLabel.textColor = .white
        }
        
        // Style based on selection
        if isSelected {
            backgroundColor = .systemBlue.withAlphaComponent(0.2)
            layer.borderWidth = 2
            layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            backgroundColor = .systemGray6
            layer.borderWidth = 0
        }
    }
}

class PrescriptionDetailsView: UIView {
    private let titleLabel = UILabel()
    private let repsSlider = UISlider()
    private let repsLabel = UILabel()
    private let durationSlider = UISlider()
    private let durationLabel = UILabel()
    private let frequencySegmentedControl = UISegmentedControl(items: ["2x/week", "3x/week", "4x/week", "5x/week"])
    private let frequencyLabel = UILabel()
    private let prioritySegmentedControl = UISegmentedControl(items: ["Low", "Medium", "High"])
    private let priorityLabel = UILabel()
    private let dateStackView = UIStackView()
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    
    weak var delegate: PrescriptionDetailsDelegate?
    
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
        titleLabel.text = "Prescription Details"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        addSubview(titleLabel)
        
        // Reps
        repsLabel.translatesAutoresizingMaskIntoConstraints = false
        repsLabel.text = "Repetitions: 10"
        repsLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(repsLabel)
        
        repsSlider.translatesAutoresizingMaskIntoConstraints = false
        repsSlider.minimumValue = 5
        repsSlider.maximumValue = 30
        repsSlider.value = 10
        repsSlider.addTarget(self, action: #selector(repsChanged), for: .valueChanged)
        addSubview(repsSlider)
        
        // Duration
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = "Duration: 60 seconds"
        durationLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(durationLabel)
        
        durationSlider.translatesAutoresizingMaskIntoConstraints = false
        durationSlider.minimumValue = 30
        durationSlider.maximumValue = 300
        durationSlider.value = 60
        durationSlider.addTarget(self, action: #selector(durationChanged), for: .valueChanged)
        addSubview(durationSlider)
        
        // Frequency
        frequencyLabel.translatesAutoresizingMaskIntoConstraints = false
        frequencyLabel.text = "Frequency per week:"
        frequencyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(frequencyLabel)
        
        frequencySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        frequencySegmentedControl.selectedSegmentIndex = 1 // 3x/week default
        addSubview(frequencySegmentedControl)
        
        // Priority
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityLabel.text = "Priority:"
        priorityLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(priorityLabel)
        
        prioritySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        prioritySegmentedControl.selectedSegmentIndex = 1 // Medium default
        addSubview(prioritySegmentedControl)
        
        // Date pickers
        dateStackView.translatesAutoresizingMaskIntoConstraints = false
        dateStackView.axis = .horizontal
        dateStackView.distribution = .fillEqually
        dateStackView.spacing = 16
        addSubview(dateStackView)
        
        let startDateContainer = createDatePickerContainer(title: "Start Date", datePicker: startDatePicker)
        let endDateContainer = createDatePickerContainer(title: "End Date", datePicker: endDatePicker)
        
        dateStackView.addArrangedSubview(startDateContainer)
        dateStackView.addArrangedSubview(endDateContainer)
        
        // Configure date pickers
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.date = Date()
        
        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            repsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            repsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            repsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            repsSlider.topAnchor.constraint(equalTo: repsLabel.bottomAnchor, constant: 8),
            repsSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            repsSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            durationLabel.topAnchor.constraint(equalTo: repsSlider.bottomAnchor, constant: 20),
            durationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            durationSlider.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            durationSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            durationSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            frequencyLabel.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 20),
            frequencyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            frequencySegmentedControl.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor, constant: 8),
            frequencySegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            frequencySegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            priorityLabel.topAnchor.constraint(equalTo: frequencySegmentedControl.bottomAnchor, constant: 20),
            priorityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            prioritySegmentedControl.topAnchor.constraint(equalTo: priorityLabel.bottomAnchor, constant: 8),
            prioritySegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            prioritySegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            dateStackView.topAnchor.constraint(equalTo: prioritySegmentedControl.bottomAnchor, constant: 20),
            dateStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dateStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dateStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func createDatePickerContainer(title: String, datePicker: UIDatePicker) -> UIView {
        let container = UIView()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .medium)
        container.addSubview(label)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            datePicker.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    @objc private func repsChanged() {
        let value = Int(repsSlider.value)
        repsLabel.text = "Repetitions: \(value)"
        delegate?.prescriptionDidChange()
    }
    
    @objc private func durationChanged() {
        let value = Int(durationSlider.value)
        durationLabel.text = "Duration: \(value) seconds"
        delegate?.prescriptionDidChange()
    }
    
    func updateForExercise(_ exercise: Exercise) {
        repsSlider.value = Float(exercise.defaultReps)
        durationSlider.value = Float(exercise.defaultDuration)
        repsChanged()
        durationChanged()
    }
    
    func getPrescriptionData() -> (reps: Int, duration: Int, frequency: Int, priority: AssignmentPriority, startDate: Date, endDate: Date) {
        let priorities: [AssignmentPriority] = [.low, .medium, .high]
        return (
            reps: Int(repsSlider.value),
            duration: Int(durationSlider.value),
            frequency: frequencySegmentedControl.selectedSegmentIndex + 2, // 2-5 times per week
            priority: priorities[prioritySegmentedControl.selectedSegmentIndex],
            startDate: startDatePicker.date,
            endDate: endDatePicker.date
        )
    }
}

class NotesView: UIView {
    private let titleLabel = UILabel()
    private let textView = UITextView()
    
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
        titleLabel.text = "Notes (Optional)"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        addSubview(titleLabel)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.text = "Add any special instructions or notes for the patient..."
        textView.textColor = .placeholderText
        textView.delegate = self
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func getNotes() -> String {
        return textView.textColor == .placeholderText ? "" : textView.text
    }
}

extension NotesView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add any special instructions or notes for the patient..."
            textView.textColor = .placeholderText
        }
    }
}
