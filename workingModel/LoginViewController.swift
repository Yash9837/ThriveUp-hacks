import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    // MARK: - UI Elements
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["User", "Organiser"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        control.selectedSegmentTintColor = .white
        control.layer.cornerRadius = 15
        control.layer.masksToBounds = true
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemOrange
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loginTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "User Login"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter with your SRM credentials"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userIDTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemOrange.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemOrange.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Card View for the loading spinner
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true // Initially hidden
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .systemOrange
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var isUserSelected = true // Track whether "User" or "Host" is selected
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.addSubview(segmentedControl)
        view.addSubview(profileImageView)
        view.addSubview(loginTitleLabel)
        view.addSubview(loginSubtitleLabel)
        view.addSubview(userIDTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(cardView) // Add the card view behind the spinner
        cardView.addSubview(activityIndicator) // Add activity indicator inside the card view
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 250),
            
            profileImageView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 32),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            loginTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            loginTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loginSubtitleLabel.topAnchor.constraint(equalTo: loginTitleLabel.bottomAnchor, constant: 8),
            loginSubtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            userIDTextField.topAnchor.constraint(equalTo: loginSubtitleLabel.bottomAnchor, constant: 32),
            userIDTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            userIDTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            passwordTextField.topAnchor.constraint(equalTo: userIDTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Card View (Loading Spinner Background) Constraints
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 200),
            cardView.heightAnchor.constraint(equalToConstant: 150),
            
            // Activity Indicator inside Card
            activityIndicator.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        ])
    }
    
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        isUserSelected = segmentedControl.selectedSegmentIndex == 0
        updateLoginPrompt()
    }
    
    private func updateLoginPrompt() {
        loginTitleLabel.text = isUserSelected ? "User Login" : "Organiser Login"
        
        // Change profile image based on selection
        if isUserSelected {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        } else {
            profileImageView.image = UIImage(systemName: "person.3.fill")
        }
    }
    
    @objc private func handleLogin() {
        guard let email = userIDTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter a valid email and password.")
            return
        }
        
        // Show the card with the activity indicator when login starts
        cardView.isHidden = false
        activityIndicator.startAnimating()
        
        let alert = UIAlertController(title: "Confirm Login", message: "You are logging in as \(isUserSelected ? "User" : "Organiser")", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { [weak self] _ in
            self?.performLogin(email: email, password: password)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func performLogin(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            // Stop the activity indicator once login finishes
            self?.cardView.isHidden = true
            self?.activityIndicator.stopAnimating()
            
            if let error = error {
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }
            
            if let user = result?.user {
                // Add user to Firestore Users collection
                self?.addUserToFirestore(uid: user.uid, email: email)
                
                if self?.isUserSelected == true {
                    self?.navigateToUserTabBar()
                } else {
                    self?.navigateToOrganizerTabBar()
                }
            }
        }
    }
    
    // MARK: - Firestore Methods
    private func addUserToFirestore(uid: String, email: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { [weak self] document, error in
            if let document = document, document.exists {
                // User document already exists, no need to create it
                return
            } else {
                // Create user document with email, uid, and userType
                let userType = self?.isUserSelected == true ? "user" : "host"
                userRef.setData([
                    "email": email,
                    "uid": uid,
                    "userType": userType,
                    "Description": "Enter Description",
                    "profileImageURL": "",
                    "ContactDetails": "Enter Contact",
                    "name": "Enter Name"
                ]) { error in
                    if let error = error {
                        self?.showAlert(title: "Error", message: "Failed to create user document: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation Methods
    private func navigateToUserTabBar() {
        let userTabBar = UserTabBarController()
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = userTabBar
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
    private func navigateToOrganizerTabBar() {
        let organizerTabBar = OrganizerTabBar()
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = organizerTabBar
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


#Preview{
    LoginViewController()
}
