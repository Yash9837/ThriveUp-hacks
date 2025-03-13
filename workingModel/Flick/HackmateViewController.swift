//
//  HackmateViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 11/03/25.
import UIKit
import FirebaseFirestore
import FirebaseAuth
import Foundation

struct Hackmate: Codable {
    let id: String
    let user1: String
    let user2: String
    let timestamp: Date
}
struct HackmateRequest: Codable {
    let id: String
    let senderId: String
    let receiverId: String
    let timestamp: Date

    func toAcceptRequest() -> AcceptRequest {
        return AcceptRequest(id: id, senderId: senderId, receiverId: receiverId, timestamp: timestamp)
    }
}
class HackmateViewController: UIViewController {
    private var hackmateRequests: [HackmateRequest] = []
    private var hackmates: [UserDetails] = []
    private let db = Firestore.firestore()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(HackmateCell.self, forCellReuseIdentifier: "HackmateCell")
        return table
    }()
    
    private let requestsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hackmate Requests", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(openRequestsView), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hackmates"
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(requestsButton)
        view.addSubview(tableView)
        
        setupLayout()
        fetchHackmates()
    }
    
    private func setupLayout() {
        requestsButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            requestsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            requestsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            requestsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            requestsButton.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: requestsButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func openRequestsView() {
        let requestsVC = HackmateRequestsViewController()
        navigationController?.pushViewController(requestsVC, animated: true)
    }
    
    private func fetchHackmates() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("hackmates")
            .whereField("user1", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching hackmates: \(error.localizedDescription)")
                    return
                }
                
                let userIds = snapshot?.documents.compactMap { $0.data()["user2"] as? String } ?? []
                self.fetchUserDetails(userIds: userIds)
            }
    }
    
    private func fetchUserDetails(userIds: [String]) {
            guard !userIds.isEmpty else { return }
            
            db.collection("users").whereField(FieldPath.documentID(), in: userIds).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching user details: \(error.localizedDescription)")
                    return
                }
                
                self.hackmates = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    return UserDetails(
                        id: document.documentID,
                        name: data["name"] as? String ?? "Unknown",
                        description: data["Description"] as? String ?? "",
                        imageUrl: data["profileImageURL"] as? String ?? "", contact: data["ContactDetails"] as? String ?? "",
                        techStack: data["techStack"] as? String ?? ""
                    )
                } ?? []
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }}

extension HackmateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hackmates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HackmateCell", for: indexPath) as! HackmateCell
        let user = hackmates[indexPath.row]
        cell.configure(with: user)
        return cell
    }
}

class HackmateCell: UITableViewCell {
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let stackView = UIStackView(arrangedSubviews: [profileImageView, nameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with user: UserDetails) {
        nameLabel.text = user.name
        if let url = URL(string: user.imageUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
