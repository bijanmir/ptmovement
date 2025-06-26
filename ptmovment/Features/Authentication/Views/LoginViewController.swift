import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    
    private let loginButton = UIButton(type: .system)
    private let signupButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup logo
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(systemName: "figure.strengthtraining.functional")
        logoImageView.tintColor = .systemBlue
        logoImageView.contentMode = .scaleAspectFit
        contentView.addSubview(logoImageView)
        
        // Setup title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "PT Movement"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // Setup subtitle
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "AI-Powered Physical Therapy"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        contentView.addSubview(subtitleLabel)
        
        // Setup email field
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.font = .systemFont(ofSize: 16)
        contentView.addSubview(emailTextField)
        
        // Setup password field
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.font = .systemFont(ofSize: 16)
        contentView.addSubview(passwordTextField)
        
        // Setup login button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Sign In", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        loginButton.layer.cornerRadius = 12
        loginButton.layer.shadowColor = UIColor.systemBlue.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        loginButton.layer.shadowOpacity = 0.3
        loginButton.layer.shadowRadius = 4
        contentView.addSubview(loginButton)
        
        // Setup signup button
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.setTitle("Don't have an account? Sign Up", for: .normal)
        signupButton.setTitleColor(.systemBlue, for: .normal)
        signupButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(signupButton)
        
        // Setup forgot password button
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.setTitleColor(.systemBlue, for: .normal)
        forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        contentView.addSubview(forgotPasswordButton)
        
        // Setup loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        // Add demo account hints
        addDemoAccountHints()
    }
    
    private func addDemoAccountHints() {
        let demoLabel = UILabel()
        demoLabel.translatesAutoresizingMaskIntoConstraints = false
        demoLabel.text = "Demo Accounts:\nPT: pt@demo.com / password\nPatient: patient@demo.com / password"
        demoLabel.font = .systemFont(ofSize: 12, weight: .regular)
        demoLabel.textColor = .tertiaryLabel
        demoLabel.textAlignment = .center
        demoLabel.numberOfLines = 0
        contentView.addSubview(demoLabel)
        
        NSLayoutConstraint.activate([
            demoLabel.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 40),
            demoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            demoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
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
            
            // Logo
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Email field
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Login button
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Forgot password button
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Signup button
            signupButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 100),
            signupButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signupButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter both email and password")
            return
        }
        
        loadingIndicator.startAnimating()
        loginButton.isEnabled = false
        
        authService.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.loginButton.isEnabled = true
                
                switch result {
                case .success(let user):
                    self?.handleSuccessfulLogin(user: user)
                case .failure(let error):
                    self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func signupButtonTapped() {
        let signupVC = SignUpViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @objc private func forgotPasswordTapped() {
        showAlert(title: "Forgot Password", message: "Password reset functionality will be implemented in a future update.")
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    private func handleSuccessfulLogin(user: User) {
        // Navigate based on user role
        switch user.role {
        case .physicalTherapist, .clinicAdmin:
            navigateToPTDashboard()
        case .patient:
            navigateToPatientDashboard()
        }
    }
    
    private func navigateToPTDashboard() {
        let ptDashboard = PTDashboardViewController()
        let navController = UINavigationController(rootViewController: ptDashboard)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func navigateToPatientDashboard() {
        let patientDashboard = PatientDashboardViewController()
        let navController = UINavigationController(rootViewController: patientDashboard)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
