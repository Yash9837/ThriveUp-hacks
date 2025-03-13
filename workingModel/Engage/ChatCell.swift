import UIKit

class ChatCell: UITableViewCell {
    static let identifier = "ChatCell"

    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let separatorLine = UIView() // Separator to match UI

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .white

        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(messageLabel)
        addSubview(timeLabel)
        addSubview(separatorLine)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false

        // Profile Image Styling
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.image = UIImage(named: "defaultProfileImage") // Placeholder image

        // Name Label Styling
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor = .black

        // Message Label Styling
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 1

        // Time Label Styling
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor = .lightGray

        // Separator Styling
        separatorLine.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0)


        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),

            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),

            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    func configure(with name: String, message: String, time: String, profileImageURL: String?) {
        nameLabel.text = name
        messageLabel.text = message
        timeLabel.text = time

        if let urlString = profileImageURL, let url = URL(string: urlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        } else {
            profileImageView.image = UIImage(named: "defaultProfileImage")
        }
    }
}

#Preview{
    ChatCell()
}
