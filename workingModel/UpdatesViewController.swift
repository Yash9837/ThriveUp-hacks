//
//  UpdatesViewController.swift
//  ThriveUp
//
//  Created by Sanidhya's MacBook Pro on 26/01/25.
//

import UIKit
import FirebaseFirestore

class UpdatesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    private var updates: [UpdateModel] = []
    private let db = Firestore.firestore()
    private let eventId: String // The event ID for which updates are being fetched

    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "updateCell")
        return tableView
    }()

    // MARK: - Initializer
    init(eventId: String) {
        self.eventId = eventId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUpdates()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Fetch Updates
    private func fetchUpdates() {
        db.collection("event_updates").whereField("eventId", isEqualTo: eventId).order(by: "timestamp", descending: true).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching updates: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            self.updates = documents.compactMap { doc in
                try? doc.data(as: UpdateModel.self)
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table View DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "updateCell", for: indexPath)
        let update = updates[indexPath.row]
        cell.textLabel?.text = update.content
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: update.timestamp, dateStyle: .short, timeStyle: .short)
        return cell
    }
}

// MARK: - UpdateModel
struct UpdateModel: Codable {
    var eventId: String
    var content: String
    var timestamp: Date
}
