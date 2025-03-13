//
//  QuickAddCell.swift
//  ThriveUp
//
//  Created by palak seth on 08/03/25.
//

import UIKit

class QuickAddCell: UICollectionViewCell {
    static let identifier = "QuickAddCell"
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    let addButton = UIButton() // Changed from `private` to `internal`

    private var addAction: (() -> Void)?

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 150, height: 200)) // Increased size
        setupUI()
    }

    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        layer.cornerRadius = 12
        layer.borderWidth = 1.5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 5
        layer.borderColor = UIColor.lightGray.cgColor
        backgroundColor = .white

        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(profileImageView)

        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)

        addButton.setTitle("ADD", for: .normal)
        addButton.backgroundColor = .systemOrange
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 14
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(addButton)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            addButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            addButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

//    @objc private func addTapped() { addAction?() }
    @objc private func addTapped() {
        addButton.setTitle("Added", for: .normal)
        addButton.backgroundColor = .lightGray
        addButton.setTitleColor(.darkGray, for: .normal)
        addButton.isUserInteractionEnabled = false // Prevents re-clicking
        addAction?()
    }


//    func configure(with user: User, addAction: @escaping () -> Void) {
//        self.addAction = addAction
//        nameLabel.text = user.name
//        profileImageView.image = UIImage(named: "defaultProfile")
//    }
    func configure(with user: User, addAction: @escaping () -> Void) {
        self.addAction = addAction
        nameLabel.text = user.name

        if let imageUrl = user.profileImageURL, let url = URL(string: imageUrl) {
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProfile"))
        } else {
            profileImageView.image = UIImage(named: "defaultProfile")
        }
    }

}

