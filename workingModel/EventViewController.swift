import UIKit

class EventViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    private var categories: [CategoryModel] = []
    private var collectionView: UICollectionView!
    private var categoryCollectionView: UICollectionView!
    private let searchBar = UISearchBar()
    private let feedLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupFeedLabel()
        setupSearchBar()
        setupCategoryCollectionView()  // Ensure this is called before collectionView
        setupCollectionView()  // Called after categoryCollectionView is set up
        
        populateData()
    }

    private func setupNavigationBar() {
        // Create the logo image view
        let logoImageView = UIImageView(image: UIImage(named: "thriveUpLogo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        // Wrap the image view in a UIView to use it as a custom bar button item
        let logoContainerView = UIView()
        logoContainerView.addSubview(logoImageView)

        // Set constraints for the logo image view within its container
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: logoContainerView.leadingAnchor),
            logoImageView.topAnchor.constraint(equalTo: logoContainerView.topAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: logoContainerView.bottomAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: logoContainerView.trailingAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 60), // Adjust width to desired size
            logoImageView.heightAnchor.constraint(equalToConstant: 60) // Adjust height to desired size
        ])

        // Create a UIBarButtonItem with the container view as its custom view
        let logoBarButtonItem = UIBarButtonItem(customView: logoContainerView)
        navigationItem.leftBarButtonItem = logoBarButtonItem

        // Add the right "Login" button
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal) // Text color
        loginButton.backgroundColor = .orange // Background color
        loginButton.layer.cornerRadius = 8 // Rounded corners
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) // Padding

        // Add target for button click
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)

        // Set the button as the custom view of the right bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loginButton)
    }

    @objc private func loginButtonTapped() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }

    private func setupFeedLabel() {
        feedLabel.text = "Feed"
        feedLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        feedLabel.textAlignment = .left
        
        view.addSubview(feedLabel)
        feedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            feedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            feedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            feedLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage() // Remove border line
        searchBar.searchBarStyle = .minimal
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: feedLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupCategoryCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.minimumInteritemSpacing = 8

        categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        categoryCollectionView.register(CategoryButtonCell.self, forCellWithReuseIdentifier: CategoryButtonCell.identifier)
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.isPagingEnabled = false // Set to true if you want paging

        view.addSubview(categoryCollectionView)
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 50),
            categoryCollectionView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 16) // Adjusted width for scrolling
        ])
    }

    private func setupCollectionView() {
        // Configure the collection view with a compositional layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(EventCell.self, forCellWithReuseIdentifier: EventCell.identifier)
        collectionView.register(CategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeader.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 8), // Adjusted constraint
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // Create compositional layout for the collection view
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            // Determine layout based on the section's name
            let category = self.categories[sectionIndex]
            
            if category.name == "Trending" {
                // Layout for Trending Events (1 item per row, horizontally scrollable)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(182))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .absolute(182))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                
                // Header
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
                
            } else {
                // Layout for Fun and Entertainment, Workshops (2 items per row, horizontally scrollable)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                // Group with two items per row
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                
                // Header
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
    }

    private func populateData() {
        categories = EventDataProvider.getCategories()
        collectionView.reloadData()
    }

    // Collection View DataSource methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == categoryCollectionView {
            return 1
        }
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return ["All 🎓", "Club 🚀", "Tech 👨🏻‍💻", "Cult 🎭","Fun 🥳", "Well 🌱", "Netw 🤝","Conn 💼" ].count
        }
        return categories[section].events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryButtonCell.identifier, for: indexPath) as! CategoryButtonCell
            let categories = ["All 🎓", "Club 🚀", "Tech 👨🏻‍💻", "Cult 🎭","Fun 🥳", "Well 🌱", "Netw 🤝","Conn 💼" ]
            cell.configure(with: categories[indexPath.item])
            return cell
        }
        
        let event = categories[indexPath.section].events[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: indexPath) as! EventCell
        cell.configure(with: event)
        return cell
    }

    // Add headers for section titles
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryHeader.identifier, for: indexPath) as! CategoryHeader
        header.titleLabel.text = categories[indexPath.section].name
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView != categoryCollectionView else {
            // If the tapped collection view is the categoryCollectionView, ignore this action
            return
        }
        let selectedEvent = categories[indexPath.section].events[indexPath.item]

        // Instantiate EventContainerViewController
        let eventContainerVC = EventDetailViewController()
        eventContainerVC.event = selectedEvent
        eventContainerVC.openedFromEventVC = true // Set the flag

        // Push EventContainerViewController onto the navigation stack
        navigationController?.pushViewController(eventContainerVC, animated: true)
    }
}
