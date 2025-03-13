import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RegisteredEventCellDelegate {
    
    // MARK: - Properties
    private var registeredEvents: [EventModel] = [] // Stores registered events
    private var userInterests: [String] = [] // Stores user interests
    private let db = Firestore.firestore()
    
    // UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default_profile")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .black
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()
    
    private let friendsLabel: UILabel = {
        let label = UILabel()
                label.text = "Friends: 0"
                label.font = UIFont.systemFont(ofSize: 18)
                label.textColor = .darkGray
                label.isUserInteractionEnabled = true // Enable tap
                return label
    }()
    
    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Details", "Events"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = UIColor.orange
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()
    
    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description: Not Available"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let contactDetailsLabel: UILabel = {
        let label = UILabel()
        label.text = "Contact: Not Available"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let githubLabel: UILabel = {
        let label = UILabel()
        label.text = "GitHub: Not Available"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let linkedinLabel: UILabel = {
        let label = UILabel()
        label.text = "LinkedIn: Not Available"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let techStackLabel: UILabel = {
        let label = UILabel()
        label.text = "Tech Stack: Not Available"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let interestsView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let interestsLabel: UILabel = {
        let label = UILabel()
        label.text = "Interests"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    private let interestsGridView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let eventsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RegisteredEventCell.self, forCellReuseIdentifier: RegisteredEventCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Configure Navigation Bar
    private func configureNavigationBar() {
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEdit))
        
        navigationItem.rightBarButtonItem = logoutButton
        navigationItem.leftBarButtonItem = editButton
    }
    
    @objc private func handleEdit() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        // Fetch user document from Firestore
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let profileImageUrl = document.data()?["profileImageURL"] as? String else {
                print("No valid profile image URL found.")
                return
            }
            
            let editVC = EditProfileViewController()
            editVC.name = self.nameLabel.text
            editVC.descriptionText = self.descriptionLabel.text?.replacingOccurrences(of: "Description: ", with: "")
            editVC.contact = self.contactDetailsLabel.text?.replacingOccurrences(of: "Contact: ", with: "")
            editVC.githubUrl = document.data()?["githubUrl"] as? String
            editVC.linkedinUrl = document.data()?["linkedinUrl"] as? String
            editVC.techStack = document.data()?["techStack"] as? String
            editVC.imageUrl = profileImageUrl
            
            editVC.onSave = { [weak self] updatedDetails in
                self?.updateProfile(with: updatedDetails)
            }
            
            self.navigationController?.pushViewController(editVC, animated: true)
        }
    }
    
    private func updateProfile(with details: UserDetails) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "name": details.name,
            "Description": details.description,
            "ContactDetails": details.contact ?? "",
            "profileImageURL": details.imageUrl,
            "githubUrl": details.githubUrl ?? "",
            "linkedinUrl": details.linkedinUrl ?? "",
            "techStack": details.techStack
        ]
        
        db.collection("users").document(userId).updateData(data) { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                self.nameLabel.text = details.name
                self.descriptionLabel.text = "Description: \(details.description)"
                self.contactDetailsLabel.text = "Contact: \(details.contact ?? "Not Available")"
                self.githubLabel.text = "GitHub: \(details.githubUrl ?? "Not Available")"
                self.linkedinLabel.text = "LinkedIn: \(details.linkedinUrl ?? "Not Available")"
                self.techStackLabel.text = "Tech Stack: \(details.techStack)"
                
                if let url = URL(string: details.imageUrl) {
                    self.loadProfileImage(from: url)
                } else {
                    print("Invalid image URL: \(details.imageUrl)")
                }
            }
        }
    }
    
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true)
    }
    
    // MARK: - Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard
            let editedImage = info[.editedImage] as? UIImage,
            let userId = Auth.auth().currentUser?.uid
        else { return }
        
        uploadProfileImage(editedImage, for: userId) { imageURL in
            self.db.collection("users").document(userId).updateData(["profileImageURL": imageURL]) { error in
                if let error = error {
                    print("Error updating image URL: \(error.localizedDescription)")
                } else {
                    self.profileImageView.image = editedImage
                }
            }
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, for userId: String, completion: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                } else if let url = url {
                    completion(url.absoluteString)
                }
            }
        }
    }
    
    @objc private func handleLogout() {
        let userTabBarController = GeneralTabbarController()
        
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = userTabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - UI Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupUI()
        setupConstraints()
        loadUserDetails()
        loadUserInterests()
        loadRegisteredEvents()
        fetchFriendsCount()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFriendCount), name: NSNotification.Name("FriendCountUpdated"), object: nil)

    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(friendsLabel)
        view.addSubview(segmentControl)
        view.addSubview(detailsStackView)
        view.addSubview(eventsTableView)
        
        detailsStackView.addArrangedSubview(descriptionLabel)
        detailsStackView.addArrangedSubview(contactDetailsLabel)
        detailsStackView.addArrangedSubview(githubLabel)
        detailsStackView.addArrangedSubview(linkedinLabel)
        detailsStackView.addArrangedSubview(techStackLabel)
        detailsStackView.addArrangedSubview(interestsView)
        
        interestsView.addSubview(interestsLabel)
        interestsView.addSubview(interestsGridView)
        
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
        
        // Add long-press gesture to show interests in a pop-up
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showInterestsPopup))
        interestsView.addGestureRecognizer(longPressGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFriendsLabel))
            friendsLabel.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        friendsLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        interestsView.translatesAutoresizingMaskIntoConstraints = false
        interestsLabel.translatesAutoresizingMaskIntoConstraints = false
        interestsGridView.translatesAutoresizingMaskIntoConstraints = false
        eventsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleStackView.heightAnchor.constraint(equalToConstant: 40),
            
            profileImageView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            friendsLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            friendsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            friendsLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            segmentControl.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            detailsStackView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            detailsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            interestsLabel.topAnchor.constraint(equalTo: interestsView.topAnchor),
            interestsLabel.leadingAnchor.constraint(equalTo: interestsView.leadingAnchor),
            
            interestsGridView.topAnchor.constraint(equalTo: interestsLabel.bottomAnchor, constant: 8),
            interestsGridView.leadingAnchor.constraint(equalTo: interestsView.leadingAnchor),
            interestsGridView.trailingAnchor.constraint(equalTo: interestsView.trailingAnchor),
            interestsGridView.bottomAnchor.constraint(equalTo: interestsView.bottomAnchor),
            
            eventsTableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            eventsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eventsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFriendsLabel))
                friendsLabel.addGestureRecognizer(tapGesture)
    }
    private func fetchFriendsCount() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("friends")
            .whereField("userID", isEqualTo: userId) // Fetch friends connected to the user
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching friends count: \(error.localizedDescription)")
                    return
                }

                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.friendsLabel.text = "Friends: \(count)"
                }
            }
    }

    @objc private func didTapFriendsLabel() {
        let friendsVC = FriendsViewController()
        friendsVC.currentUser = User(id: Auth.auth().currentUser?.uid ?? "", name: nameLabel.text ?? "Unknown")
        navigationController?.pushViewController(friendsVC, animated: true)
    }
    @objc private func updateFriendCount() {
        fetchFriendsCount()
    }


    @objc private func showInterestsPopup() {
        let interestsVC = InterestsPopupViewController()
        interestsVC.interests = userInterests
        interestsVC.modalPresentationStyle = .popover
        interestsVC.preferredContentSize = CGSize(width: 300, height: 400)
        
        if let popoverPresentationController = interestsVC.popoverPresentationController {
            popoverPresentationController.sourceView = interestsView
            popoverPresentationController.sourceRect = interestsView.bounds
            popoverPresentationController.permittedArrowDirections = .any
        }
        
        present(interestsVC, animated: true, completion: nil)
    }
    
    // MARK: - Load Interests
    private func loadUserInterests() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        db.collection("Interest").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user interests: \(error.localizedDescription)")
                return
            }
            
            guard let data = document?.data(), let interests = data["interests"] as? [String] else {
                print("No interests data found.")
                return
            }
            
            self.userInterests = interests
            self.updateInterestsUI()
        }
    }
    
    private func updateInterestsUI() {
        interestsGridView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear existing views
        
        let columns = 2
        var currentRowStack: UIStackView?
        
        for (index, interest) in userInterests.enumerated() {
            if index % columns == 0 {
                currentRowStack = UIStackView()
                currentRowStack?.axis = .horizontal
                currentRowStack?.spacing = 12
                currentRowStack?.distribution = .fillEqually
                interestsGridView.addArrangedSubview(currentRowStack!)
            }
            
            let button = UIButton(type: .system)
            button.setTitle(interest, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.backgroundColor = UIColor.systemGray5
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            
            currentRowStack?.addArrangedSubview(button)
        }
        
        interestsView.isHidden = false
    }
    
    // MARK: - Load User Details
    private func loadUserDetails() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }
            
            guard let data = document?.data() else {
                print("No user data found for userId: \(userId)")
                return
            }
            
            self?.nameLabel.text = data["name"] as? String ?? "Name"
            self?.emailLabel.text = data["email"] as? String ?? "Email"
            self?.contactDetailsLabel.text = "Contact: \(data["ContactDetails"] as? String ?? "Not Available")"
            self?.descriptionLabel.text = "Description: \(data["Description"] as? String ?? "No Description Available")"
            self?.githubLabel.text = "GitHub: \(data["githubUrl"] as? String ?? "Not Available")"
            self?.linkedinLabel.text = "LinkedIn: \(data["linkedinUrl"] as? String ?? "Not Available")"
            self?.techStackLabel.text = "Tech Stack: \(data["techStack"] as? String ?? "Not Available")"
            self?.friendsLabel.text = "Friends: \(data["friends"] as? String ?? "0")"
            
            if let profileImageURLString = data["profileImageURL"] as? String,
               let profileImageURL = URL(string: profileImageURLString) {
                self?.loadProfileImage(from: profileImageURL)
            } else {
                self?.profileImageView.image = UIImage(named: "default_profile")
            }
        }
    }
    
    private func loadProfileImage(from url: URL) {
        // Using URLSession to download the image
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error downloading profile image: \(error.localizedDescription)")
                return
            }
            
            guard
                let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode),
                let data = data,
                let image = UIImage(data: data)
            else {
                print("Invalid response or image data.")
                return
            }
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }
        task.resume()
    }
    
    private func loadRegisteredEvents() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        db.collection("registrations").whereField("uid", isEqualTo: userId).getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching registrations: \(error.localizedDescription)")
                return
            }
            
            let eventIds = querySnapshot?.documents.compactMap { $0.data()["eventId"] as? String } ?? []
            if eventIds.isEmpty {
                print("No registered events found.")
            } else {
                self.fetchEvents(for: eventIds)
            }
        }
    }
    
    private func fetchEvents(for eventIds: [String]) {
        let group = DispatchGroup()
        registeredEvents.removeAll()
        
        for eventId in eventIds {
            group.enter()
            db.collection("events").document(eventId).getDocument { [weak self] document, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error fetching event details for \(eventId): \(error.localizedDescription)")
                    return
                }
                
                guard let data = document?.data(), let self = self else {
                    print("No data found for eventId: \(eventId)")
                    return
                }
                
                let imageNameOrUrl = data["imageName"] as? String ?? ""
                let isImageUrl = URL(string: imageNameOrUrl)?.scheme != nil
                
                let event = EventModel(
                    eventId: eventId,
                    title: data["title"] as? String ?? "Untitled",
                    category: data["category"] as? String ?? "Uncategorized",
                    attendanceCount: data["attendanceCount"] as? Int ?? 0,
                    organizerName: data["organizerName"] as? String ?? "Unknown",
                    date: data["date"] as? String ?? "Unknown Date",
                    time: data["time"] as? String ?? "Unknown Time",
                    location: data["location"] as? String ?? "Unknown Location",
                    locationDetails: data["locationDetails"] as? String ?? "",
                    imageName: isImageUrl ? imageNameOrUrl : "",
                    speakers: [],
                    userId: data["userId"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    latitude: data["latitude"] as? Double,
                    longitude: data["longitude"] as? Double,
                    tags: []
                )
                self.registeredEvents.append(event)
            }
        }
        
        group.notify(queue: .main) {
            self.eventsTableView.reloadData()
        }
    }
    
    // MARK: - Unregister Event
    func didTapUnregister(event: EventModel) {
        let alert = UIAlertController(
            title: "Unregister",
            message: "Are you sure you want to unregister from \(event.title)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.unregisterEvent(event)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    private func unregisterEvent(_ event: EventModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("registrations")
            .whereField("uid", isEqualTo: userId)
            .whereField("eventId", isEqualTo: event.eventId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching registration for unregistration: \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("No registration found for event \(event.eventId)")
                    return
                }
                
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting registration: \(error.localizedDescription)")
                    } else {
                        print("Successfully unregistered from event \(event.eventId)")
                        self.registeredEvents.removeAll { $0.eventId == event.eventId }
                        DispatchQueue.main.async {
                            self.eventsTableView.reloadData()
                        }
                    }
                }
            }
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registeredEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RegisteredEventCell.identifier, for: indexPath) as! RegisteredEventCell
        cell.configure(with: registeredEvents[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ticketVC = TicketViewController()
        ticketVC.eventId = registeredEvents[indexPath.row].eventId
        navigationController?.pushViewController(ticketVC, animated: true)
    }
    
    // MARK: - Segment Control Action
    @objc private func segmentChanged() {
        let isShowingEvents = segmentControl.selectedSegmentIndex == 1
        detailsStackView.isHidden = isShowingEvents
        eventsTableView.isHidden = !isShowingEvents
        if isShowingEvents {
            loadRegisteredEvents()
        }
    }
}




    // MARK: - InterestsPopupViewController
