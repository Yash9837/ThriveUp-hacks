

import UIKit
import MapKit
import FirebaseFirestore
import FirebaseAuth

class EventDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties
    var eventId: String? // Event ID passed from the previous page
    var openedFromEventVC: Bool = false // Flag to check if opened from EventViewController
    private let db = Firestore.firestore()
    var event: EventModel?

    // MARK: - UI Elements
    private let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let detailSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 5
        return view
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        return label
    }()

    private let organizerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Organizer"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private let organizerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private let organizerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()

    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()

    private let locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mappin.and.ellipse")
        imageView.tintColor = .orange
        imageView.backgroundColor = UIColor.orange.withAlphaComponent(0.2)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    private let dateIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = .orange
        imageView.backgroundColor = UIColor.orange.withAlphaComponent(0.2)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    private let mapTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Map"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.layer.cornerRadius = 10
        map.isUserInteractionEnabled = false
        return map
    }()

    private let speakersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Speakers"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private let speakersCollectionView: UICollectionView

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializer
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 100)
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        speakersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchEventDetails()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white

        // Add gesture recognizers
        let eventTapGesture = UITapGestureRecognizer(target: self, action: #selector(eventImageTapped))
        eventImageView.isUserInteractionEnabled = true
        eventImageView.addGestureRecognizer(eventTapGesture)

        let organizerTapGesture = UITapGestureRecognizer(target: self, action: #selector(organizerImageTapped))
        organizerImageView.isUserInteractionEnabled = true
        organizerImageView.addGestureRecognizer(organizerTapGesture)

        // Add subviews
        view.addSubview(eventImageView)
        view.addSubview(detailSectionView)
        view.addSubview(registerButton)
        detailSectionView.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, organizerTitleLabel, organizerImageView, organizerNameLabel,
         descriptionTitleLabel, descriptionLabel, locationIcon, locationLabel, dateIcon, dateLabel,
         mapTitleLabel, mapView, speakersTitleLabel, speakersCollectionView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        setupConstraints()
    }

    private func setupConstraints() {
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        detailSectionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Event Image View
            eventImageView.topAnchor.constraint(equalTo: view.topAnchor),
            eventImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eventImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventImageView.heightAnchor.constraint(equalToConstant: 300),

            // Detail Section View
            detailSectionView.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: -30),
            detailSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailSectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Scroll View inside Detail Section
            scrollView.topAnchor.constraint(equalTo: detailSectionView.topAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: detailSectionView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: detailSectionView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: detailSectionView.bottomAnchor),

            // Content View inside Scroll View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Register Button (Fixed at Bottom)
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            registerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            registerButton.heightAnchor.constraint(equalToConstant: 50),

            // Title Section
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            // Organizer Section
            organizerTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            organizerTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            organizerImageView.topAnchor.constraint(equalTo: organizerTitleLabel.bottomAnchor, constant: 8),
            organizerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            organizerImageView.widthAnchor.constraint(equalToConstant: 40),
            organizerImageView.heightAnchor.constraint(equalToConstant: 40),

            organizerNameLabel.centerYAnchor.constraint(equalTo: organizerImageView.centerYAnchor),
            organizerNameLabel.leadingAnchor.constraint(equalTo: organizerImageView.trailingAnchor, constant: 8),

            // Description Section
            descriptionTitleLabel.topAnchor.constraint(equalTo: organizerImageView.bottomAnchor, constant: 16),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Location Section
            locationIcon.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            locationIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationIcon.widthAnchor.constraint(equalToConstant: 40),
            locationIcon.heightAnchor.constraint(equalToConstant: 40),

            locationLabel.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 8),

            // Date Section
            dateIcon.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            dateIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateIcon.widthAnchor.constraint(equalToConstant: 40),
            dateIcon.heightAnchor.constraint(equalToConstant: 40),

            dateLabel.centerYAnchor.constraint(equalTo: dateIcon.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateIcon.trailingAnchor, constant: 8),

            // Map Section
            mapTitleLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            mapTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            mapView.topAnchor.constraint(equalTo: mapTitleLabel.bottomAnchor, constant: 8),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 200),

            // Speakers Section
            speakersTitleLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            speakersTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            speakersCollectionView.topAnchor.constraint(equalTo: speakersTitleLabel.bottomAnchor, constant: 8),
            speakersCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            speakersCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            speakersCollectionView.heightAnchor.constraint(equalToConstant: 120),

            contentView.bottomAnchor.constraint(equalTo: speakersCollectionView.bottomAnchor, constant: 80)
        ])
    }
    @objc private func eventImageTapped() {
        if let image = eventImageView.image {
            presentImagePreview(image: image)
        }
    }

    @objc private func organizerImageTapped() {
        if let image = organizerImageView.image {
            presentImagePreview(image: image)
        }
    }

    private func presentImagePreview(image: UIImage) {
        let previewVC = ImagePreviewViewController(image: image)
        previewVC.modalPresentationStyle = .fullScreen
        present(previewVC, animated: true, completion: nil)
    }

    private func fetchEventDetails() {
        guard let eventId = eventId else { return }
        db.collection("events").document(eventId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching event: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No data found for eventId: \(eventId)")
                return
            }
            
            // Parse the `speakers` array
            let speakers: [Speaker] = (data["speakers"] as? [[String: Any]])?.compactMap { speakerDict in
                guard let name = speakerDict["name"] as? String,
                      let imageURL = speakerDict["imageURL"] as? String else {
                    return nil
                }
                return Speaker(name: name, imageURL: imageURL)
            } ?? []

            // Fetch organizer details (UID from event document)
            let uid = data["userId"] as? String ?? ""
            self.fetchOrganizerDetails(uid: uid)

            // Initialize the EventModel
            let event = EventModel(
                eventId: data["eventId"] as? String ?? "",
                title: data["title"] as? String ?? "Untitled",
                category: data["category"] as? String ?? "Uncategorized",
                attendanceCount: data["attendanceCount"] as? Int ?? 0,
                organizerName: data["organizerName"] as? String ?? "Unknown Organizer",
                date: data["date"] as? String ?? "Unknown Date",
                time: data["time"] as? String ?? "Unknown Time",
                location: data["location"] as? String ?? "Unknown Location",
                locationDetails: data["locationDetails"] as? String ?? "",
                imageName: data["imageName"] as? String ?? "",
                speakers: speakers,
                userId: data["userId"] as? String ?? "",
                description: data["description"] as? String ?? "",
                latitude: data["latitude"] as? Double,
                longitude: data["longitude"] as? Double,
                tags: []
            )
            
            self.event = event

            // Update the UI
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
    }

    private func fetchOrganizerDetails(uid: String) {
        guard !uid.isEmpty else {
            print("UID is empty. Cannot fetch organizer details.")
            return
        }
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching organizer details: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No data found for UID: \(uid)")
                return
            }
            
            // Extract organizer details
            let organizerName = data["name"] as? String ?? "Unknown Organizer"
            let profileImageURL = data["profileImageURL"] as? String ?? ""

            // Update the organizer UI
            DispatchQueue.main.async {
                self.organizerNameLabel.text = organizerName
                
                if let url = URL(string: profileImageURL) {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                self.organizerImageView.image = UIImage(data: data)
                            }
                        }
                    }
                }
            }
        }
    }

    private func updateUI() {
        guard let event = event else { return }
        titleLabel.text = event.title
        descriptionLabel.text = event.description
        locationLabel.text = event.location
        dateLabel.text = "\(event.date), \(event.time)"
        
        if let latitude = event.latitude, let longitude = event.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: false)

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = event.location
            mapView.addAnnotation(annotation)
        }
        
        if let imageUrl = URL(string: event.imageName) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async {
                        self.eventImageView.image = UIImage(data: data)
                    }
                }
            }
        }
        
        // Reload the collection view to display speakers
        speakersCollectionView.reloadData()
    }

    @objc private func registerButtonTapped() {
        guard let event = event else { return }
        
        if openedFromEventVC{
            // Navigate to LoginViewController
            let loginVC = LoginViewController()
            navigationController?.pushViewController(loginVC, animated: true)
        } else {
            // Define form fields with placeholders and empty values
            let formFields = [
                FormField(placeholder: "Name", value: ""),
                FormField(placeholder: "Phone Number", value: ""),
                FormField(placeholder: "Year of Study", value: ""),
                FormField(placeholder: "Course", value: ""),
                FormField(placeholder: "Department", value: ""),
                FormField(placeholder: "Specialization", value: "")
            ]
            
            // Initialize and push the registration view controller
            let registrationVC = RegistrationViewController(formFields: formFields, event: event)
            navigationController?.pushViewController(registrationVC, animated: true)
        }
    }

    // MARK: - Collection View DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return event?.speakers.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpeakerCell.identifier, for: indexPath) as! SpeakerCell
        if let speaker = event?.speakers[indexPath.item] {
            cell.configure(with: speaker)
        }
        return cell
    }
}

class SpeakerCell: UICollectionViewCell {
    static let identifier = "SpeakerCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with speaker: Speaker) {
        nameLabel.text = speaker.name
        if let url = URL(string: speaker.imageURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}

class ImagePreviewViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return button
    }()

    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(imageView)
        view.addSubview(closeButton)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 80),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
