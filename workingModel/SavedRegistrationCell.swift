//
//  RegistrationCell.swift
//  ThriveUp
//
//  Created by palak seth on 16/11/24.
//

import UIKit

class SavedRegistrationCell: UITableViewCell {
    
    private let serialNumberLabel = UILabel()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let yearLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        serialNumberLabel.font = UIFont.systemFont(ofSize: 16)
        serialNumberLabel.textAlignment = .center
        
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        yearLabel.font = UIFont.systemFont(ofSize: 16)
        yearLabel.textAlignment = .center
        
        // Add subviews to content view
        contentView.addSubview(serialNumberLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(yearLabel)
    }
    
    private func setupConstraints() {
        serialNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            serialNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            serialNumberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            serialNumberLabel.widthAnchor.constraint(equalToConstant: 30),
            
            profileImageView.leadingAnchor.constraint(equalTo: serialNumberLabel.trailingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            yearLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            yearLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configure(with registration: Registration) {
        serialNumberLabel.text = "\(registration.serialNumber)"
        profileImageView.image = registration.profileImage
        nameLabel.text = registration.name
        yearLabel.text = registration.year
    }
}


