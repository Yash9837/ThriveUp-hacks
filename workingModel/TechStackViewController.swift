import UIKit
import Firebase
import FirebaseFirestore

class TechStackViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // User ID property
    var userID: String?
    var selectedTechStack = [String]()
    var onSave: (([String]) -> Void)?
    private let maxSelection = 10

    // Data structure for tech stack
    private let techStack: [String: [String]] = [
        "🍏 Apple": ["Swift 🍎", "Objective-C 📚", "Xcode 🛠", "CocoaPods 📦"],
        "💻 Coding Languages": ["Python 🐍", "Java ☕️", "JavaScript 🌐", "C++ 💻", "C# 🎮", "Ruby 💎", "Go 🚀", "Kotlin ☕️", "Dart 🎯", "Rust 🦀", "TypeScript 📜", "PHP 🐘", "Scala 🐱", "Haskell 🔢"],
        "🔧 Frameworks": ["React ⚛️", "Angular 🅰️", "Vue.js 🖖", "Django 🌿", "Spring 🌱", "Rails 🚂", "Flutter 🦋", "Laravel 🌐", "Express 🚂", "ASP.NET 🖥", "Svelte 🎨", "Next.js ⏭", "Nuxt.js ⏮"],
        "🛠 Tools": ["Git 🔧", "Docker 🐳", "Kubernetes ☸️", "Jenkins 🏗", "Azure DevOps ☁️", "Terraform 🌍", "Ansible 🛡", "Gradle 📦", "Maven 📦", "Travis CI 🔧", "CircleCI 🔄", "Vagrant 📦", "Webpack 📦"],
        "📊 Databases": ["MySQL 🐬", "PostgreSQL 🐘", "MongoDB 🍃", "Firebase 🔥", "SQLite 🗃", "Redis 🧠", "Cassandra 🌿", "Oracle 🏛", "SQL Server 🗄", "DynamoDB 🌩", "MariaDB 🐬", "Neo4j 🌐", "Elasticsearch 🔍"],
        "🌐 Web Technologies": ["HTML5 🌐", "CSS3 🎨", "Sass 🎨", "Less 🎨", "Bootstrap 🅱️", "Tailwind CSS 🌬", "jQuery 💻", "GraphQL 🔍", "REST API 🌐", "WebAssembly 🕸"],
        "📱 Mobile Development": ["SwiftUI 📱", "React Native ⚛️", "Flutter 🦋", "Kotlin/Native ☕️", "Xamarin 📱", "Ionic 🌐", "Cordova 🌐"],
        "☁️ Cloud Services": ["AWS ☁️", "Azure ☁️", "Google Cloud ☁️", "Heroku ☁️", "Netlify 🌐", "Vercel 🌐", "Firebase 🔥", "DigitalOcean ☁️", "Linode ☁️"]
    ]

    private var collectionView: UICollectionView!

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Tech Stack"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Pick exactly 10 tools, languages, or frameworks you use. It’ll help you showcase your skills."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let selectionLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10 selected"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupHeader()
        setupCollectionView()
        setupConstraints()

        // Initialize selection label
        selectionLabel.text = "0/\(maxSelection) selected"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSavedTechStack() // Fetch the tech stack every time the view appears
    }

    private func setupHeader() {
        view.addSubview(headerLabel)
        view.addSubview(subHeaderLabel)
        view.addSubview(selectionLabel)
        view.addSubview(saveButton)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(44))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            section.boundarySupplementaryItems = [header]

            return section
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(InterestCell.self, forCellWithReuseIdentifier: "InterestCell")
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            selectionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            selectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: subHeaderLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: selectionLabel.topAnchor, constant: -16),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func saveButtonTapped() {
        if selectedTechStack.count == maxSelection {
            saveTechStackToFirestore()
        } else {
            let alert = UIAlertController(title: "Selection Incomplete", message: "Please select exactly \(maxSelection) items before saving.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    private func saveTechStackToFirestore() {
        guard let userID = userID else {
            print("User ID is nil") // Debugging statement
            return
        }

        let db = Firestore.firestore()
        let userTechStack = ["userID": userID, "techStack": selectedTechStack] as [String : Any]

        db.collection("TechStack").document(userID).setData(userTechStack) { error in
            if let error = error {
                print("Error saving tech stack: \(error.localizedDescription)") // Debugging statement
                return
            }
            print("Tech stack saved successfully.") // Debugging statement

            // Show an alert controller confirming the tech stack has been saved
            let alertController = UIAlertController(title: "Success", message: "Your tech stack has been saved.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.onSave?(self?.selectedTechStack ?? [])
                self?.navigationController?.popViewController(animated: true)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    // Fetch saved tech stack from Firestore
    private func fetchSavedTechStack() {
        guard let userID = userID else {
            print("User ID is nil") // Debugging statement
            return
        }

        let db = Firestore.firestore()
        db.collection("TechStack").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching saved tech stack: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("No saved tech stack found for user \(userID)") // Debugging statement
                return
            }

            // Clear the selectedTechStack array to avoid duplication
            self?.selectedTechStack.removeAll()
            
            // Fetch the tech stack from the document
            if let fetchedTechStack = data["techStack"] as? [String] {
                self?.selectedTechStack = fetchedTechStack.filter { !$0.isEmpty }
            }
            
            // Update the selection label
            self?.selectionLabel.text = "\(self?.selectedTechStack.count ?? 0)/\(self?.maxSelection ?? 10) selected"
            
            // Reload the collection view to reflect the updated selections
            self?.collectionView.reloadData()
        }
    }

    // MARK: - UICollectionView DataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return techStack.keys.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = Array(techStack.keys)[section]
        return techStack[category]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = Array(techStack.keys)[indexPath.section]
        let item = techStack[category]?[indexPath.row] ?? ""

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestCell", for: indexPath) as! InterestCell
        cell.configure(with: item, isSelected: selectedTechStack.contains(item))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = Array(techStack.keys)[indexPath.section]
        let selectedItem = techStack[category]?[indexPath.row] ?? ""

        if selectedItem.isEmpty {
            return
        }

        if let index = selectedTechStack.firstIndex(of: selectedItem) {
            selectedTechStack.remove(at: index)
        } else if selectedTechStack.count < maxSelection {
            selectedTechStack.append(selectedItem)
        } else {
            let alert = UIAlertController(title: "Limit Reached", message: "You can only select up to \(maxSelection) items.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

        collectionView.reloadData()
        selectionLabel.text = "\(selectedTechStack.count)/\(maxSelection) selected"
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        let category = Array(techStack.keys)[indexPath.section]
        header.configure(with: category)
        return header
    }
}
