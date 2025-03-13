//
//  RegistrationsListViewController.swift
//  ThriveUp
//

import UIKit
import FirebaseFirestore

class RegistrationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    private var registrations: [[String: Any]] = [] // Holds fetched registrations data
    private let eventId: String
    private let db = Firestore.firestore()
    
    // MARK: - UI Components
    private let registrationsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RegistrationTableViewCell.self, forCellReuseIdentifier: RegistrationTableViewCell.identifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        return tableView
    }()
    
    private let totalCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20) // Larger font size
        label.textColor = .orange // Standard black text color
        label.textAlignment = .center // Center aligned text
        label.text = "Total Registrations: 0" // Default text
        return label
    }()



    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download File", for: .normal)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Initializer
    init(eventId: String) {
        self.eventId = eventId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTableHeader() // Setup for headings
        fetchRegistrations()
        downloadButton.addTarget(self, action: #selector(handleDownload), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Registrations"
        view.backgroundColor = .white
        view.addSubview(totalCountLabel)
        view.addSubview(registrationsTableView)
        view.addSubview(downloadButton)
        
        registrationsTableView.delegate = self
        registrationsTableView.dataSource = self
    }
    
    private func setupConstraints() {
        totalCountLabel.translatesAutoresizingMaskIntoConstraints = false
        registrationsTableView.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Total Count Label
            totalCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16), // Space from top
            totalCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            totalCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // TableView
            registrationsTableView.topAnchor.constraint(equalTo: totalCountLabel.bottomAnchor, constant: 16), // Increased spacing here
            registrationsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            registrationsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            registrationsTableView.bottomAnchor.constraint(equalTo: downloadButton.topAnchor, constant: -16),
            
            // Download Button
            downloadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            downloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            downloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            downloadButton.heightAnchor.constraint(equalToConstant: 50)
        ])


    }
    
    private func setupTableHeader() {
        // Create the table header view
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        headerView.backgroundColor = UIColor.systemGray6
        
        let headers = ["S.No", "Name", "Email", "Year"]
        let headerWidth = view.frame.width / CGFloat(headers.count)
        
        for (index, title) in headers.enumerated() {
            let label = UILabel(frame: CGRect(x: CGFloat(index) * headerWidth, y: 0, width: headerWidth, height: 40))
            label.text = title
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textColor = .black
            label.textAlignment = .center
            headerView.addSubview(label)
        }
        
        registrationsTableView.tableHeaderView = headerView
    }
    
    // MARK: - Fetch Registrations
    private func fetchRegistrations() {
        db.collection("registrations")
            .whereField("eventId", isEqualTo: eventId)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching registrations: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No registrations found for event \(self.eventId)")
                    return
                }
                
                self.registrations = documents.map { $0.data() }
                DispatchQueue.main.async {
                    self.totalCountLabel.text = "Total Number of Registrations: \(self.registrations.count)"
                    self.registrationsTableView.reloadData()
                }
            }
    }
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registrations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RegistrationTableViewCell.identifier, for: indexPath) as! RegistrationTableViewCell
        let registration = registrations[indexPath.row]
        cell.configure(with: registration, index: indexPath.row)
        return cell
    }
    
    // MARK: - Download Button Action
    @objc private func handleDownload() {
        let csvData = generateCSVData()
        let fileName = "registrations_event_\(eventId).csv"
        
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvData.write(to: tempURL, atomically: true, encoding: .utf8)
            let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            present(activityViewController, animated: true)
        } catch {
            print("Error writing CSV file: \(error.localizedDescription)")
        }
    }
    
    private func generateCSVData() -> String {
        var csvString = "S.No,Name,Email,Year\n" // Header row
        
        for (index, registration) in registrations.enumerated() {
            let serialNumber = index + 1
            let name = registration["Name"] as? String ?? "N/A"
            let email = registration["email"] as? String ?? "N/A"
            let year = registration["Year of Study"] as? String ?? "N/A"
            
            csvString += "\(serialNumber),\"\(name)\",\"\(email)\",\"\(year)\"\n"
        }
        
        return csvString
    }
}
