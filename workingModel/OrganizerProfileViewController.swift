//
//  OrganizerProfileViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 19/11/24.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class OrganizerProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    private var createdEvents: [EventModel] = []
    private let db = Firestore.firestore()

    // MARK: - UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfileImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.systemOrange.cgColor
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Organizer Name"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "organizer@example.com"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()

    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Details", "Events"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = UIColor.orange
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()

    private let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "About"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()

    private let aboutDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "This is the organizer description."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()

    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()

    private let eventsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureNavigationBar()
        fetchOrganizerData()
        fetchCreatedEvents()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(segmentControl)
        view.addSubview(aboutLabel)
        view.addSubview(aboutDescriptionLabel)
        view.addSubview(detailsStackView)
        view.addSubview(eventsTableView)

        // Add detail views
        let eventsCountView = createDetailView(title: "Number of Events", value: "0")
        let contactView = createDetailView(title: "Contact", value: "-")
        let pocView = createDetailView(title: "Person of Contact", value: "-")
        [eventsCountView, contactView, pocView].forEach { detailsStackView.addArrangedSubview($0) }

        eventsTableView.dataSource = self
        eventsTableView.delegate = self
    }

    private func setupConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        eventsTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            segmentControl.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            aboutLabel.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            aboutLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            aboutDescriptionLabel.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 8),
            aboutDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            aboutDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            detailsStackView.topAnchor.constraint(equalTo: aboutDescriptionLabel.bottomAnchor, constant: 20),
            detailsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            eventsTableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            eventsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eventsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func createDetailView(title: String, value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .orange

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.textColor = .gray

        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }

    // MARK: - Navigation Bar
    private func configureNavigationBar() {
        navigationItem.title = "Organizer Profile"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        
        // Create Edit button
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEdit))
        
        // Create Logout button
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        // Set the buttons in order: Edit first, then Logout
        navigationItem.leftBarButtonItem = editButton
        navigationItem.rightBarButtonItem = logoutButton
    }


    @objc private func handleEdit() {
        let editVC = EditOrganizerViewController()
        editVC.name = nameLabel.text
        editVC.descriptionText = aboutDescriptionLabel.text
        editVC.contact = (detailsStackView.arrangedSubviews[1].subviews.last as? UILabel)?.text
        editVC.poc = (detailsStackView.arrangedSubviews[2].subviews.last as? UILabel)?.text
        editVC.imageUrl = "Current image URL if available" // Pass the current image URL

        editVC.onSave = { [weak self] updatedDetails in
            self?.updateProfile(with: updatedDetails)
        }

        navigationController?.pushViewController(editVC, animated: true)
    }

    private func updateProfile(with details: OrganizerDetails) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found.")
            return
        }

        let data: [String: Any] = [
            "name": details.name,
            "Description": details.description,
            "ContactDetails": details.contact,
            "POC": details.poc,
            "profileImageURL": details.imageUrl // Save the new image URL
        ]

        db.collection("users").document(userId).updateData(data) { error in
            if let error = error {
                print("Failed to update profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully.")
                self.fetchOrganizerData() // Refresh UI with updated data
            }
        }
    }




    private func saveProfileData(userId: String, data: [String: Any]) {
        db.collection("users").document(userId).updateData(data) { [weak self] error in
            guard error == nil else { return }
            self?.fetchOrganizerData()
        }
    }
    
    @objc private func handleLogout() {
        do {
            try Auth.auth().signOut()
            let loginVC = GeneralTabbarController()
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = loginVC
                sceneDelegate.window?.makeKeyAndVisible()
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

// MARK: - Fetch Organizer Data
    private func fetchOrganizerData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self, let data = document?.data(), error == nil else { return }

            self.nameLabel.text = data["name"] as? String ?? "Organizer Name"
            self.emailLabel.text = data["email"] as? String ?? "Email"
            self.aboutDescriptionLabel.text = data["Description"] as? String ?? "No description provided."

            if let contact = data["ContactDetails"] as? String,
               let contactLabel = self.detailsStackView.arrangedSubviews[1].subviews.last as? UILabel {
                contactLabel.text = contact
            }

            if let poc = data["POC"] as? String,
               let pocLabel = self.detailsStackView.arrangedSubviews[2].subviews.last as? UILabel {
                pocLabel.text = poc
            }

            if let profileImageURLString = data["profileImageURL"] as? String,
               let profileImageURL = URL(string: profileImageURLString) {
                self.loadProfileImage(from: profileImageURL)
            }
        }
    }

    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }

    // MARK: - Fetch Created Events
    private func fetchCreatedEvents() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("events").whereField("uid", isEqualTo: userId).getDocuments { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents, error == nil else { return }

            self.createdEvents = documents.map { doc in
                let data = doc.data()
                return EventModel(
                                eventId: doc.documentID,
                                title: data["title"] as? String ?? "Untitled Event",
                                category: data["category"] as? String ?? "Uncategorized",
                                attendanceCount: data["attendanceCount"] as? Int ?? 0,
                                organizerName: data["organizerName"] as? String ?? "Unknown Organizer",
                                date: data["date"] as? String ?? "Unknown Date",
                                time: data["time"] as? String ?? "Unknown Time",
                                location: data["location"] as? String ?? "Unknown Location",
                                locationDetails: data["locationDetails"] as? String ?? "",
                                imageName: data["imageName"] as? String ?? "",
                                speakers: [],
                                userId : "",
                                
                                description: data["description"] as? String ?? "",
                                tags: []
                            )
            }

            if let eventsCountLabel = self.detailsStackView.arrangedSubviews[0].subviews.last as? UILabel {
                eventsCountLabel.text = "\(self.createdEvents.count)"
            }

            DispatchQueue.main.async {
                self.eventsTableView.reloadData()
            }
        }
    }

       // MARK: - UITableView DataSource
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return createdEvents.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier, for: indexPath) as! EventTableViewCell
           cell.configure(with: createdEvents[indexPath.row])
           return cell
       }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let selectedEvent = createdEvents[indexPath.row]
           let registrationsListVC = RegistrationListViewController(eventId: selectedEvent.eventId)
           navigationController?.pushViewController(registrationsListVC, animated: true)
       }

       @objc private func segmentChanged() {
           let isEventsSelected = segmentControl.selectedSegmentIndex == 1
           aboutLabel.isHidden = isEventsSelected
           aboutDescriptionLabel.isHidden = isEventsSelected
           detailsStackView.isHidden = isEventsSelected
           eventsTableView.isHidden = !isEventsSelected
       }
   }


