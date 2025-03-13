import FirebaseFirestore
import UIKit
import FirebaseAuth
import SDWebImage

class EventListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    // MARK: - Properties
    private var eventsByCategory: [String: [EventModel]] = [:]
    private var filteredEventsByCategory: [String: [EventModel]] = [:]
    private let predefinedCategories = [
        "Trending", "Fun and Entertainment", "Tech and Innovation",
        "Club and Societies", "Cultural", "Networking", "Sports", "Career Connect", "Wellness", "Other"
    ]
    private var categories: [String] = []
    private var filteredCategories: [String] = []
    private var collectionView: UICollectionView!
    private let searchBar = UISearchBar()
    private let feedLabel = UILabel()
    private let filterButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupGradientBackground() // Add gradient background first
                
        setupFeedLabel()
        setupSearchBar()
        setupFilterButton()
        setupCollectionView()
        fetchEventsFromFirestore()
    }
    private func setupGradientBackground() {
        // Primary Gradient for Top Section
        let topGradientLayer = CAGradientLayer()
        let topGradientHeight = view.bounds.height * 1 // Covers 30% of the screen for top navigation
        topGradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topGradientHeight)

        topGradientLayer.colors = [
            UIColor(red: 1.0, green: 0.7, blue: 0.4, alpha: 1.0).cgColor, // Lighter Orange
            UIColor.white.cgColor // Smooth transition to white
        ]

        topGradientLayer.locations = [0.0, 0.4]
        topGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        topGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        let topGradientView = UIView(frame: topGradientLayer.frame)
        topGradientView.layer.addSublayer(topGradientLayer)
        view.addSubview(topGradientView)

        // Secondary Gradient for Collection View Area
        let bottomGradientLayer = CAGradientLayer()
        let bottomGradientHeight = view.bounds.height * 0.4 // Covers 40% of collection view
        bottomGradientLayer.frame = CGRect(x: 0, y: topGradientHeight, width: view.bounds.width, height: bottomGradientHeight)

        bottomGradientLayer.colors = [
            UIColor(red: 1.0, green: 0.85, blue: 0.7, alpha: 0.7).cgColor, // Lightest Orange
            UIColor.white.cgColor  // Smooth White Transition
        ]
        bottomGradientLayer.locations = [0.0, 1.0]
        bottomGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bottomGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        let bottomGradientView = UIView(frame: bottomGradientLayer.frame)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        view.addSubview(bottomGradientView)

        // Ensure both gradients are in the background
        view.sendSubviewToBack(bottomGradientView)
        view.sendSubviewToBack(topGradientView)
    }


    private func setupNavigationBar() {
        guard let user = Auth.auth().currentUser else {
            print("No user signed in")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [self] snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data(),
                  let profileImageURL = data["profileImageURL"] as? String,
                  let userName = data["name"] as? String else {
                print("User data missing or improperly formatted")
                return
            }

            // Profile Image
            let profileImageView = UIImageView()
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.clipsToBounds = true
            profileImageView.layer.cornerRadius = 25  // Circular Image
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            profileImageView.sd_setImage(with: URL(string: profileImageURL), placeholderImage: UIImage(named: "defaultProfile"))
            
            let nameLabel = UILabel()
            nameLabel.text = userName
            nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
            nameLabel.textColor = .black
            nameLabel.translatesAutoresizingMaskIntoConstraints = false

            // Container View for profile image and name label
            let profileContainerView = UIView()
            profileContainerView.addSubview(profileImageView)
            profileContainerView.addSubview(nameLabel)
            profileContainerView.translatesAutoresizingMaskIntoConstraints = false

            // Bookmark & Notification Buttons
            let bookmarkButton = UIButton(type: .system)
            bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            bookmarkButton.tintColor = .black
            bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
            bookmarkButton.translatesAutoresizingMaskIntoConstraints = false

            let notificationButton = UIButton(type: .system)
            notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
            notificationButton.tintColor = .black
            notificationButton.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
            notificationButton.translatesAutoresizingMaskIntoConstraints = false

            // Container View for the profile container and buttons
            let topBarView = UIView()
            topBarView.addSubview(profileContainerView)
            topBarView.addSubview(bookmarkButton)
            topBarView.addSubview(notificationButton)
            topBarView.translatesAutoresizingMaskIntoConstraints = false

            // Add custom topBarView as a subview to the main view
            view.addSubview(topBarView)
            
            // MARK: - Layout Constraints
            NSLayoutConstraint.activate([
                // Custom NavBar View Constraints (topBarView) relative to safeArea
                topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: -16),
                topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                topBarView.heightAnchor.constraint(equalToConstant: 70), // Adjust height if needed
            ])

            // Constraints for profile image and name label
            NSLayoutConstraint.activate([
                profileImageView.widthAnchor.constraint(equalToConstant: 50),
                profileImageView.heightAnchor.constraint(equalToConstant: 50),
                profileImageView.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor,constant: 16),
                profileImageView.centerYAnchor.constraint(equalTo: profileContainerView.centerYAnchor),

                nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
                nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
                nameLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor)
            ])

            // Constraints for the bookmark and notification buttons
            NSLayoutConstraint.activate([
                bookmarkButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
                notificationButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),

                notificationButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -20),
                bookmarkButton.trailingAnchor.constraint(equalTo: notificationButton.leadingAnchor, constant: -16)
            ])
        }
    }



    @objc private func bookmarkButtonTapped() {
        let bookmarkedVC = BookmarkViewController()
        navigationController?.pushViewController(bookmarkedVC, animated: true)
    }

    @objc private func notificationButtonTapped() {
        let notificationVC = NotificationViewController()
        navigationController?.pushViewController(notificationVC, animated: true)
    }

    // MARK: - Feed Label
    private func setupFeedLabel() {
        feedLabel.text = "Discover"
        feedLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        feedLabel.textAlignment = .left
        view.addSubview(feedLabel)
        feedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            feedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            feedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            feedLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Search Bar
    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: feedLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Filter Button
    private func setupFilterButton() {
        filterButton.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle"), for: .normal)
        filterButton.tintColor = .black
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        view.addSubview(filterButton)

        filterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            filterButton.widthAnchor.constraint(equalToConstant: 40),
            filterButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        present(filterVC, animated: true, completion: nil)
    }

    // MARK: - Collection View Setup
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let sectionName = self.filteredCategories[sectionIndex]

            if sectionName == "Trending" {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(180))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .absolute(180))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]

                return section
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(200))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 8)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]

                return section
            }
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EventCell.self, forCellWithReuseIdentifier: EventCell.identifier)
        collectionView.register(CategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeader.identifier)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear // ✅ Keep collection view transparent so gradient shows properly

        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    // MARK: - Fetch Events
    private func fetchEventsFromFirestore() {
        Firestore.firestore().collection("events").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            var events: [EventModel] = []

            for document in documents {
                do {
                    let event = try document.data(as: EventModel.self)
                    events.append(event)
                } catch {
                    print("Error decoding event: \(error.localizedDescription)")
                }
            }

            self?.groupEventsByCategory(events)
        }
    }

    private func groupEventsByCategory(_ events: [EventModel]) {
        eventsByCategory = Dictionary(grouping: events, by: { $0.category })
        filteredEventsByCategory = eventsByCategory
        categories = predefinedCategories.filter { eventsByCategory.keys.contains($0) }
        filteredCategories = categories
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: - Collection View DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = filteredCategories[section]
        return filteredEventsByCategory[category]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: indexPath) as! EventCell
        let category = filteredCategories[indexPath.section]
        if let event = filteredEventsByCategory[category]?[indexPath.item] {
            cell.configure(with: event)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryHeader.identifier, for: indexPath) as! CategoryHeader
        header.titleLabel.text = filteredCategories[indexPath.section]

        header.titleLabel.font = UIFont.boldSystemFont(ofSize: 18)

        if filteredCategories[indexPath.section] != "Trending" {
            header.arrowButton.isHidden = false
            header.arrowButton.tag = indexPath.section
            header.arrowButton.addTarget(self, action: #selector(arrowButtonTapped(_:)), for: .touchUpInside)
            header.arrowButton.tintColor = .systemOrange
        } else {
            header.arrowButton.isHidden = true
        }

        return header
    }

    @objc func arrowButtonTapped(_ sender: UIButton) {
        let section = sender.tag
        let category = filteredCategories[section]

        let eventsListVC = EventsCardsViewController()
        eventsListVC.category = CategoryModel(name: category, events: eventsByCategory[category] ?? [])
        navigationController?.pushViewController(eventsListVC, animated: true)
    }

    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = filteredCategories[indexPath.section]
        if let event = filteredEventsByCategory[category]?[indexPath.item] {
            let eventDetailVC = EventDetailViewController()
            eventDetailVC.eventId = event.eventId
            eventDetailVC.openedFromEventVC = false // Set the flag
            
            navigationController?.pushViewController(eventDetailVC, animated: true)
        }
    }

    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCategories = categories
            filteredEventsByCategory = eventsByCategory
        } else {
            filteredEventsByCategory = eventsByCategory.mapValues { events in
                events.filter { event in
                    event.title.lowercased().contains(searchText.lowercased())
                }
            }
            filteredCategories = filteredEventsByCategory.keys.filter { !filteredEventsByCategory[$0]!.isEmpty }
        }
        collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(_ filters: [String])
}

