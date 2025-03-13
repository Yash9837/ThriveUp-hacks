import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// Extension to add padding to UITextField
private extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

class EventPostViewController: UIViewController, CLLocationManagerDelegate, TagViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let imagePickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.backgroundColor = .white
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(selectEventImage), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()

    
    private let titleLabel = UILabel()
    private let titleTextField = UITextField()
    
    private let categoryLabel = UILabel()
    private let categoryTextField = UITextField()
    private let categoryPicker = UIPickerView()
    
    private let attendanceLabel = UILabel()
    private let attendanceTextField = UITextField()
    
    private let organizerLabel = UILabel()
    private let organizerTextField = UITextField()
    
    private let dateLabel = UILabel()
    private let datePicker = UIDatePicker()
    
    private let timeLabel = UILabel()
    private let timeTextField = UITextField()
    
    private let locationLabel = UILabel()
    private let locationTextField = UITextField()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.layer.cornerRadius = 8
        mapView.layer.borderWidth = 1
        mapView.layer.borderColor = UIColor.lightGray.cgColor
        return mapView
    }()
    
    private let locationDetailsLabel = UILabel()
    private let locationDetailsTextField = UITextField()
    
    private let descriptionLabel = UILabel()
    private let descriptionTextView = UITextView()
    
    private let tagsLabel = UILabel()
    private let tagsStackView = UIStackView()
    private let addTagsButton = UIButton(type: .system)
    private let editTagsButton = UIButton(type: .system)
    
    private let submitButton = UIButton(type: .system)
    
    // New UI components for speakers
    private let speakersLabel = UILabel()
    private let addSpeakerButton = UIButton(type: .system)
    private let speakersStackView = UIStackView()
    
    // Firestore Reference
    private let db = Firestore.firestore()
    
    // Firebase Storage Reference
    private let storage = Storage.storage()
    
    // Predefined Categories
    private let categories = [
        "Trending", "Fun and Entertainment", "Tech and Innovation",
        "Club and Societies", "Cultural", "Networking", "Sports",
        "Career Connect", "Wellness", "Other"
    ]
    private var selectedCategory: String?
    
    // Location Variables
    private var selectedLatitude: Double?
    private var selectedLongitude: Double?
    private let locationManager = CLLocationManager()
    
    // Tags
    private var selectedTags: [String] = []
    
    // Selected Image
    private var selectedImage: UIImage? {
        didSet {
            if let image = selectedImage {
                imagePickerButton.setBackgroundImage(image, for: .normal)
                imagePickerButton.setTitle("", for: .normal)
            } else {
                imagePickerButton.setBackgroundImage(nil, for: .normal)
                imagePickerButton.setTitle("+", for: .normal)
            }
        }
    }
    
    // Speakers
    private var speakers: [Speaker] = []
    
    // Dictionary to keep track of speaker images
    private var speakerImages: [Int: UIImage] = [:]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardHandling()
        setupMapGestureRecognizer()
        setupLocationManager()
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Location Permission Denied",
            message: "Please enable location permissions in Settings to select event locations.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Location Manager Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .denied || status == .restricted {
            showLocationPermissionAlert()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        
        // Center map on user's current location
        let coordinateRegion = MKCoordinateRegion(
            center: userLocation.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        mapView.setRegion(coordinateRegion, animated: true)
        
        // Stop updating location to save battery
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "Post an Event"
        
        // Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        
        // Image Picker
        contentView.addSubview(imagePickerButton)
        
        // Title
        setupLabel(titleLabel, text: "Event Title")
        setupTextField(titleTextField, placeholder: "Enter event title")
        
        // Category
        setupLabel(categoryLabel, text: "Category")
        setupTextField(categoryTextField, placeholder: "Select category")
        categoryTextField.inputView = categoryPicker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        // Attendance
        setupLabel(attendanceLabel, text: "Attendance Count")
        setupTextField(attendanceTextField, placeholder: "Enter attendance count", keyboardType: .numberPad)
        
        // Organizer
        setupLabel(organizerLabel, text: "Organizer Name")
        setupTextField(organizerTextField, placeholder: "Enter organizer name")
        
        // Date Picker
        setupLabel(dateLabel, text: "Event Date")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        contentView.addSubview(datePicker)
        
        // Time
        setupLabel(timeLabel, text: "Event Time")
        setupTextField(timeTextField, placeholder: "Enter event time (e.g., 10:00 AM)")
        
        // Location
        setupLabel(locationLabel, text: "Location Name")
        setupTextField(locationTextField, placeholder: "Enter location name")
        
        // Map View
        contentView.addSubview(mapView)
        
        // Location Details
        setupLabel(locationDetailsLabel, text: "Location Details")
        setupTextField(locationDetailsTextField, placeholder: "Enter location details")
        
        // Description
        setupLabel(descriptionLabel, text: "Event Description")
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.font = .systemFont(ofSize: 14)
        contentView.addSubview(descriptionTextView)
        
        // Tags
        setupLabel(tagsLabel, text: "Tags")
        
        tagsStackView.axis = .vertical
        tagsStackView.spacing = 4
        contentView.addSubview(tagsStackView)
        
        // Add Tags Button
        addTagsButton.setTitle("Add Tags", for: .normal)
        addTagsButton.addTarget(self, action: #selector(addTagsButtonTapped), for: .touchUpInside)
        contentView.addSubview(addTagsButton)
        
        // Edit Tags Button
        editTagsButton.setTitle("Edit Tags", for: .normal)
        editTagsButton.addTarget(self, action: #selector(editTagsButtonTapped), for: .touchUpInside)
        contentView.addSubview(editTagsButton)
        editTagsButton.isHidden = true // Initially hidden
        
        // New UI components for speakers
        setupLabel(speakersLabel, text: "Speakers")
        
        addSpeakerButton.setTitle("Add Speaker", for: .normal)
        addSpeakerButton.addTarget(self, action: #selector(addSpeakerButtonTapped), for: .touchUpInside)
        contentView.addSubview(addSpeakerButton)
        
        speakersStackView.axis = .vertical
        speakersStackView.spacing = 8
        contentView.addSubview(speakersStackView)
        
        // Submit Button
        submitButton.setTitle("Post Event", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(postEvent), for: .touchUpInside)
        contentView.addSubview(submitButton)
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [UIView] = [
            imagePickerButton, titleLabel, titleTextField,
            categoryLabel, categoryTextField,
            attendanceLabel, attendanceTextField,
            organizerLabel, organizerTextField,
            dateLabel, datePicker,
            timeLabel, timeTextField,
            locationLabel, locationTextField,
            mapView, locationDetailsLabel,
            locationDetailsTextField, descriptionLabel,
            descriptionTextView, tagsLabel, tagsStackView,
            addTagsButton, editTagsButton, speakersLabel,
            addSpeakerButton, speakersStackView, submitButton
        ]
        
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            
            
            // ScrollView Constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView Constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Image Picker Button
            imagePickerButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imagePickerButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imagePickerButton.widthAnchor.constraint(equalToConstant: 150),
            imagePickerButton.heightAnchor.constraint(equalToConstant: 150),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: imagePickerButton.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Title TextField
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Category Label
            categoryLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Category TextField
            categoryTextField.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            categoryTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Attendance Label
            attendanceLabel.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: 16),
            attendanceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            attendanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Attendance TextField
            attendanceTextField.topAnchor.constraint(equalTo: attendanceLabel.bottomAnchor, constant: 8),
            attendanceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            attendanceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            attendanceTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Organizer Label
            organizerLabel.topAnchor.constraint(equalTo: attendanceTextField.bottomAnchor, constant: 16),
            organizerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            organizerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Organizer TextField
            organizerTextField.topAnchor.constraint(equalTo: organizerLabel.bottomAnchor, constant: 8),
            organizerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            organizerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            organizerTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Date Label and Date Picker
            dateLabel.topAnchor.constraint(equalTo: organizerTextField.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePicker.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Time Label
            timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Time TextField
            timeTextField.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            timeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Location Label
            locationLabel.topAnchor.constraint(equalTo: timeTextField.bottomAnchor, constant: 16),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Location TextField
            locationTextField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            locationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            locationTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Map View
            mapView.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 300),
            
            // Location Details Label
            locationDetailsLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            locationDetailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationDetailsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Location Details TextField
            locationDetailsTextField.topAnchor.constraint(equalTo: locationDetailsLabel.bottomAnchor, constant: 8),
            locationDetailsTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationDetailsTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            locationDetailsTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: locationDetailsTextField.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Description TextView
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120),
            
            // Tags Label
                        tagsLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
                        tagsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                        tagsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                        
                        // Tags StackView
                        tagsStackView.topAnchor.constraint(equalTo: tagsLabel.bottomAnchor, constant: 8),
                        tagsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                        tagsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                        
                        // Add Tags Button
                        addTagsButton.topAnchor.constraint(equalTo: tagsStackView.bottomAnchor, constant: 8),
                        addTagsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                        addTagsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                        addTagsButton.heightAnchor.constraint(equalToConstant: 44),
                        
                        // Edit Tags Button
                        editTagsButton.topAnchor.constraint(equalTo: addTagsButton.bottomAnchor, constant: 8),
                        editTagsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                        editTagsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                        editTagsButton.heightAnchor.constraint(equalToConstant: 44),
                        
                        // Speakers Label
                        speakersLabel.topAnchor.constraint(equalTo: editTagsButton.bottomAnchor, constant: 16),
                        speakersLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                        
                        // Add Speaker Button
                        addSpeakerButton.centerYAnchor.constraint(equalTo: speakersLabel.centerYAnchor),
                        addSpeakerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                        addSpeakerButton.heightAnchor.constraint(equalToConstant: 44),
                        
                        // Speakers StackView
                        speakersStackView.topAnchor.constraint(equalTo: addSpeakerButton.bottomAnchor, constant: 16),
                        speakersStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                        speakersStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                        
                        // Submit Button
                        submitButton.topAnchor.constraint(equalTo: speakersStackView.bottomAnchor, constant: 20),
                        submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                        submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                        submitButton.heightAnchor.constraint(equalToConstant: 50),
                        submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
                    ])
                }

                private func setupLabel(_ label: UILabel, text: String) {
                    label.text = text
                    label.font = .systemFont(ofSize: 16, weight: .semibold)
                    label.textColor = .darkGray
                    contentView.addSubview(label)
                }

                private func setupTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default) {
                    textField.placeholder = placeholder
                    textField.borderStyle = .roundedRect
                    textField.keyboardType = keyboardType
                    textField.layer.cornerRadius = 8
                    textField.layer.borderWidth = 1
                    textField.layer.borderColor = UIColor.lightGray.cgColor
                    textField.setLeftPaddingPoints(10) // Add padding to the text field
                    contentView.addSubview(textField)
                }

                private func setupKeyboardHandling() {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                    tapGesture.cancelsTouchesInView = false // Allow other interactions, such as map gestures
                    view.addGestureRecognizer(tapGesture)

                    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
                }

                @objc private func dismissKeyboard() {
                    view.endEditing(true)
                }

                @objc private func keyboardWillShow(notification: NSNotification) {
                    if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                        let keyboardFrame = keyboardSize.cgRectValue
                        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
                        scrollView.contentInset = contentInsets
                        scrollView.scrollIndicatorInsets = contentInsets
                    }
                }

                @objc private func keyboardWillHide(notification: NSNotification) {
                    let contentInsets = UIEdgeInsets.zero
                    scrollView.contentInset = contentInsets
                    scrollView.scrollIndicatorInsets = contentInsets
                }

                private func setupMapGestureRecognizer() {
                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleMapLongPress(_:)))
                    mapView.addGestureRecognizer(longPressGesture)
                }

                @objc private func handleMapLongPress(_ gesture: UILongPressGestureRecognizer) {
                    if gesture.state == .began {
                        let locationInView = gesture.location(in: mapView)
                        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)

                        // Remove existing annotations
                        mapView.removeAnnotations(mapView.annotations)

                        // Add a new pin
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "Event Location"
                        mapView.addAnnotation(annotation)

                        // Save coordinates
                        selectedLatitude = coordinate.latitude
                        selectedLongitude = coordinate.longitude
                    }
                }

                @objc private func addTagsButtonTapped() {
                    let tagVC = TagViewController()
                    tagVC.delegate = self
                    tagVC.selectedTags = self.selectedTags
                    navigationController?.pushViewController(tagVC, animated: true)
                    addTagsButton.isHidden = true
                    editTagsButton.isHidden = false
                }

                @objc private func editTagsButtonTapped() {
                    let tagVC = TagViewController()
                    tagVC.delegate = self
                    tagVC.selectedTags = self.selectedTags
                    navigationController?.pushViewController(tagVC, animated: true)
                }

                // MARK: - TagViewControllerDelegate
                func tagViewController(_ controller: TagViewController, didSelectTags tags: [String]) {
                    self.selectedTags = tags
                    updateTagsView()
                }

                private func updateTagsView() {
                    // Clear existing tag labels
                    for view in tagsStackView.arrangedSubviews {
                        tagsStackView.removeArrangedSubview(view)
                        view.removeFromSuperview()
                    }

                    // Add new tag labels in pairs
                    var currentRowStackView: UIStackView?
                    for (index, tag) in selectedTags.enumerated() {
                        if index % 2 == 0 {
                            currentRowStackView = UIStackView()
                            currentRowStackView?.axis = .horizontal
                            currentRowStackView?.spacing = 8
                            currentRowStackView?.distribution = .fillEqually
                            tagsStackView.addArrangedSubview(currentRowStackView!)
                        }

                        let label = UILabel()
                        label.text = tag
                        label.font = .systemFont(ofSize: 14)
                        label.backgroundColor = .systemGray6
                        label.textColor = .black
                        label.layer.cornerRadius = 8
                        label.layer.masksToBounds = true
                        label.textAlignment = .center
                        label.heightAnchor.constraint(equalToConstant: 32).isActive = true
                        label.widthAnchor.constraint(equalToConstant: 150).isActive = true // Increased width for larger size

                        currentRowStackView?.addArrangedSubview(label)
                    }
                }

                // MARK: - Image Picker Functions
                @objc private func selectEventImage() {
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.sourceType = .photoLibrary
                    imagePickerController.view.tag = 0 // Tag the controller to identify it later
                    present(imagePickerController, animated: true, completion: nil)
                }

                @objc private func selectSpeakerImage(_ sender: UITapGestureRecognizer) {
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.sourceType = .photoLibrary
                    imagePickerController.view.tag = sender.view?.tag ?? 0 // Tag the controller with the sender's tag
                    present(imagePickerController, animated: true, completion: nil)
                }

                func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                    if let image = info[.originalImage] as? UIImage {
                        if picker.view.tag == 0 {
                            // Event image picker
                            selectedImage = image
                        } else {
                            // Speaker image picker
                            let imageViewTag = picker.view.tag
                            speakerImages[imageViewTag] = image
                            if let imageView = speakersStackView.viewWithTag(imageViewTag) as? UIImageView {
                                imageView.image = image
                            }
                        }
                    }
                    dismiss(animated: true, completion: nil)
                }

                func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                    dismiss(animated: true, completion: nil)
                }

                // MARK: - Post Event
                @objc private func postEvent() {
                    var missingFields = [String]()

                    // Validate fields
                    if let title = titleTextField.text, title.isEmpty {
                        missingFields.append("Event Title")
                    }

                    if selectedCategory == nil || selectedCategory?.isEmpty == true {
                        missingFields.append("Category")
                    }

                    if let time = timeTextField.text, time.isEmpty {
                        missingFields.append("Event Time")
                    }

                    if let location = locationTextField.text, location.isEmpty {
                        missingFields.append("Location Name")
                    }

                    if selectedLatitude == nil || selectedLongitude == nil {
                        missingFields.append("Event Location")
                    }

                    if selectedImage == nil {
                        missingFields.append("Event Image")
                    }

                    if !missingFields.isEmpty {
                        let message = "Please fill in the following fields: \(missingFields.joined(separator: ", "))"
                        showAlert(title: "Error", message: message)
                        return
                    }
                    
                    // Start Activity Indicator
                        activityIndicator.startAnimating()
                        submitButton.isEnabled = false

                    guard let title = titleTextField.text,
                          let selectedCategory = selectedCategory,
                          let time = timeTextField.text,
                          let location = locationTextField.text,
                          let latitude = selectedLatitude,
                          let organizerName = organizerTextField.text,
                          let longitude = selectedLongitude,
                          let image = selectedImage,
                          let userId = Auth.auth().currentUser?.uid else {
                        showAlert(title: "Error", message: "Please fill in all required fields.")
                        return
                    }

                    let eventId = UUID().uuidString
                    let attendanceCount = Int(attendanceTextField.text ?? "0") ?? 0
                    let eventDate = DateFormatter.localizedString(from: datePicker.date, dateStyle: .medium, timeStyle: .none)
                    let locationDetails = locationDetailsTextField.text ?? ""
                    let description = descriptionTextView.text.isEmpty ? nil : descriptionTextView.text

                    // Upload event image to Firestore Storage
                    let storageRef = storage.reference().child("event_images/\(eventId).jpg")
                    guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

                    storageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
                        guard let self = self else { return }
                        if let error = error {
                            self.showAlert(title: "Error", message: error.localizedDescription)
                            return
                        }

                        storageRef.downloadURL { (url, error) in
                            if let error = error {
                                self.showAlert(title: "Error", message: error.localizedDescription)
                                return
                            }

                            guard let imageUrl = url?.absoluteString else { return }

                            let speakerData = self.speakers.enumerated().compactMap { (index, speaker) -> [String: String]? in
                                if let image = self.speakerImages[index + 1] {
                                    return [
                                        "name": speaker.name,
                                        "imageURL": imageUrl
                                    ]
                                }
                                return nil
                            }

                            // Save event data to Firestore
                            let eventData: [String: Any] = [
                                "eventId": eventId,
                                "title": title,
                                "category": selectedCategory,
                                "attendanceCount": attendanceCount,
                                "date": eventDate,
                                "time": time,
                                "location": location,
                                "speakers": speakerData,
                                "organizerName": organizerName,
                                "locationDetails": locationDetails,
                                "description": description ?? "",
                                "latitude": latitude,
                                "longitude": longitude,
                                "imageName": imageUrl,
                                "tags": self.selectedTags,
                                "userId": userId
                            ]

                            self.db.collection("events").document(eventId).setData(eventData) { error in
                                if let error = error {
                                    self.showAlert(title: "Error", message: error.localizedDescription)
                                } else {
                                    self.showAlert(title: "Success", message: "Event posted successfully!") {
                                        self.tabBarController?.selectedIndex = 0
                                    }
                                }
                            }
                        }
                    }

                    // Upload speaker images to Firestore Storage
                    for (index, image) in speakerImages {
                        let speakerId = UUID().uuidString
                        let storageRef = storage.reference().child("speaker_images/\(speakerId).jpg")
                        guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }

                        storageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
                            guard let self = self else { return }
                            if let error = error {
                                self.showAlert(title: "Error", message: error.localizedDescription)
                                return
                            }

                            storageRef.downloadURL { (url, error) in
                                if let error = error {
                                    self.showAlert(title: "Error", message: error.localizedDescription)
                                    return
                                }

                                guard let imageUrl = url?.absoluteString else { return }

                                // Update the speaker's imageURL
                                self.speakers[index - 1].imageURL = imageUrl

                                // Save updated speakers to Firestore
                                self.db.collection("events").document(eventId).updateData([
                                    "speakers": self.speakers.map { ["name": $0.name, "imageURL": $0.imageURL] }
                                ])
                            }
                        }
                    }
                }

                @objc private func addSpeakerButtonTapped() {
                    let speakerView = createSpeakerInputView()
                    speakersStackView.addArrangedSubview(speakerView)
                    speakers.append(Speaker(name: "", imageURL: ""))
                }

    private func createSpeakerInputView() -> UIView {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false

            // Speaker Image
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "person.circle") // Placeholder image
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(imageView)

            // Speaker Name TextField
            let textField = UITextField()
            textField.placeholder = "Enter speaker name"
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(textField)

            // Delete Button
            let deleteButton = UIButton(type: .system)
            deleteButton.setTitle("Delete", for: .normal)
            deleteButton.setTitleColor(.red, for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteSpeakerButtonTapped(_:)), for: .touchUpInside)
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(deleteButton)

            // Set tag for imageView
            imageView.tag = speakersStackView.arrangedSubviews.count + 1

            // Layout Constraints
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 50),
                imageView.heightAnchor.constraint(equalToConstant: 50),

                textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
                textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                textField.heightAnchor.constraint(equalToConstant: 44),

                deleteButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 16),
                deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

                containerView.heightAnchor.constraint(equalToConstant: 70) // Adjust as needed
            ])

            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectSpeakerImage(_:))))

            return containerView
        }

                @objc private func deleteSpeakerButtonTapped(_ sender: UIButton) {
                    guard let speakerView = sender.superview else { return }
                    speakersStackView.removeArrangedSubview(speakerView)
                    speakerView.removeFromSuperview()

                    if let index = speakersStackView.arrangedSubviews.firstIndex(of: speakerView) {
                        speakers.remove(at: index)
                        speakerImages.removeValue(forKey: index + 1)
                    }
                }

                private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        completion?()
                    }
                    alert.addAction(okAction)
                    present(alert, animated: true)
                }
            }

            // MARK: - UIPickerViewDelegate and UIPickerViewDataSource
            extension EventPostViewController: UIPickerViewDelegate, UIPickerViewDataSource {
                func numberOfComponents(in pickerView: UIPickerView) -> Int {
                    return 1
                }

                func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
                    return categories.count
                }

                func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
                    return categories[row]
                }

                func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                    selectedCategory = categories[row]
                    categoryTextField.text = selectedCategory
                }
            }




#Preview{
    EventPostViewController()
}
