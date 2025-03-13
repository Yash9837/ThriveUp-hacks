//
//  FriendRequestCell.swift
//  ThriveUp
//
//  Created by palak seth on 08/03/25.
//

import UIKit

class FriendRequestCell: UITableViewCell {
    static let identifier = "FriendRequestCell"

    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let acceptButton = UIButton()
    private let rejectButton = UIButton()

    private var acceptAction: (() -> Void)?
    private var rejectAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none

        // Profile Image
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(named: "defaultProfile") // Default placeholder
        contentView.addSubview(profileImageView)

        // Name Label
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        // Username Label
        usernameLabel.font = UIFont.systemFont(ofSize: 14)
        usernameLabel.textColor = .gray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(usernameLabel)

        // Accept Button
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.backgroundColor = .systemOrange
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.layer.cornerRadius = 16
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(acceptButton)

        // Reject Button
        rejectButton.setTitle("✖", for: .normal)
        rejectButton.setTitleColor(.gray, for: .normal)
        rejectButton.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rejectButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Profile Image
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),

            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),

            // Username Label
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            // Accept Button
            acceptButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            acceptButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            acceptButton.widthAnchor.constraint(equalToConstant: 80),
            acceptButton.heightAnchor.constraint(equalToConstant: 32),

            // Reject Button
            rejectButton.trailingAnchor.constraint(equalTo: acceptButton.leadingAnchor, constant: -8),
            rejectButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rejectButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc private func acceptTapped() { acceptAction?() }
    @objc private func rejectTapped() { rejectAction?() }

    func configure(with user: User, acceptAction: @escaping () -> Void, rejectAction: @escaping () -> Void) {
        self.acceptAction = acceptAction
        self.rejectAction = rejectAction
        nameLabel.text = user.name
        usernameLabel.text = user.name ?? "No username"
    }
}
