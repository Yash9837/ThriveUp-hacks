import UIKit
import FirebaseFirestore

class EventRegistrationViewController: UIViewController {

    var event: EventModel? // Pass the selected event to this view

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your name"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your email"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private let chatManager = FirestoreChatManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Register for \(event?.title ?? "Event")"

        setupUI()
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }

    private func setupUI() {
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(registerButton)

        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            registerButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func registerButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please fill all fields.")
            return
        }

        registerForEvent(name: name, email: email)
    }

    private func registerForEvent(name: String, email: String) {
        guard let eventId = event?.eventId else {
            showAlert(title: "Error", message: "Event ID is missing.")
            return
        }

        let db = Firestore.firestore()
        let registrationData: [String: Any] = [
            "userName": name,
            "userEmail": email,
            "registrationTime": Timestamp()
        ]

        db.collection("events")
            .document(eventId)
            .collection("registrations")
            .addDocument(data: registrationData) { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to register: \(error.localizedDescription)")
                } else {
                    self?.showAlert(title: "Success", message: "You have successfully registered!")
                    // Notify friends about the event registration
                    if let eventName = self?.event?.title {
                        self?.chatManager.notifyFriendsForEventRegistration(eventName: eventName)
                    }
                }
            }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
