

//
//  OrganiserEventDetailViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 24/01/25.
//


    import UIKit
    import MapKit
    import FirebaseFirestore

    class OrganiserEventDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

        // MARK: - Properties
        var eventId: String? // Event ID passed from the previous page
        private let db = Firestore.firestore()
        var chatThread: ChatThread? // The current chat thread
           var onChatEnded: (() -> Void)?
        var event: EventModel?
        override func viewDidDisappear(_ animated: Bool) {
                super.viewDidDisappear(animated)
                onChatEnded?() // Trigger the closure when the view disappears
            }
        

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
        

        private let EditButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Edit", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            button.backgroundColor = .orange
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            
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
            setupRegisterButton()
            fetchEventDetails()
        }

        // MARK: - Setup UI
        private func setupUI() {
            view.backgroundColor = .white

            // Add subviews
            view.addSubview(eventImageView)
            view.addSubview(detailSectionView)
            view.addSubview(EditButton)
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
            EditButton.translatesAutoresizingMaskIntoConstraints = false

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
                EditButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                EditButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                EditButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                EditButton.heightAnchor.constraint(equalToConstant: 50),

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
                
                // Debugging: Print the parsed speakers
                print("Parsed Speakers: \(speakers)")

                // Fetch organizer details (UID from event document)
                let uid = data["uid"] as? String ?? ""
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
                    userId : "",
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

        

        private func setupRegisterButton() {
            EditButton.setTitle("Edit", for: .normal)
            EditButton.backgroundColor = .orange
            EditButton.setTitleColor(.white, for: .normal)
            EditButton.layer.cornerRadius = 10
            EditButton.addTarget(self, action: #selector(EditButtonTapped), for: .touchUpInside)
        }
        @objc private func EditButtonTapped() {
            guard let event = event else { return }
                   
                   let editEventVC = EditEventViewController()
                   editEventVC.event = event
                   editEventVC.onEventUpdated = { [weak self] updatedEvent in
                       self?.event = updatedEvent
                       self?.updateUI() // Refresh UI after editing
                   }
                   navigationController?.pushViewController(editEventVC, animated: true)
        }


        // MARK: - Collection View DataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return event?.speakers.count ?? 0
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpeakerCell2.identifier, for: indexPath) as! SpeakerCell2
            if let speaker = event?.speakers[indexPath.item] {
                cell.configure(with: speaker)
            }
            return cell
        }
    }

    class SpeakerCell2: UICollectionViewCell {
        static let identifier = "SpeakerCell2"
        
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
class EditEventViewController: UIViewController {
    
    // MARK: - Properties
    var event: EventModel? // The event to be edited
    private let db = Firestore.firestore()
    var onEventUpdated: ((EventModel) -> Void)?
    
    // MARK: - UI Elements
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Event Title"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    private let dateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Event Date"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let locationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Event Location"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        populateFields()
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
        view.addSubview(dateTextField)
        view.addSubview(locationTextField)
        view.addSubview(saveButton)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        locationTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 150),
            
            dateTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            dateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateTextField.heightAnchor.constraint(equalToConstant: 50),
            
            locationTextField.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 16),
            locationTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            locationTextField.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Populate Fields with Event Data
    private func populateFields() {
        guard let event = event else { return }
        titleTextField.text = event.title
        descriptionTextView.text = event.description
        dateTextField.text = event.date
        locationTextField.text = event.location
    }
    // Save button action
        @objc private func saveButtonTapped() {
            guard let event = event else { return }
            
            let updatedTitle = titleTextField.text ?? ""
            let updatedDescription = descriptionTextView.text ?? ""
            let updatedDate = dateTextField.text ?? ""
            let updatedLocation = locationTextField.text ?? ""
            
            let updatedEvent = EventModel(
                eventId: event.eventId,
                title: updatedTitle,
                category: event.category,
                attendanceCount: event.attendanceCount,
                organizerName: event.organizerName,
                date: updatedDate,
                time: event.time,
                location: updatedLocation,
                locationDetails: event.locationDetails,
                imageName: event.imageName,
                speakers: event.speakers,
                userId: event.userId,
                description: updatedDescription,
                latitude: event.latitude,
                longitude: event.longitude,
                
                tags: event.tags
            )
            
            db.collection("events").document(event.eventId).updateData([
                "title": updatedTitle,
                "description": updatedDescription,
                "date": updatedDate,
                "location": updatedLocation
            ]) { [weak self] error in
                if let error = error {
                    print("Error updating event: \(error.localizedDescription)")
                    return
                }
                
                self?.onEventUpdated?(updatedEvent)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    // MARK: - Save Button Action
  
}
