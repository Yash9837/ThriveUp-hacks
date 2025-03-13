//
//  RegisteredEventCell.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 17/11/24.
//
import UIKit

protocol RegisteredEventCellDelegate: AnyObject {
    func didTapUnregister(event: EventModel)
}

class RegisteredEventCell: UITableViewCell {
    
    static let identifier = "RegisteredEventCell"
    
    weak var delegate: RegisteredEventCellDelegate?
    private var currentEvent: EventModel?
    
    // MARK: - UI Elements
    private let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let unregisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("×", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        unregisterButton.addTarget(self, action: #selector(unregisterButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(eventImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(unregisterButton)
        
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        unregisterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Event Image
            eventImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            eventImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            eventImageView.widthAnchor.constraint(equalToConstant: 60),
            eventImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: eventImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: unregisterButton.leadingAnchor, constant: -8),
            
            // Date Label
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: eventImageView.trailingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: unregisterButton.leadingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Unregister Button
            unregisterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            unregisterButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            unregisterButton.widthAnchor.constraint(equalToConstant: 30),
            unregisterButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Configure Cell
    func configure(with event: EventModel) {
        currentEvent = event
        titleLabel.text = event.title
        dateLabel.text = "\(event.date), \(event.time)"
        
        if let imageUrl = URL(string: event.imageName), event.imageName.hasPrefix("http") {
            loadImage(from: imageUrl, into: eventImageView)
        } else {
            eventImageView.image = UIImage(named: event.imageName)
        }
    }
    
    // MARK: - Helper to Load Image
    private func loadImage(from url: URL, into imageView: UIImageView) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "placeholder") // Placeholder image
                }
            }
        }
    }
    
    // MARK: - Button Action
    @objc private func unregisterButtonTapped() {
        guard let event = currentEvent else { return }
        delegate?.didTapUnregister(event: event)
    }
}
