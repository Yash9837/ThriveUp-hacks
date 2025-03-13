//
//  SavedRegistrationViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 19/11/24.
//

import UIKit

class SavedRegistrationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
        private var registrations: [Registration] = [] // Array to store registration data
        
        private let tableView = UITableView()
        private let downloadButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Download File", for: .normal)
            button.backgroundColor = .systemOrange
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        private let totalRegistrationsLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Total Number of Registration: 0" // Default text
            return label
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .white
            title = "Registrations"
            
            setupViews()
            setupConstraints()
            loadData() // Load data from the data model
        }
        
        // View Setup
        private func setupViews() {
            tableView.register(SavedRegistrationCell.self, forCellReuseIdentifier: "RegistrationCell")
            tableView.dataSource = self
            tableView.delegate = self
            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)
            
            // Add total registrations label and download button
            view.addSubview(totalRegistrationsLabel)
            view.addSubview(downloadButton)
            
            // Add target action for download button
            downloadButton.addTarget(self, action: #selector(downloadFile), for: .touchUpInside)
        }
        
        // Constraints Setup
        private func setupConstraints() {
            NSLayoutConstraint.activate([
                totalRegistrationsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                totalRegistrationsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                tableView.topAnchor.constraint(equalTo: totalRegistrationsLabel.bottomAnchor, constant: 8),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: downloadButton.topAnchor, constant: -16),
                
                downloadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                downloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                downloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                downloadButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        // Load Data from the Data Model
        private func loadData() {
            // Load sample data from RegistrationDataSource
            registrations = RegistrationDataSource.sampleRegistrations
            totalRegistrationsLabel.text = "Total Number of Registration: \(registrations.count)"
            
            // Reload table view to reflect new data
            tableView.reloadData()
        }
        
        // Action for Download Button
        @objc private func downloadFile() {
            // Implement download file functionality here
            print("Download button pressed.")
        }
        
        // MARK: - UITableViewDataSource
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return registrations.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegistrationCell", for: indexPath) as! SavedRegistrationCell
            let registration = registrations[indexPath.row]
            cell.configure(with: registration)
            return cell
        }
    }
