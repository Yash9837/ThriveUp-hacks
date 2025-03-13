//
//  AcceptRequestCardView.swift
//  ThriveUp
//
//  Created by Sanidhya's MacBook Pro on 09/03/25.
//
import UIKit
import FirebaseFirestore

protocol AcceptRequestCardViewDelegate: AnyObject {
    func didAcceptRequest(_ request: AcceptRequest)
    func didRejectRequest(_ request: AcceptRequest)
}

class AcceptRequestCardView: UIView {
    var request: AcceptRequest
    var user: UserDetails?
    weak var delegate: AcceptRequestCardViewDelegate?
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let aboutTitleLabel = UILabel()
    private let aboutLabel = UILabel()
    private let githubTabView = UIView()
    private let linkedInTabView = UIView()
    private let techStackTitleLabel = UILabel()
    private let techStackGridView = UIStackView()
    private let acceptButton = UIButton(type: .system)
    private let rejectButton = UIButton(type: .system)
    private let db = Firestore.firestore()
    
    init(request: AcceptRequest) {
        self.request = request
        super.init(frame: .zero)
        setupViews()
        fetchUserDetails()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 10
        layer.masksToBounds = false
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 40
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.isUserInteractionEnabled = true
        
        nameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        aboutTitleLabel.text = "About"
        aboutTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        aboutTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        aboutLabel.font = UIFont.systemFont(ofSize: 16)
        aboutLabel.numberOfLines = 0
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        
        techStackTitleLabel.text = "Tech Stack"
        techStackTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        techStackTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        techStackGridView.axis = .vertical
        techStackGridView.spacing = 16
        techStackGridView.distribution = .fillEqually
        techStackGridView.translatesAutoresizingMaskIntoConstraints = false
        
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        
        rejectButton.setTitle("Reject", for: .normal)
        rejectButton.addTarget(self, action: #selector(handleReject), for: .touchUpInside)
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(aboutTitleLabel)
        addSubview(aboutLabel)
        addSubview(techStackTitleLabel)
        addSubview(techStackGridView)
        addSubview(acceptButton)
        addSubview(rejectButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            aboutTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            aboutTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            aboutTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            aboutLabel.topAnchor.constraint(equalTo: aboutTitleLabel.bottomAnchor, constant: 8),
            aboutLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            aboutLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            techStackTitleLabel.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 32),
            techStackTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            techStackTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            techStackGridView.topAnchor.constraint(equalTo: techStackTitleLabel.bottomAnchor, constant: 16),
            techStackGridView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            techStackGridView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            acceptButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            acceptButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            rejectButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            rejectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    private func fetchUserDetails() {
        db.collection("users").document(request.senderId).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("No user data found for user \(self?.request.senderId ?? "")")
                return
            }
            
            let id = document.documentID
            let name = data["name"] as? String ?? ""
            let description = data["Description"] as? String ?? "No Description Available"
            let imageUrl = data["profileImageURL"] as? String ?? ""
            let githubUrl = data["githubUrl"] as? String ?? "Not Available"
            let linkedinUrl = data["linkedinUrl"] as? String ?? "Not Available"
            let techStack = data["techStack"] as? String ?? "Unknown"
            let contact = data["ContactDetails"] as? String ?? "Not Available"
            
            self?.user = UserDetails(
                id: id,
                name: name,
                description: description,
                imageUrl: imageUrl,
                contact: contact,
                githubUrl: githubUrl,
                linkedinUrl: linkedinUrl,
                techStack: techStack
            )
            
            DispatchQueue.main.async {
                self?.nameLabel.text = name
                self?.aboutLabel.text = description
                if let url = URL(string: imageUrl) {
                    self?.profileImageView.loadImage(from: url)
                }
                self?.setupTechStack()
            }
        }
    }
    
    private func setupTechStack() {
        techStackGridView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear existing views
        
        guard let techStack = user?.techStack else { return }
        let techStackItems = techStack.components(separatedBy: ", ")
        let columns = 2
        var currentRowStack: UIStackView?
        
        for (index, item) in techStackItems.enumerated() {
            if index % columns == 0 {
                currentRowStack = UIStackView()
                currentRowStack?.axis = .horizontal
                currentRowStack?.spacing = 12
                currentRowStack?.distribution = .fillEqually
                techStackGridView.addArrangedSubview(currentRowStack!)
            }
            
            let button = UIButton(type: .system)
            button.setTitle(item, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.backgroundColor = UIColor.systemGray5
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            
            currentRowStack?.addArrangedSubview(button)
        }
    }
    
    @objc private func handleAccept() {
        delegate?.didAcceptRequest(request)
    }
    
    @objc private func handleReject() {
        delegate?.didRejectRequest(request)
    }
}
