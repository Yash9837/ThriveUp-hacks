//
//  UpdateCell.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 18/11/24.
//
//
//import UIKit
//
//class UpdateCell: UITableViewCell {
//    static let identifier = "UpdateCell"
//    
//    private let updateLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let timestampLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 12)
//        label.textColor = .gray
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.addSubview(updateLabel)
//        contentView.addSubview(timestampLabel)
//        NSLayoutConstraint.activate([
//            updateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            updateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            updateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            
//            timestampLabel.topAnchor.constraint(equalTo: updateLabel.bottomAnchor, constant: 4),
//            timestampLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
//        ])
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(with update: String, timestamp: String) {
//        updateLabel.text = update
//        timestampLabel.text = timestamp
//    }
//}