class InterestsPopupViewController: UIViewController {
        var interests: [String] = []

        private let interestsLabel: UILabel = {
            let label = UILabel()
            label.text = "Interests"
            label.font = UIFont.boldSystemFont(ofSize: 24)
            label.textAlignment = .center
            return label
        }()

        private let interestsStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 12
            stackView.alignment = .center
            return stackView
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }

        private func setupUI() {
            view.backgroundColor = .white
            view.layer.cornerRadius = 12
            view.clipsToBounds = true

            view.addSubview(interestsLabel)
            view.addSubview(interestsStackView)

            interestsLabel.translatesAutoresizingMaskIntoConstraints = false
            interestsStackView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                interestsLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
                interestsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                interestsStackView.topAnchor.constraint(equalTo: interestsLabel.bottomAnchor, constant: 16),
                interestsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                interestsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                interestsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
            ])

            for interest in interests {
                let interestLabel = UILabel()
                interestLabel.text = interest
                interestLabel.font = UIFont.systemFont(ofSize: 18)
                interestLabel.textAlignment = .center
                interestLabel.backgroundColor = UIColor.systemGray5
                interestLabel.layer.cornerRadius = 8
                interestLabel.clipsToBounds = true
                interestLabel.widthAnchor.constraint(equalTo: interestsStackView.widthAnchor, multiplier: 0.9).isActive = true

                interestsStackView.addArrangedSubview(interestLabel)
            }
        }
    }


