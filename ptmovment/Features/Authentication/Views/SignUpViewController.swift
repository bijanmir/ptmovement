import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let firstNameTextField = UITextField()
    private let lastNameTextField = UITextField()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    
    private let roleSegmentedControl = UISegmentedControl(items: ["Patient", "Physical Therapist"])
    private let roleLabel = UILabel()
    
    private let signupButton = UIButton(type: .system)
    private let loginButton = UIButton(type: .system)
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    private let authService = AuthenticationService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        title = "Create Account"
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Join PT Movement"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // Setup subtitle
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Create your account to get started"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        contentView.addSubview(subtitleLabel)
        
        // Setup text fields
        setupTextField(firstNameTextField, placeholder: "First Name")
        setupTextField(lastNameTextField, placeholder: "Last Name")
        setupTextField(emailTextField, placeholder: "Email")
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        setupTextField(passwordTextField, placeholder: "Password")
        passwordTextField.isSecureTextEntry = true
        
        setupTextField(confirmPasswordTextField, placeholder: "Confirm Password")
        confirmPasswordTextField.isSecureTextEntry = true
        
        contentView.addSubview(firstNameTextField)
        contentView.addSubview(lastNameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(confirmPasswordTextField)
        
        // Setup role selection
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        roleLabel.text = "I am a:"
        roleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        roleLabel.textColor = .label
        contentView.addSubview(roleLabel)
        
        roleSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        roleSegmentedControl.selectedSegmentIndex = 0 // Default to patient
        roleSegmentedControl.backgroundColor = .systemGray6
        contentView.addSubview(roleSegmentedControl)
        
        // Setup signup button
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.setTitle("Create Account", for: .normal)
        signupButton.backgroundColor = .systemBlue
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        signupButton.layer.cornerRadius = 12
        signupButton.layer.shadowColor = UIColor.systemBlue.cgColor
        signupButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        signupButton.layer.shadowOpacity = 0.3
        signupButton.layer.shadowRadius = 4
        contentView.addSubview(signupButton)
        
        // Setup login button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Already have an account? Sign In", for: .normal)
        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(loginButton)
        
        // Setup loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
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
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // First name field
            firstNameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            firstNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            firstNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            firstNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Last name field
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 16),
            lastNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lastNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            lastNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Email field
            emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Confirm password field
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Role label
            roleLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            roleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // Role segmented control
            roleSegmentedControl.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 12),
            roleSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            roleSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            roleSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            // Signup button
            signupButton.topAnchor.constraint(equalTo: roleSegmentedControl.bottomAnchor, constant: 40),
            signupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            signupButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Login button
            loginButton.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func signupButtonTapped() {
        guard validateInputs() else { return }
        
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let role: UserRole = roleSegmentedControl.selectedSegmentIndex == 0 ? .patient : .physicalTherapist
        
        loadingIndicator.startAnimating()
        signupButton.isEnabled = false
        
        authService.createAccount(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            role: role
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.signupButton.isEnabled = true
                
                switch result {
                case .success(let user):
                    self?.handleSuccessfulSignup(user: user)
                case .failure(let error):
                    self?.showAlert(title: "Signup Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func loginButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Validation
    private func validateInputs() -> Bool {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
            showAlert(title: "Error", message: "Please enter your first name")
            return false
        }
        
        guard let lastName = lastNameTextField.text, !lastName.isEmpty else {
            showAlert(title: "Error", message: "Please enter your last name")
            return false
        }
        
        guard let email = emailTextField.text, !email.isEmpty, email.contains("@") else {
            showAlert(title: "Error", message: "Please enter a valid email address")
            return false
        }
        
        guard let password = passwordTextField.text, password.count >= 6 else {
            showAlert(title: "Error", message: "Password must be at least 6 characters long")
            return false
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, password == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match")
            return false
        }
        
        return true
    }
    
    // MARK: - Navigation
    private func handleSuccessfulSignup(user: User) {
        // Show success and navigate to appropriate dashboard
        let alert = UIAlertController(
            title: "Account Created!",
            message: "Welcome to PT Movement, \(user.firstName)!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Get Started", style: .default) { [weak self] _ in
            switch user.role {
            case .physicalTherapist, .clinicAdmin:
                self?.navigateToPTDashboard()
            case .patient:
                self?.navigateToPatientDashboard()
            }
        })
        
        present(alert, animated: true)
    }
    
    private func navigateToPTDashboard() {
        let ptDashboard = PTDashboardViewController()
        let navController = UINavigationController(rootViewController: ptDashboard)
        navController.modalPresentationStyle = .fullScreen
        view.window?.rootViewController = navController
    }
    
    private func navigateToPatientDashboard() {
        let patientDashboard = PatientDashboardViewController()
        let navController = UINavigationController(rootViewController: patientDashboard)
        navController.modalPresentationStyle = .fullScreen
        view.window?.rootViewController = navController
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
