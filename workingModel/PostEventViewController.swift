//
//  PostEventViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 19/11/24.
//
import UIKit
import FirebaseFirestore
import FirebaseStorage

class PostEventViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Event Details
    private var selectedCategory: String?
    private var selectedImage: UIImage?
    private var selectedLatitude: Double?
    private var selectedLongitude: Double?
    
    // Firestore References
    private let db = Firestore.firestore()
    
    // UI Elements
    private let eventImageView = UIImageView()
    private let titleTextField = UITextField()
    private let categoryButton = UIButton()
    private let organizerNameTextField = UITextField()
    private let dateButton = UIButton()
    private let timeButton = UIButton()
    private let locationTextField = UITextField()
    private let locationDetailsTextField = UITextField()
    private let descriptionTextView = UITextView()
    private let latitudeTextField = UITextField()
    private let longitudeTextField = UITextField()
    private let postButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // Add ScrollView and ContentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Setup Fields
        setupFields()
    }
    
    private func setupFields() {
        // Image View
        eventImageView.backgroundColor = .systemGray5
        eventImageView.layer.cornerRadius = 12
        eventImageView.clipsToBounds = true
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        eventImageView.isUserInteractionEnabled = true
        eventImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eventImageTapped)))
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eventImageView)
        
        // Title Field
        setupTextField(titleTextField, placeholder: "Event Title")
        setupTextField(organizerNameTextField, placeholder: "Organizer Name")
        setupTextField(locationTextField, placeholder: "Location")
        setupTextField(locationDetailsTextField, placeholder: "Location Details")
        setupTextField(latitudeTextField, placeholder: "Latitude (Optional)")
        setupTextField(longitudeTextField, placeholder: "Longitude (Optional)")
        
        // Category Button
        setupButton(categoryButton, title: "Select Category", action: #selector(selectCategory))
        
        // Date Button
        setupButton(dateButton, title: "Select Date", action: #selector(selectDate))
        
        // Time Button
        setupButton(timeButton, title: "Select Time", action: #selector(selectTime))
        
        // Description TextView
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.text = "Description (Optional)"
        descriptionTextView.textColor = .systemGray
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(descriptionTextView)
        
        // Post Button
        postButton.setTitle("Post Event", for: .normal)
        postButton.backgroundColor = .systemOrange
        postButton.layer.cornerRadius = 10
        postButton.setTitleColor(.white, for: .normal)
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.addTarget(self, action: #selector(postEvent), for: .touchUpInside)
        contentView.addSubview(postButton)
        
        // Add Constraints
        NSLayoutConstraint.activate([
            eventImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            eventImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            eventImageView.heightAnchor.constraint(equalToConstant: 160),
            eventImageView.widthAnchor.constraint(equalToConstant: 160),
            
            titleTextField.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            categoryButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 44),
            
            organizerNameTextField.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 16),
            organizerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            organizerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            organizerNameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            dateButton.topAnchor.constraint(equalTo: organizerNameTextField.bottomAnchor, constant: 16),
            dateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateButton.heightAnchor.constraint(equalToConstant: 44),
            
            timeButton.topAnchor.constraint(equalTo: dateButton.bottomAnchor, constant: 16),
            timeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeButton.heightAnchor.constraint(equalToConstant: 44),
            
            locationTextField.topAnchor.constraint(equalTo: timeButton.bottomAnchor, constant: 16),
            locationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            locationTextField.heightAnchor.constraint(equalToConstant: 44),
            
            locationDetailsTextField.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 16),
            locationDetailsTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationDetailsTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            locationDetailsTextField.heightAnchor.constraint(equalToConstant: 44),
            
            latitudeTextField.topAnchor.constraint(equalTo: locationDetailsTextField.bottomAnchor, constant: 16),
            latitudeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            latitudeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            latitudeTextField.heightAnchor.constraint(equalToConstant: 44),
            
            longitudeTextField.topAnchor.constraint(equalTo: latitudeTextField.bottomAnchor, constant: 16),
            longitudeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            longitudeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            longitudeTextField.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionTextView.topAnchor.constraint(equalTo: longitudeTextField.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            postButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24),
            postButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postButton.heightAnchor.constraint(equalToConstant: 50),
            postButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
    }
    
    private func setupButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 8
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        contentView.addSubview(button)
    }
    
    // MARK: - Actions
    @objc private func eventImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc private func selectCategory() {
        let categories = ["Trending", "Fun and Entertainment", "Tech", "Culture", "Networking", "Sports"]
        
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        
        for category in categories {
            alert.addAction(UIAlertAction(title: category, style: .default, handler: { [weak self] _ in
                self?.selectedCategory = category
                self?.categoryButton.setTitle(category, for: .normal)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    
    @objc private func selectDate() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline // Modern inline style
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        let alert = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alert.view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 10),
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -10),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 40),
            datePicker.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            self?.dateButton.setTitle(formatter.string(from: datePicker.date), for: .normal)
        }))
        
        present(alert, animated: true)
    }

    
    @objc private func selectTime() {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels // Traditional wheel style for time selection
        timePicker.translatesAutoresizingMaskIntoConstraints = false

        let alert = UIAlertController(title: "Select Time", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alert.view.addSubview(timePicker)
        
        NSLayoutConstraint.activate([
            timePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 10),
            timePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -10),
            timePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 40),
            timePicker.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            self?.timeButton.setTitle(formatter.string(from: timePicker.date), for: .normal)
        }))
        
        present(alert, animated: true)
    }

    @objc private func postEvent() {
        guard let title = titleTextField.text, !title.isEmpty,
              let category = selectedCategory else {
            showAlert(title: "Error", message: "Title and Category are required.")
            return
        }
        
        // Prepare Event Data
        var eventData: [String: Any] = [
            "title": title,
            "category": category,
            "organizerName": organizerNameTextField.text ?? "",
            "date": dateButton.title(for: .normal) ?? "",
            "time": timeButton.title(for: .normal) ?? "",
            "location": locationTextField.text ?? "",
            "locationDetails": locationDetailsTextField.text ?? "",
            "description": descriptionTextView.text ?? "",
            "latitude": Double(latitudeTextField.text ?? "") ?? 0.0,
            "longitude": Double(longitudeTextField.text ?? "") ?? 0.0
        ]
        
        // Handle Image Upload (if available)
        if let image = selectedImage {
            uploadImageToFirebase(image) { [weak self] imageURL in
                guard let imageURL = imageURL else {
                    self?.showAlert(title: "Error", message: "Failed to upload image.")
                    return
                }
                eventData["imageName"] = imageURL
                self?.saveEventToFirestore(eventData, category: category)
            }
        } else {
            saveEventToFirestore(eventData, category: category)
        }
    }
    
    private func uploadImageToFirebase(_ image: UIImage, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("eventImages/\(UUID().uuidString).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Image upload failed: \(error.localizedDescription)")
                completion(nil)
                return
            }
            imageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }
    
    private func saveEventToFirestore(_ data: [String: Any], category: String) {
        let categoryRef = db.collection("categories").document(category)
        let eventsRef = categoryRef.collection("events")
        
        eventsRef.addDocument(data: data) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to save event: \(error.localizedDescription)")
            } else {
                self?.showAlert(title: "Success", message: "Event successfully posted!")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension PostEventViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            eventImageView.image = image
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate
extension PostEventViewController: UINavigationControllerDelegate {}