import UIKit
import FirebaseAuth
import FirebaseStorage

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var name: String?
    var descriptionText: String?
    var contact: String?
    var githubUrl: String?
    var linkedinUrl: String?
    var techStack: String?
    var imageUrl: String?
    var onSave: ((UserDetails) -> Void)?

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
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
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
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
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Enter contact"
        return textField
    }()

    private let githubTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Enter GitHub URL"
        return textField
    }()

    private let linkedinTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Enter LinkedIn URL"
        return textField
    }()

    private let techStackTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Enter Tech Stack"
        return textField
    }()

    private let addTechStackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleAddTechStack), for: .touchUpInside)
        return button
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        populateFields()
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(profileImageView)
        view.addSubview(selectImageButton)
        view.addSubview(nameTextField)
        view.addSubview(descriptionTextView)
        view.addSubview(contactTextField)
        view.addSubview(githubTextField)
        view.addSubview(linkedinTextField)
        view.addSubview(techStackTextField)
        view.addSubview(addTechStackButton)
        view.addSubview(saveButton)
    }

    private func setupConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        selectImageButton.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        contactTextField.translatesAutoresizingMaskIntoConstraints = false
        githubTextField.translatesAutoresizingMaskIntoConstraints = false
        linkedinTextField.translatesAutoresizingMaskIntoConstraints = false
        techStackTextField.translatesAutoresizingMaskIntoConstraints = false
        addTechStackButton.translatesAutoresizingMaskIntoConstraints = false
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
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),

            contactTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            contactTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contactTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            githubTextField.topAnchor.constraint(equalTo: contactTextField.bottomAnchor, constant: 20),
            githubTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            githubTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            linkedinTextField.topAnchor.constraint(equalTo: githubTextField.bottomAnchor, constant: 20),
            linkedinTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            linkedinTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            techStackTextField.topAnchor.constraint(equalTo: linkedinTextField.bottomAnchor, constant: 20),
            techStackTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            techStackTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            addTechStackButton.topAnchor.constraint(equalTo: techStackTextField.bottomAnchor, constant: 10),
            addTechStackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addTechStackButton.widthAnchor.constraint(equalToConstant: 50),
            addTechStackButton.heightAnchor.constraint(equalToConstant: 30),

            saveButton.topAnchor.constraint(equalTo: addTechStackButton.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func populateFields() {
        nameTextField.text = name
        descriptionTextView.text = descriptionText
        contactTextField.text = contact
        githubTextField.text = githubUrl
        linkedinTextField.text = linkedinUrl
        techStackTextField.text = techStack
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            loadProfileImage(from: url)
        } else {
            profileImageView.image = UIImage(named: "default_profile")
        }
    }

    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        }.resume()
    }

    @objc private func handleSelectImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
        }
    }

    @objc private func handleSave() {
        guard
            let updatedName = nameTextField.text,
            let updatedDescription = descriptionTextView.text,
            let updatedContact = contactTextField.text,
            let updatedGithubUrl = githubTextField.text,
            let updatedLinkedinUrl = linkedinTextField.text,
            let updatedTechStack = techStackTextField.text,
            let profileImage = profileImageView.image,
            let imageData = profileImage.jpegData(compressionQuality: 0.8),
            let userId = Auth.auth().currentUser?.uid
        else { return }

        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            guard error == nil else { return }

            storageRef.downloadURL { [weak self] url, error in
                guard let url = url else { return }

                let details = UserDetails(
                    id: userId,
                    name: updatedName,
                    description: updatedDescription,
                    imageUrl: url.absoluteString, contact: updatedContact,
                    githubUrl: updatedGithubUrl,
                    linkedinUrl: updatedLinkedinUrl,
                    techStack: updatedTechStack
                )

                self?.onSave?(details)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func handleAddTechStack() {
        let techStackVC = TechStackViewController()
        techStackVC.userID = Auth.auth().currentUser?.uid
        techStackVC.selectedTechStack = self.techStackTextField.text?.components(separatedBy: ", ") ?? []
        techStackVC.onSave = { [weak self] selectedTechStack in
            self?.techStackTextField.text = selectedTechStack.joined(separator: ", ")
        }
        navigationController?.pushViewController(techStackVC, animated: true)
    }
}
