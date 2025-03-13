//
//  iOSOnboardingViewController.swift
//  ThriveUp
//
//  Created by Sanidhya's MacBook Pro on 07/02/25.
//


import UIKit

class iOSOnboardingViewController: UIViewController {

    // Scroll View and Content Vi
    let scrollView = UIScrollView()
    let contentView = UIView()

    // Labels
    let headerLabel = UILabel()
    let subHeaderLabel = UILabel()  // Declaring at the class level

    
    // Onboarding Items (Title, Description, SF Symbol Icon)
    let onboardingItems: [(String, String, String)] = [
        ("Post Events", "Easily create and share your events with the community.", "square.and.pencil"),
        ("Register for Events", "Secure your spot for exciting events with one tap.", "checkmark.circle"),
        ("Stay Updated", "Get real-time updates and announcements for your favorite events.", "bell"),
        ("Bookmark Events", "Swipe right to save events to your favorites.", "bookmark")
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = UIColor.white

        // Present as a PageSheet
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
            presentationController.prefersGrabberVisible = true
        }

        // Header Label
        headerLabel.text = "Welcome To"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 42)
        headerLabel.textColor = .black
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)

        // Sub-header Label
        subHeaderLabel.text = "ThriveUp"
        subHeaderLabel.font = UIFont.boldSystemFont(ofSize: 44)
        subHeaderLabel.textColor = UIColor.orange
        subHeaderLabel.textAlignment = .center
        subHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subHeaderLabel)

        // Scroll View
        setupScrollView()

        // Onboarding Content
        setupOnboardingContent()

        // Footer Button
        setupFooterButton()

        // Constraints for Header & Subheader
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 5),
            subHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: subHeaderLabel.bottomAnchor, constant: 40), // Using the class-level subHeaderLabel
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func setupOnboardingContent() {
        var previousView: UIView?

        for (title, description, imageName) in onboardingItems {
            let onboardingView = createOnboardingView(title: title, description: description, imageName: imageName)
            contentView.addSubview(onboardingView)

            onboardingView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                onboardingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                onboardingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                onboardingView.topAnchor.constraint(equalTo: previousView?.bottomAnchor ?? contentView.topAnchor, constant: 30)
            ])

            previousView = onboardingView
        }

        previousView?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
    }

    func createOnboardingView(title: String, description: String, imageName: String) -> UIView {
        let container = UIView()

        
        // Icon instead of image
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: imageName) // Using SF Symbols
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .orange // Set the icon color
        imageView.translatesAutoresizingMaskIntoConstraints = false


        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(imageView)
        container.addSubview(titleLabel)
        container.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    func setupFooterButton() {
        let continueButton = UIButton()
        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor = UIColor.orange
        continueButton.layer.cornerRadius = 8
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)

        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func didTapContinue() {
        transitionToMainApp()
    }
    
    private func transitionToMainApp() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        window?.rootViewController = GeneralTabbarController()
        UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {}, completion: nil)
    }
}
#Preview{
    iOSOnboardingViewController()
}
