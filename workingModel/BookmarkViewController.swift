import UIKit
import FirebaseFirestore
import FirebaseAuth

class BookmarkViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    private var bookmarkedEvents: [EventModel] = [] {
        didSet {
            categorizedEvents = categorizeEvents(bookmarkedEvents)
            collectionView.reloadData()
        }
    }
    private var categorizedEvents: [String: [EventModel]] = [:]

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search events"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            // Layout for each section
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(200))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            section.interGroupSpacing = 20 // Add spacing between groups
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60)) // Increased height
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]

            return section
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(BookmarkCell.self, forCellWithReuseIdentifier: BookmarkCell.identifier)
        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderReusableView.identifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Bookmarks"

        setupSearchBar()
        setupCollectionView()
        loadBookmarkedEvents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUnbookmarkEvent(_:)), name: NSNotification.Name("UnbookmarkEvent"), object: nil)
    }

    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadBookmarkedEvents() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated")
            return
        }

        let db = Firestore.firestore()
        
        db.collection("swipedeventsdb").whereField("userId", isEqualTo: userId).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else { return }
            var eventIds: [String] = []
            for document in documents {
                let data = document.data()
                if let eventId = data["eventId"] as? String {
                    eventIds.append(eventId)
                }
            }
            
            self?.fetchEvents(eventIds: eventIds)
        }
    }
    
    private func fetchEvents(eventIds: [String]) {
        let db = Firestore.firestore()
        let eventsCollection = db.collection("events")
        
        let dispatchGroup = DispatchGroup()
        var fetchedEvents: [EventModel] = []
        
        for eventId in eventIds {
            dispatchGroup.enter()
            eventsCollection.document(eventId).getDocument { (document, error) in
                if let document = document, document.exists {
                    do {
                        let data = document.data()!
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let event = try JSONDecoder().decode(EventModel.self, from: jsonData)
                        fetchedEvents.append(event)
                    } catch {
                        print("Error decoding event: \(error)")
                    }
                } else {
                    print("Event not found: \(eventId)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.bookmarkedEvents = fetchedEvents
        }
    }

    private func categorizeEvents(_ events: [EventModel]) -> [String: [EventModel]] {
        return Dictionary(grouping: events, by: { $0.category })
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categorizedEvents.keys.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = Array(categorizedEvents.keys)[section]
        return categorizedEvents[category]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = Array(categorizedEvents.keys)[indexPath.section]
        guard let events = categorizedEvents[category] else { return UICollectionViewCell() }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookmarkCell.identifier, for: indexPath) as! BookmarkCell
        cell.configure(with: events[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderReusableView.identifier, for: indexPath) as! HeaderReusableView
            let category = Array(categorizedEvents.keys)[indexPath.section]
            header.configure(title: category)
            return header
        }
        return UICollectionReusableView()
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 32) / 2 // Adjust for spacing
        return CGSize(width: width, height: 200)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = Array(categorizedEvents.keys)[indexPath.section]
        if let event = categorizedEvents[category]?[indexPath.item] {
            let eventDetailsVC = EventDetailViewController()
            eventDetailsVC.eventId = event.eventId // Pass the event ID to fetch the specific event details
            navigationController?.pushViewController(eventDetailsVC, animated: true)
        }
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            categorizedEvents = categorizeEvents(bookmarkedEvents)
        } else {
            let filteredEvents = bookmarkedEvents.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            categorizedEvents = categorizeEvents(filteredEvents)
        }
        collectionView.reloadData()
    }

    @objc private func handleUnbookmarkEvent(_ notification: Notification) {
        if let event = notification.userInfo?["event"] as? EventModel {
            // Remove the event from the bookmarkedEvents array
            if let index = bookmarkedEvents.firstIndex(where: { $0.eventId == event.eventId }) {
                bookmarkedEvents.remove(at: index)
                collectionView.reloadData()

                // Query Firestore to get the document ID
                Firestore.firestore().collection("swipedeventsdb")
                    .whereField("eventId", isEqualTo: event.eventId)
                    .getDocuments { querySnapshot, error in
                        if let error = error {
                            print("Error querying documents: \(error)")
                            return
                        }
                        
                        guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                            print("No matching documents found")
                            return
                        }

                        // Assuming eventId is unique, so we take the first document
                        let document = documents.first
                        let documentId = document?.documentID ?? ""

                        // Remove the event from Firestore using the document ID
                        Firestore.firestore().collection("swipedeventsdb").document(documentId).delete { error in
                            if let error = error {
                                print("Error removing document: \(error)")
                            } else {
                                print("Document successfully removed!")
                            }
                        }
                }
            }
        }
    }
}

// MARK: - HeaderReusableView

class HeaderReusableView: UICollectionReusableView {
    static let identifier = "HeaderReusableView"
    
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20) // Increased font size
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10), // Increased padding
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10) // Increased padding
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}

class BookmarkCell: UICollectionViewCell {
    static let identifier = "BookmarkCell"
    
    private let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        let bookmarkImage = UIImage(systemName: "bookmark.fill")
        button.setImage(bookmarkImage, for: .normal)
        button.tintColor = .red
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var event: EventModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(eventImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bookmarkButton)
        
        // Set up constraints
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            eventImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            eventImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            eventImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            eventImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Constraints for bookmark button
            bookmarkButton.trailingAnchor.constraint(equalTo: eventImageView.trailingAnchor, constant: -8),
            bookmarkButton.bottomAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: -8),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = .white
        
        bookmarkButton.addTarget(self, action: #selector(didTapBookmarkButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with event: EventModel) {
        self.event = event
        // Debugging prints to ensure imageName is not nil and has a valid value
        print("Configuring BookmarkCell with event: \(event)")
        print("Image name: \(event.imageName)")

        // Set the image
        if let imageURL = URL(string: event.imageName), !event.imageName.isEmpty, event.imageName.hasPrefix("http") {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.eventImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.eventImageView.image = UIImage(named: "placeholder")
                        print("Failed to load image from URL: \(imageURL)")
                    }
                }
            }
        } else if !event.imageName.isEmpty {
            eventImageView.image = UIImage(named: event.imageName) ?? UIImage(named: "placeholder")
            print("Loaded image from assets: \(event.imageName)")
        } else {
            eventImageView.image = UIImage(named: "placeholder")
            print("Using placeholder image")
        }
        
        // Set title and date
        titleLabel.text = event.title
        dateLabel.text = event.date
    }
    
    @objc private func didTapBookmarkButton() {
        guard let event = event else { return }
        // Notify the view controller about the unbookmark action
        NotificationCenter.default.post(name: NSNotification.Name("UnbookmarkEvent"), object: nil, userInfo: ["event": event])
    }
}
