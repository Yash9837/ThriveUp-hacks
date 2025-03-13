//
//  EventCell.swift
//  workingModel
//
//  Created by Yash's Mackbook on 12/11/24.
//

import UIKit

class EventCell: UICollectionViewCell {
    static let identifier = "EventCell"
    
    private let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(eventImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        // Set up constraints
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            eventImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            eventImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            eventImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            eventImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = .white

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with event: EventModel) {
        // Set the image
        if let imageURL = URL(string: event.imageName), !event.imageName.isEmpty, event.imageName.hasPrefix("http") {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.eventImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.eventImageView.image = UIImage(named: "placeholder")
                    }
                }
            }
        } else if !event.imageName.isEmpty {
            eventImageView.image = UIImage(named: event.imageName) ?? UIImage(named: "placeholder")
        } else {
            eventImageView.image = UIImage(named: "placeholder")
        }
        
        // Set title and date
        titleLabel.text = event.title
        dateLabel.text = event.date
    }
}
