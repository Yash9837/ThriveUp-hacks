/*import UIKit
import FirebaseStorage

class NotificationCell: UITableViewCell {
    static let identifier = "NotificationCell"

    private let userImageView = UIImageView()
    private let nameLabel = UILabel()
    private let timestampLabel = UILabel()
    private let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Configure container view
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 10
        contentView.addSubview(containerView)

        // Configure image view
        userImageView.layer.cornerRadius = 25
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor.systemGray5.cgColor
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill
        containerView.addSubview(userImageView)

        // Configure name label
        nameLabel.font = UIFont.systemFont(ofSize: 14) // Decreased font size
        nameLabel.numberOfLines = 0 // Allow multiple lines
        containerView.addSubview(nameLabel)

        // Configure timestamp label
        timestampLabel.font = UIFont.systemFont(ofSize: 12) // Decreased font size
        timestampLabel.textColor = .systemGray
        timestampLabel.textAlignment = .right
        containerView.addSubview(timestampLabel)

        // Layout constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Image view constraints
            userImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            userImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.heightAnchor.constraint(equalToConstant: 50),

            // Timestamp label constraints (aligned to the right)
            timestampLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            timestampLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            
            // Name label constraints
            nameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: timestampLabel.leadingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with notification: NotificationItem) {
        nameLabel.text = "\(notification.name) has sent a message"
        timestampLabel.text = timeAgoSinceDate(notification.timestamp)
        fetchProfileImage(urlString: notification.profileImageURL)
    }

    private func fetchProfileImage(urlString: String) {
        let storageRef = Storage.storage().reference(forURL: urlString)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error fetching profile image: \(error)")
                self.userImageView.image = UIImage(named: "placeholder")
                return
            }
            guard let data = data else {
                self.userImageView.image = UIImage(named: "placeholder")
                return
            }
            self.userImageView.image = UIImage(data: data)
        }
    }

    private func timeAgoSinceDate(_ date: Date, numericDates: Bool = false) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components: DateComponents = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: earliest, to: latest)
        
        if let year = components.year, year >= 2 {
            return "\(year) years ago"
        } else if let year = components.year, year >= 1 {
            if numericDates {
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if let month = components.month, month >= 2 {
            return "\(month) months ago"
        } else if let month = components.month, month >= 1 {
            if numericDates {
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks ago"
        } else if let week = components.weekOfYear, week >= 1 {
            if numericDates {
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if let day = components.day, day >= 2 {
            return "\(day) days ago"
        } else if let day = components.day, day >= 1 {
            if numericDates {
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        } else if let hour = components.hour, hour >= 1 {
            if numericDates {
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes ago"
        } else if let minute = components.minute, minute >= 1 {
            if numericDates {
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else {
            return "Just now"
        }
    }
}*/
