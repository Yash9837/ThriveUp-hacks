//
//  UnauthenViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 19/11/24.
//
import UIKit

class UnauthenticatedProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    private var registeredEvents: [EventModel] = [] // Placeholder for registered events (for demo purposes)
    
    // UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular, scale: .large)
        imageView.image = UIImage(systemName: "person.circle.fill", withConfiguration: symbolConfig) // Default User Icon in iOS
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Guest User"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .darkGray
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Please log in to view your profile."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor.orange
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Log in to view your registered events."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let eventsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EventCell")
        tableView.isHidden = true // Initially hidden until there are events to show
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupUI()
        setupConstraints()
        print("UnauthenticatedProfileViewController loaded.")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(loginButton)
        view.addSubview(placeholderLabel)
        view.addSubview(eventsTableView)
        
        // Set table view data source and delegate
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
    }
    
    private func setupConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        eventsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            loginButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 24),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 160),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            placeholderLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 40),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            eventsTableView.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 16),
            eventsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eventsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Configure Navigation Bar
    private func configureNavigationBar() {
        navigationItem.title = "Profile"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]
    }
    
    // MARK: - Login Button Action
    @objc private func loginButtonTapped() {
        let loginVC = LoginViewController() // Replace with your LoginViewController
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registeredEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        cell.textLabel?.text = "Event \(indexPath.row + 1)" // Replace with actual event data
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected Event \(indexPath.row + 1)")
    }
}
