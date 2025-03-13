//
//  TicketViewController.swift
//  ThriveUp
//
//  Created by palak seth on 23/01/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SDWebImage

class TicketViewController: UIViewController {
    // MARK: - Properties
    var eventId: String? // Passed from ProfileViewController
    var eventDetails: [String: Any]? // Event details fetched from Firestore

    private let ticketContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 6
        return view
    }()
    
    private let headerBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Rounded only on the top
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()
    
    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "Date and Time"
        label.numberOfLines = 2
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Location"
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4
        return view
    }()
    
    private let qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let barcodeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        setupUI()
        fetchTicketDetails()
        fetchEventDetails()
        fetchUserName()
    }
    
    private func setupUI() {
        view.addSubview(ticketContainerView)
        ticketContainerView.addSubview(headerBackgroundImageView)
        ticketContainerView.addSubview(userNameLabel)
        ticketContainerView.addSubview(titleLabel)
        ticketContainerView.addSubview(dateTimeLabel)
        ticketContainerView.addSubview(locationLabel)
        ticketContainerView.addSubview(separatorView)
        ticketContainerView.addSubview(qrImageView)
        ticketContainerView.addSubview(barcodeLabel)
        
        // Constraints
        ticketContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        barcodeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            ticketContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ticketContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ticketContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            ticketContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75), // Adjusted height
            
            headerBackgroundImageView.topAnchor.constraint(equalTo: ticketContainerView.topAnchor),
            headerBackgroundImageView.leadingAnchor.constraint(equalTo: ticketContainerView.leadingAnchor),
            headerBackgroundImageView.trailingAnchor.constraint(equalTo: ticketContainerView.trailingAnchor),
            headerBackgroundImageView.heightAnchor.constraint(equalTo: ticketContainerView.heightAnchor, multiplier: 0.3),
            
            userNameLabel.topAnchor.constraint(equalTo: headerBackgroundImageView.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: ticketContainerView.leadingAnchor, constant: 16),
            userNameLabel.trailingAnchor.constraint(equalTo: ticketContainerView.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: ticketContainerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: ticketContainerView.trailingAnchor, constant: -16),
            
            dateTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            dateTimeLabel.leadingAnchor.constraint(equalTo: ticketContainerView.leadingAnchor, constant: 16),
            dateTimeLabel.trailingAnchor.constraint(equalTo: ticketContainerView.trailingAnchor, constant: -16),
            
            locationLabel.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: ticketContainerView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: ticketContainerView.trailingAnchor, constant: -16),
            
            separatorView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            separatorView.leadingAnchor.constraint(equalTo: ticketContainerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: ticketContainerView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            qrImageView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),
            qrImageView.centerXAnchor.constraint(equalTo: ticketContainerView.centerXAnchor),
            qrImageView.widthAnchor.constraint(equalTo: ticketContainerView.widthAnchor, multiplier: 0.6),
            qrImageView.heightAnchor.constraint(equalTo: qrImageView.widthAnchor),
            
            barcodeLabel.topAnchor.constraint(equalTo: qrImageView.bottomAnchor, constant: 8),
            barcodeLabel.leadingAnchor.constraint(equalTo: ticketContainerView.leadingAnchor, constant: 16),
            barcodeLabel.trailingAnchor.constraint(equalTo: ticketContainerView.trailingAnchor, constant: -16),
            barcodeLabel.bottomAnchor.constraint(equalTo: ticketContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func fetchTicketDetails() {
        guard let eventId = eventId, let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("registrations")
            .whereField("eventId", isEqualTo: eventId)
            .whereField("uid", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching ticket details: \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("No ticket details found.")
                    return
                }
                
                self?.updateTicketDetails(document.data())
            }
    }
    
    private func fetchEventDetails() {
        guard let eventId = eventId else { return }
        
        let db = Firestore.firestore()
        db.collection("events").document(eventId).getDocument { [weak self] document, error in
            guard let self = self, let data = document?.data(), error == nil else {
                print("Error fetching event details: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.eventDetails = data
                self.titleLabel.text = data["title"] as? String ?? "Event Title"
                self.dateTimeLabel.text = "Date: \(data["date"] as? String ?? "Unknown")\nTime: \(data["time"] as? String ?? "Unknown")"
                self.locationLabel.text = "Location: \(data["location"] as? String ?? "Unknown")"
                
                // Load event image for header background
                if let imageUrl = data["imageName"] as? String {
                    self.headerBackgroundImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: nil)
                }
            }
        }
    }
    
    private func fetchUserName() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self, let data = document?.data(), error == nil else {
                print("Error fetching user name: \(error?.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.userNameLabel.text = data["name"] as? String ?? "User Name"
            }
        }
    }
    
    private func updateTicketDetails(_ details: [String: Any]) {
        DispatchQueue.main.async {
            if let qrCodeBase64 = details["qrCode"] as? String,
               let qrCodeData = Data(base64Encoded: qrCodeBase64),
               let qrImage = UIImage(data: qrCodeData) {
                self.qrImageView.image = qrImage
            }
            
//            self.barcodeLabel.text = "QR Data: \(details["qrCode"] as? String ?? "Unknown")"
        }
    }
}
