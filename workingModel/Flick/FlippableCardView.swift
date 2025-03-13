//
//  FlippableCardView.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 11/03/25.
//

import UIKit


class FlippableCardView: UIView, UITableViewDataSource, UITableViewDelegate {
    private var isFlipped = false
    private let frontView = UIView()
    private let backView = UIView()
    private let gradientLayer = CAGradientLayer()
    let event: EventModel

    var bookmarkButton: UIButton?
    var discardButton: UIButton?

    private let detailItems: [(String, String)]

    init(event: EventModel) {
        self.event = event
        self.detailItems = [
            ("calendar", event.date),
            ("clock", event.time),
            ("location", event.location),
            ("person.2", "Organizer: \(event.organizerName)"),
            ("text.bubble", event.description ?? "No description available.")
        ]
        
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = backView.bounds
    }

    private func setupViews() {
        setupFrontView()
        setupBackView()

        addSubview(frontView)
        addSubview(backView)

        frontView.translatesAutoresizingMaskIntoConstraints = false
        backView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            frontView.topAnchor.constraint(equalTo: topAnchor),
            frontView.leadingAnchor.constraint(equalTo: leadingAnchor),
            frontView.trailingAnchor.constraint(equalTo: trailingAnchor),
            frontView.bottomAnchor.constraint(equalTo: bottomAnchor),

            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        backView.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        addGestureRecognizer(tapGesture)
    }

    private func setupFrontView() {
        frontView.backgroundColor = .white
        frontView.layer.cornerRadius = 20
        frontView.layer.shadowColor = UIColor.black.cgColor
        frontView.layer.shadowOpacity = 0.3
        frontView.layer.shadowOffset = CGSize(width: 0, height: 5)
        frontView.layer.shadowRadius = 10
        frontView.layer.masksToBounds = false

        let imageView = UIImageView(image: UIImage(named: event.imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        frontView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: frontView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: frontView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: frontView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: frontView.bottomAnchor)
        ])
        // Load image from URL
           if let imageUrl = URL(string: event.imageName) {
               imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(systemName: "photo"))
           } else {
               imageView.image = UIImage(systemName: "photo") // Fallback image
           }
    }

    private func setupBackView() {
        backView.backgroundColor = .clear
        backView.layer.cornerRadius = 20
        backView.layer.masksToBounds = true

        gradientLayer.colors = [UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 20
        backView.layer.insertSublayer(gradientLayer, at: 0)

        let titleLabel = UILabel()
        titleLabel.text = event.title
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 20
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.delegate = self
        tableView.dataSource = self
                tableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")

                backView.addSubview(titleLabel)
                backView.addSubview(tableView)

                NSLayoutConstraint.activate([
                    titleLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: 32),
                    titleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16),
                    titleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16),

                    tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
                    tableView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16),
                    tableView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16),
                    tableView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -16)
                ])
            }

            @objc private func flipCard() {
                let fromView = isFlipped ? backView : frontView
                let toView = isFlipped ? frontView : backView

                UIView.transition(from: fromView, to: toView, duration: 0.6, options: [.transitionFlipFromLeft, .showHideTransitionViews]) { [weak self] _ in
                    self?.isFlipped.toggle()
                }
            }

            func numberOfSections(in tableView: UITableView) -> Int {
                return detailItems.count
            }

            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return 1
            }

            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as? DetailCell else {
                    return UITableViewCell()
                }

                let item = detailItems[indexPath.section]
                cell.configure(iconName: item.0, detail: item.1)

                return cell
            }

            func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
                switch section {
                case 0:
                    return "Date"
                case 1:
                    return "Time"
                case 2:
                    return "Location"
                case 3:
                    return "Organizer"
                case 4:
                    return "Description"
                default:
                    return nil
                }
            }
        }

        class DetailCell: UITableViewCell {
            private let iconImageView = UIImageView()
            private let detailLabel = UILabel()

            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                setupViews()
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            private func setupViews() {
                backgroundColor = .clear

                // Ensure iconImageView is properly initialized
                iconImageView.tintColor = .white
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(iconImageView)

                detailLabel.font = UIFont.preferredFont(forTextStyle: .body)
                detailLabel.textColor = .label
                detailLabel.numberOfLines = 0
                detailLabel.translatesAutoresizingMaskIntoConstraints = false
                addSubview(detailLabel)

                // Ensure layout constraints are applied after adding subviews
                NSLayoutConstraint.activate([
                    iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                    iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                    iconImageView.widthAnchor.constraint(equalToConstant: 24),
                    iconImageView.heightAnchor.constraint(equalToConstant: 24),

                    detailLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
                    detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                    detailLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                    detailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
                ])
            }

            // Ensure `iconImageView.image` is set properly
            func configure(iconName: String, detail: String) {
                if let image = UIImage(systemName: iconName) {
                    iconImageView.image = image
                } else {
                    print("Error: Image not found for iconName \(iconName)")
                }
                detailLabel.text = detail
            }

            
        }