class FilterViewController: UIViewController {
    weak var delegate: FilterViewControllerDelegate?
    private let filterOptions: [String] = ["Trending", "Fun and Entertainment", "Tech and Innovation", "Club and Societies", "Cultural", "Networking", "Sports", "Career Connect", "Wellness", "Other"]
    private var selectedFilters: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Select Filters"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let filterTableView = UITableView()
        filterTableView.delegate = self
        filterTableView.dataSource = self
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterTableView)

        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Apply Filters", for: .normal)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(applyButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            filterTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            filterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterTableView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -20),

            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func applyButtonTapped() {
        delegate?.didApplyFilters(selectedFilters)
        dismiss(animated: true, completion: nil)
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = filterOptions[indexPath.row]

        if selectedFilters.contains(filterOptions[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = filterOptions[indexPath.row]

        if let index = selectedFilters.firstIndex(of: selectedOption) {
            selectedFilters.remove(at: index)
        } else {
            selectedFilters.append(selectedOption)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - FilterViewControllerDelegate
extension EventListViewController: FilterViewControllerDelegate {
    func didApplyFilters(_ filters: [String]) {
        if filters.isEmpty {
            filteredCategories = categories
            filteredEventsByCategory = eventsByCategory
        } else {
            filteredCategories = filters
            filteredEventsByCategory = eventsByCategory.filter { filters.contains($0.key) }
        }
        collectionView.reloadData()
    }
}
#Preview{
    EventListViewController()
}

