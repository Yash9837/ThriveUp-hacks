//
//  HackmateRequestsViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 11/03/25.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class HackmateRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var requests: [UserDetails] = []
    private let db = Firestore.firestore()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hackmate Requests"
        view.backgroundColor = .white

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HackmateRequestCell.self, forCellReuseIdentifier: "HackmateRequestCell")
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.frame = view.bounds
        fetchRequests()
    }

    private func fetchRequests() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("hackmate_requests")
            .whereField("receiverId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching hackmate requests: \(error.localizedDescription)")
                    return
                }

                let userIds = snapshot?.documents.compactMap { $0.data()["senderId"] as? String } ?? []
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

            self.requests = snapshot?.documents.compactMap { document in
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
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HackmateRequestCell", for: indexPath) as! HackmateRequestCell
        let user = requests[indexPath.row]
        cell.configure(with: user)
        return cell
    }

    // MARK: - Swipe Actions for Accept & Reject
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = requests[indexPath.row]

        // Reject Action (Swipe Left)
        let rejectAction = UIContextualAction(style: .destructive, title: "Reject") { _, _, completionHandler in
            self.rejectRequest(user: user)
            completionHandler(true)
        }
        rejectAction.backgroundColor = .red

        return UISwipeActionsConfiguration(actions: [rejectAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = requests[indexPath.row]

        // Accept Action (Swipe Right)
        let acceptAction = UIContextualAction(style: .normal, title: "Accept") { _, _, completionHandler in
            self.acceptRequest(user: user)
            completionHandler(true)
        }
        acceptAction.backgroundColor = .green

        return UISwipeActionsConfiguration(actions: [acceptAction])
    }

    private func acceptRequest(user: UserDetails) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        // First, find the request document ID
        db.collection("hackmate_requests")
            .whereField("receiverId", isEqualTo: userId)
            .whereField("senderId", isEqualTo: user.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error finding request document: \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("No matching request document found")
                    return
                }
                
                let requestDocID = document.documentID // ✅ Correct document ID

                // 🔥 Now update status instead of deleting the request
                self.db.collection("hackmate_requests").document(requestDocID)
                    .updateData(["status": "accepted"]) { err in
                        if let err = err {
                            print("Error updating request status: \(err.localizedDescription)")
                        } else {
                            print("Hackmate request accepted successfully!")
                            self.requests.removeAll { $0.id == user.id } // Remove from UI
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
            }
    }


    private func rejectRequest(user: UserDetails) {
        db.collection("hackmate_requests").document(user.id).delete() { error in
            if let error = error {
                print("Error rejecting request: \(error.localizedDescription)")
                return
            }
            print("Hackmate request rejected")
            self.requests.removeAll { $0.id == user.id }  // Remove from array
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

}

// MARK: - Custom TableView Cell
class HackmateRequestCell: UITableViewCell {
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
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
        stackView.distribution = .fill

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