class EventTableViewCell: UITableViewCell {

    static let identifier = "EventTableViewCell"

    private let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(eventImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            eventImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            eventImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            eventImageView.widthAnchor.constraint(equalToConstant: 60),
            eventImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: eventImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: eventImageView.trailingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with event: EventModel) {
        titleLabel.text = event.title
        dateLabel.text = "\(event.date) at \(event.time)"

        if let imageUrl = URL(string: event.imageName ?? "") {
            loadImage(from: imageUrl)
        } else {
            eventImageView.image = UIImage(named: "placeholderImage")
        }
    }

    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.eventImageView.image = UIImage(data: data)
                }
            }
        }
    }
}

class EditOrganizerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Your existing code

    // MARK: - Properties
    var name: String?
    var descriptionText: String?
    var contact: String?
    var poc: String?
    var imageUrl: String?
    var onSave: ((OrganizerDetails) -> Void)?

    // MARK: - UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfileImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()

    private let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Image", for: .normal)
        button.addTarget(self, action: #selector(handleSelectImage), for: .touchUpInside)
        return button
    }()


    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter name"
        return textField
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()

    private let contactTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter contact"
        return textField
    }()

    private let pocTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter Person of Contact"
        return textField
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        populateFields()
    }

    // MARK: - Setup UI
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(profileImageView)
        view.addSubview(selectImageButton)
        view.addSubview(nameTextField)
        view.addSubview(descriptionTextView)
        view.addSubview(contactTextField)
        view.addSubview(pocTextField)
        view.addSubview(saveButton)
    }


    private func setupConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        selectImageButton.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        contactTextField.translatesAutoresizingMaskIntoConstraints = false
        pocTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            selectImageButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameTextField.topAnchor.constraint(equalTo: selectImageButton.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),

            contactTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            contactTextField.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            contactTextField.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),

            pocTextField.topAnchor.constraint(equalTo: contactTextField.bottomAnchor, constant: 20),
            pocTextField.leadingAnchor.constraint(equalTo: contactTextField.leadingAnchor),
            pocTextField.trailingAnchor.constraint(equalTo: contactTextField.trailingAnchor),

            saveButton.topAnchor.constraint(equalTo: pocTextField.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: pocTextField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: pocTextField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func handleSelectImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
        }
    }

    private func populateFields() {
        if let imageUrlString = imageUrl, let url = URL(string: imageUrlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                }
            }.resume()
        }
        nameTextField.text = name
        descriptionTextView.text = descriptionText
        contactTextField.text = contact
        pocTextField.text = poc
    }


    // MARK: - Actions
    @objc private func handleSave() {
        guard let updatedName = nameTextField.text,
              let updatedDescription = descriptionTextView.text,
              let updatedContact = contactTextField.text,
              let updatedPOC = pocTextField.text,
              let profileImage = profileImageView.image,
              let imageData = profileImage.jpegData(compressionQuality: 0.8) else {
            return
        }

        // Upload image to Firebase Storage
        let storageRef = Storage.storage().reference().child("profile_images/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard error == nil else {
                print("Failed to upload image: \(error!.localizedDescription)")
                return
            }

            // Get download URL
            storageRef.downloadURL { url, error in
                guard let url = url, error == nil else {
                    print("Failed to fetch download URL: \(error!.localizedDescription)")
                    return
                }

                // Pass updated details with image URL
                let updatedDetails = OrganizerDetails(
                    name: updatedName,
                    description: updatedDescription,
                    contact: updatedContact,
                    poc: updatedPOC,
                    imageUrl: url.absoluteString
                )

                self?.onSave?(updatedDetails)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

}

// MARK: - OrganizerDetails Model
struct OrganizerDetails {
    let name: String
    let description: String
    let contact: String
    let poc: String
    let imageUrl: String
}
