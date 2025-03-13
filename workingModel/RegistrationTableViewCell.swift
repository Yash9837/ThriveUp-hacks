//
//  RegistrationTableViewCell.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 09/01/25.
//

import UIKit

class RegistrationTableViewCell: UITableViewCell {
    
    static let identifier = "RegistrationTableViewCell"
    
    // MARK: - UI Components
    private let serialNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 2 // Allow multiline for long emails
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(serialNumberLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(yearLabel)
        
        serialNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Serial Number
            serialNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            serialNumberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            serialNumberLabel.widthAnchor.constraint(equalToConstant: 50),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: serialNumberLabel.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 100),
            
            // Email Label
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            emailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emailLabel.widthAnchor.constraint(equalToConstant: 150),
            
            // Year Label
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            yearLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            yearLabel.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Configure Cell
    func configure(with registration: [String: Any], index: Int) {
        serialNumberLabel.text = "\(index + 1)"
        nameLabel.text = registration["Name"] as? String ?? "N/A"
        emailLabel.text = registration["email"] as? String ?? "N/A"
        let yearOfStudy = registration["Year of Study"] as? String ?? "N/A"
        yearLabel.text = formatYear(yearOfStudy)
    }
    
    private func formatYear(_ year: String) -> String {
        switch year {
        case "1":
            return "1st Year"
        case "2":
            return "2nd Year"
        case "3":
            return "3rd Year"
        case "4":
            return "4th Year"
        default:
            return year
        }
    }
}
