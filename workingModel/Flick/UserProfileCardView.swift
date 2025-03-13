//
//  UserProfileCardView.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 11/03/25.
//

import UIKit
import Instructions
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class UserProfileCardView: UIView {
    var user: UserDetails
    var bookmarkButton: UIButton?
    var discardButton: UIButton?
    var profileImageView: UIImageView!
    var nameLabel: UILabel!
    var aboutTitleLabel: UILabel!
    var aboutLabel: UILabel!
    var githubTabView: UIView!
    var linkedInTabView: UIView!
    var socialProfilesTitleLabel: UILabel!
    var techStackTitleLabel: UILabel!
    var techStackView: UIView!
    var techStackGridView: UIStackView!
    private let db = Firestore.firestore()

    init(user: UserDetails) {
        self.user = user
        super.init(frame: .zero)
        setupViews()
        fetchUserDetails()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 10
        layer.masksToBounds = false

        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 40
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.isUserInteractionEnabled = true

        if let url = URL(string: user.imageUrl) {
            profileImageView.loadImage(from: url)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(enlargeProfileImage))
        profileImageView.addGestureRecognizer(tapGesture)

        nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        aboutTitleLabel = UILabel()
        aboutTitleLabel.text = "About"
        aboutTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        aboutTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        aboutLabel = UILabel()
        aboutLabel.font = UIFont.systemFont(ofSize: 16)
        aboutLabel.numberOfLines = 0
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false

        socialProfilesTitleLabel = UILabel()
        socialProfilesTitleLabel.text = "Social Profiles"
        socialProfilesTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        socialProfilesTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        githubTabView = createTabView(iconName: "logo.github", title: "GitHub", url: user.githubUrl ?? "")
        linkedInTabView = createTabView(iconName: "logo.linkedin", title: "LinkedIn", url: user.linkedinUrl ?? "")

        techStackTitleLabel = UILabel()
        techStackTitleLabel.text = "Tech Stack"
        techStackTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        techStackTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        techStackView = UIView()
        techStackView.translatesAutoresizingMaskIntoConstraints = false

        techStackGridView = UIStackView()
        techStackGridView.axis = .vertical
        techStackGridView.spacing = 16
        techStackGridView.distribution = .fillEqually
        techStackGridView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(aboutTitleLabel)
        addSubview(aboutLabel)
        addSubview(socialProfilesTitleLabel)
        addSubview(githubTabView)
        addSubview(linkedInTabView)
        addSubview(techStackTitleLabel)
        addSubview(techStackView)
        techStackView.addSubview(techStackGridView)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            aboutTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            aboutTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            aboutTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            aboutLabel.topAnchor.constraint(equalTo: aboutTitleLabel.bottomAnchor, constant: 8),
            aboutLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            aboutLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            socialProfilesTitleLabel.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 16),
            socialProfilesTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            socialProfilesTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            githubTabView.topAnchor.constraint(equalTo: socialProfilesTitleLabel.bottomAnchor, constant: 8),
            githubTabView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            githubTabView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            githubTabView.heightAnchor.constraint(equalToConstant: 44),

            linkedInTabView.topAnchor.constraint(equalTo: githubTabView.bottomAnchor, constant: 8),
            linkedInTabView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            linkedInTabView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            linkedInTabView.heightAnchor.constraint(equalToConstant: 44),

            techStackTitleLabel.topAnchor.constraint(equalTo: linkedInTabView.bottomAnchor, constant: 32),
            techStackTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            techStackTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            techStackView.topAnchor.constraint(equalTo: techStackTitleLabel.bottomAnchor, constant: 4),
            techStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            techStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            techStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            techStackGridView.topAnchor.constraint(equalTo: techStackView.topAnchor),
            techStackGridView.leadingAnchor.constraint(equalTo: techStackView.leadingAnchor),
            techStackGridView.trailingAnchor.constraint(equalTo: techStackView.trailingAnchor),
            techStackGridView.bottomAnchor.constraint(equalTo: techStackView.bottomAnchor)
        ])

        setupTechStack()
    }

    private func setupTechStack() {
        techStackGridView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear existing views

        let techStackItems = user.techStack.components(separatedBy: ", ")
        let columns = 2
        var currentRowStack: UIStackView?

        for (index, item) in techStackItems.enumerated() {
            if index % columns == 0 {
                currentRowStack = UIStackView()
                currentRowStack?.axis = .horizontal
                currentRowStack?.spacing = 12
                currentRowStack?.distribution = .fillEqually
                techStackGridView.addArrangedSubview(currentRowStack!)
            }

            let button = UIButton(type: .system)
            button.setTitle(item, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.backgroundColor = UIColor.systemGray5
            button.layer.cornerRadius = 8
            button.clipsToBounds = true

            currentRowStack?.addArrangedSubview(button)
        }
    }

    @objc private func enlargeProfileImage() {
        guard let imageView = profileImageView else { return }
        
        // Create a new view controller to present the enlarged image
        let enlargedImageViewController = UIViewController()
        enlargedImageViewController.view.backgroundColor = .black
        
        // Create an image view to display the enlarged image
        let enlargedImageView = UIImageView(image: imageView.image)
        enlargedImageView.contentMode = .scaleAspectFit
        enlargedImageView.frame = enlargedImageViewController.view.frame
        enlargedImageViewController.view.addSubview(enlargedImageView)
        
        // Add a tap gesture to dismiss the enlarged image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissEnlargedImage))
        enlargedImageViewController.view.addGestureRecognizer(tapGesture)
        
        // Present the view controller
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
            topViewController.present(enlargedImageViewController, animated: true, completion: nil)
        }
    }

    @objc private func dismissEnlargedImage(_ sender: UITapGestureRecognizer) {
        sender.view?.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    private func createTabView(iconName: String, title: String, url: String) -> UIView {
        let tabView = UIView()
        tabView.backgroundColor = .white
        tabView.layer.cornerRadius = 8
        tabView.layer.borderWidth = 1
        tabView.layer.borderColor = UIColor.lightGray.cgColor
        tabView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.tintColor = .black
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        if let profileName = url.split(separator: "/").last {
            titleLabel.text = "\(title) Profile /\(profileName)"
        } else {
            titleLabel.text = title
        }

        tabView.addSubview(iconImageView)
        tabView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: tabView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: tabView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: tabView.centerYAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openURL(_:)))
        tabView.addGestureRecognizer(tapGesture)
        tabView.accessibilityLabel = url

        // Fetch and set the icon image
        fetchIconImage(named: iconName) { image in
            iconImageView.image = image
        }

        return tabView
    }

    private func fetchIconImage(named iconName: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = Storage.storage().reference().child("logo_images/\(iconName).png")
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }

    @objc private func openURL(_ sender: UITapGestureRecognizer) {
        if let urlString = sender.view?.accessibilityLabel, var urlWithScheme = URL(string: urlString) {
            if !urlString.hasPrefix("http") {
                urlWithScheme = URL(string: "https://\(urlString)")!
            }
            UIApplication.shared.open(urlWithScheme)
        }
    }

    private func fetchUserDetails() {
        print("Fetching user details for user: \(user.id)")
        let db = Firestore.firestore()
        db.collection("users").document(user.id).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("No user data found for user \(self?.user.id ?? "")")
                return
            }

            if let githubUrl = data["githubUrl"] as? String, !githubUrl.isEmpty {
                print("Fetched GitHub URL: \(githubUrl)")
                self?.user.githubUrl = githubUrl
                self?.githubTabView.accessibilityLabel = githubUrl
                if let githubLabel = self?.githubTabView.subviews.compactMap({ $0 as? UILabel }).first,
                   let profileName = githubUrl.split(separator: "/").last {
                    githubLabel.text = "GitHub Account"
                }
            } else {
                if let githubLabel = self?.githubTabView.subviews.compactMap({ $0 as? UILabel }).first {
                    githubLabel.text = "Not Available"
                }
            }

            if let linkedInUrl = data["linkedinUrl"] as? String, !linkedInUrl.isEmpty {
                print("Fetched LinkedIn URL: \(linkedInUrl)")
                self?.user.linkedinUrl = linkedInUrl
                self?.linkedInTabView.accessibilityLabel = linkedInUrl
                if let linkedInLabel = self?.linkedInTabView.subviews.compactMap({ $0 as? UILabel }).first,
                   let profileName = linkedInUrl.split(separator: "/").last {
                    linkedInLabel.text = "LinkedIn Profile"
                }
            } else {
                if let linkedInLabel = self?.linkedInTabView.subviews.compactMap({ $0 as? UILabel }).first {
                    linkedInLabel.text = "Not Available"
                }
            }

            if let about = data["Description"] as? String {
                print("Fetched description: \(about)")
                self?.aboutLabel.text = about
            }
        }
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }
    }
}

