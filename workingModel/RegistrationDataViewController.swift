//
//  RegistrationDataViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 17/11/24.
//

import UIKit

class RegistrationDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private var registrationData: [String: [[String: String]]] = [:] // Stores data loaded from file
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Stored Registrations"
        
        setupTableView()
        loadRegistrationData()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DataCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func loadRegistrationData() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("RegistrationData.json")
            if let existingData = try? Data(contentsOf: fileURL),
               let existingEventData = try? JSONSerialization.jsonObject(with: existingData, options: []) as? [String: [[String: String]]] {
                self.registrationData = existingEventData
            } else {
                print("No existing data found or failed to load.")
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return registrationData.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let eventIds = Array(registrationData.keys)
        let eventId = eventIds[section]
        return registrationData[eventId]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath)
        let eventIds = Array(registrationData.keys)
        let eventId = eventIds[indexPath.section]
        if let dataArray = registrationData[eventId] {
            let dataEntry = dataArray[indexPath.row]
            let dataText = dataEntry.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            cell.textLabel?.text = dataText
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let eventIds = Array(registrationData.keys)
        return "Event ID: \(eventIds[section])"
    }
}

