//
//  AcceptRequestViewController.swift
//  ThriveUp
//
//  Created by Sanidhya's MacBook Pro on 09/03/25.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol AcceptRequestsDelegate: AnyObject {
    func didAcceptRequest(_ request: AcceptRequest)
    func didRejectRequest(_ request: AcceptRequest)
}

class AcceptRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AcceptRequestCardViewDelegate {
    var acceptRequests: [AcceptRequest] = []
    weak var delegate: AcceptRequestsDelegate?
    
    private let tableView = UITableView()
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Accept Requests"
        setupTableView()
        fetchAcceptRequests()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AcceptRequestCell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func fetchAcceptRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        db.collection("accept_requests")
            .whereField("receiverId", isEqualTo: currentUserId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching accept requests: \(error.localizedDescription)")
                    return
                }
                
                var fetchedRequests: [AcceptRequest] = []
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    let senderId = data["senderId"] as? String ?? ""
                    let receiverId = data["receiverId"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
                    let request = AcceptRequest(id: document.documentID, senderId: senderId, receiverId: receiverId, timestamp: timestamp.dateValue())
                    fetchedRequests.append(request)
                }
                self?.acceptRequests = fetchedRequests
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acceptRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AcceptRequestCell", for: indexPath)
        let request = acceptRequests[indexPath.row]
        cell.textLabel?.text = "Request from \(request.senderId)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = acceptRequests[indexPath.row]
        let acceptRequestCardView = AcceptRequestCardView(request: request)
        acceptRequestCardView.delegate = self
        acceptRequestCardView.translatesAutoresizingMaskIntoConstraints = false
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertController.view.addSubview(acceptRequestCardView)
        
        NSLayoutConstraint.activate([
            acceptRequestCardView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20),
            acceptRequestCardView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20),
            acceptRequestCardView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20),
            acceptRequestCardView.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -20)
        ])
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { _ in
            self.didAcceptRequest(request)
        }
        
        let rejectAction = UIAlertAction(title: "Reject", style: .destructive) { _ in
            self.didRejectRequest(request)
        }
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(acceptAction)
        alertController.addAction(rejectAction)
        alertController.addAction(closeAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func didAcceptRequest(_ request: AcceptRequest) {
        delegate?.didAcceptRequest(request)
        navigationController?.popViewController(animated: true)
    }

    func didRejectRequest(_ request: AcceptRequest) {
        delegate?.didRejectRequest(request)
        navigationController?.popViewController(animated: true)
    }
}
