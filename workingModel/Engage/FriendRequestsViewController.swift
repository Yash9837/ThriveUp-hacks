import UIKit
import FirebaseFirestore

class FriendRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
    
    
    var currentUser: User?
    var friendRequests: [FriendRequest] = []
    var users: [User] = []
    var filteredUsers: [User] = []
    var userCache: [String: User] = [:]

    let searchBar = UISearchBar()
    let tableView = UITableView()
    

//    private let quickAddCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.itemSize = CGSize(width: 120, height: 160) // Adjusted for grid layout
//        layout.minimumInteritemSpacing = 10
//        layout.minimumLineSpacing = 15
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.register(QuickAddCell.self, forCellWithReuseIdentifier: QuickAddCell.identifier)
//        return collectionView
//    }()
//    private let quickAddCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.itemSize = CGSize(width: 150, height: 200) // Increased size
//        layout.minimumInteritemSpacing = 12
//        layout.minimumLineSpacing = 18
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.register(QuickAddCell.self, forCellWithReuseIdentifier: QuickAddCell.identifier)
//        return collectionView
//    }()

    private let firstRowCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 200)
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(QuickAddCell.self, forCellWithReuseIdentifier: QuickAddCell.identifier)
        return collectionView
    }()

    private let secondRowCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 200)
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(QuickAddCell.self, forCellWithReuseIdentifier: QuickAddCell.identifier)
        return collectionView
    }()




    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Add Friends"

        setupSearchBar()
        setupAddedMeHeading()
        setupTableView()
        setupQuickAddHeading()
        setupCollectionViews() // ✅ Ensure this runs
        fetchFriendRequests()
        fetchUsersExcludingFriendsAndRequests()
    }

    
    private let addedMeLabel: UILabel = {
        let label = UILabel()
        label.text = "Added Me"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let quickAddLabel: UILabel = {
        let label = UILabel()
        label.text = "Quick Add"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private func setupAddedMeHeading() {
        view.addSubview(addedMeLabel)
        NSLayoutConstraint.activate([
            addedMeLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            addedMeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }

    private func setupQuickAddHeading() {
        view.addSubview(quickAddLabel)
        NSLayoutConstraint.activate([
            quickAddLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            quickAddLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }

    
    private func setupCollectionView() {
        quickAddCollectionView.dataSource = self
        quickAddCollectionView.delegate = self
        quickAddCollectionView.backgroundColor = .white
        view.addSubview(quickAddCollectionView)

        NSLayoutConstraint.activate([
            quickAddCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            quickAddCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            quickAddCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            quickAddCollectionView.heightAnchor.constraint(equalToConstant: 420) // Adjusted height
        ])
    }


    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search users"
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
            searchBar.heightAnchor.constraint(equalToConstant: 40)
        ])

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemOrange, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        view.addSubview(cancelButton)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func cancelSearch() {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredUsers = users
        quickAddCollectionView.reloadData()
    }
    
    private let quickAddCollectionView: UICollectionView

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 200)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        self.quickAddCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.quickAddCollectionView.showsHorizontalScrollIndicator = false
        self.quickAddCollectionView.isPagingEnabled = false
        self.quickAddCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.quickAddCollectionView.register(QuickAddCell.self, forCellWithReuseIdentifier: QuickAddCell.identifier)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: "FriendRequestCell")

        view.addSubview(addedMeLabel) // ✅ Add the label before the table
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            addedMeLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            addedMeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            tableView.topAnchor.constraint(equalTo: addedMeLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 250) // Adjusted height
        ])
    }


//    private func setupCollectionView() {
//        quickAddCollectionView.dataSource = self
//        quickAddCollectionView.delegate = self
//        quickAddCollectionView.backgroundColor = .white
//        view.addSubview(quickAddCollectionView)
//
//        NSLayoutConstraint.activate([
//            quickAddCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
//            quickAddCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            quickAddCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            quickAddCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
//        ])
//    }
    private func setupCollectionViews() {
        
        
        
        firstRowCollectionView.dataSource = self  // ✅ Set data source
        firstRowCollectionView.delegate = self
        firstRowCollectionView.backgroundColor = .white
        view.addSubview(firstRowCollectionView)

        secondRowCollectionView.dataSource = self  // ✅ Set data source
        secondRowCollectionView.delegate = self
        secondRowCollectionView.backgroundColor = .white
        view.addSubview(secondRowCollectionView)

        NSLayoutConstraint.activate([
            quickAddLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            quickAddLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            firstRowCollectionView.topAnchor.constraint(equalTo: quickAddLabel.bottomAnchor, constant: 12),
            firstRowCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            firstRowCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            firstRowCollectionView.heightAnchor.constraint(equalToConstant: 200),

            secondRowCollectionView.topAnchor.constraint(equalTo: firstRowCollectionView.bottomAnchor, constant: 20), // ✅ Add spacing between rows
            secondRowCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            secondRowCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            secondRowCollectionView.heightAnchor.constraint(equalToConstant: 200)
            
            
        ])
    }




    private func fetchFriendRequests() {
        guard let currentUser = currentUser else { return }
        FriendsService.shared.fetchFriendRequests(forUserID: currentUser.id) { [weak self] requests, error in
            if let error = error {
                print("Error fetching friend requests: \(error)")
                return
            }
            self?.friendRequests = requests ?? []
            self?.fetchUserDetailsForRequests()
        }
    }

    private func fetchUserDetailsForRequests() {
        let dispatchGroup = DispatchGroup()
        for request in friendRequests {
            if userCache[request.fromUserID] == nil {
                dispatchGroup.enter()
                FriendsService.shared.fetchUserDetails(uid: request.fromUserID) { [weak self] user, error in
                    if let user = user {
                        self?.userCache[request.fromUserID] = user
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }

    private func fetchUsersExcludingFriendsAndRequests() {
        guard let currentUser = currentUser else { return }
        FriendsService.shared.fetchUsersExcludingFriendsAndRequests(currentUserID: currentUser.id) { [weak self] users, error in
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            DispatchQueue.main.async {
                self?.users = users ?? []
                self?.filteredUsers = self?.users ?? []
                self?.firstRowCollectionView.reloadData()  // ✅ Reload first row
                self?.secondRowCollectionView.reloadData() // ✅ Reload second row
            }
        }
    }


//    private func acceptFriendRequest(_ request: FriendRequest) {
//        FriendsService.shared.acceptFriendRequest(requestID: request.id) { [weak self] success, error in
//            if let error = error {
//                print("Error accepting friend request: \(error)")
//                return
//            }
//
//            // Remove the request from UI
//            self?.friendRequests.removeAll { $0.id == request.id }
//            self?.tableView.reloadData()
//
//            // Fetch updated users and friends list
//            self?.fetchUsersExcludingFriendsAndRequests()
//            NotificationCenter.default.post(name: NSNotification.Name("FriendListUpdated"), object: nil)
//
//
//            // Notify ChatViewController to update chat list
//            NotificationCenter.default.post(name: NSNotification.Name("FriendRequestUpdated"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ChatListUpdated"), object: nil)
//        }
//    }
    private func acceptFriendRequest(_ request: FriendRequest) {
            FriendsService.shared.acceptFriendRequest(requestID: request.id) { [weak self] success, error in
                if let error = error {
                    print("Error accepting friend request: \(error)")
                    return
                }

                // Remove the request from UI
                self?.friendRequests.removeAll { $0.id == request.id }
                self?.tableView.reloadData()

                // Fetch updated users and friends list
                self?.fetchUsersExcludingFriendsAndRequests()

                // Immediately update the friend's list in the Chat section
                NotificationCenter.default.post(name: NSNotification.Name("FriendAddedToChat"), object: nil)

                // Notify ChatViewController to update the chat list
                NotificationCenter.default.post(name: NSNotification.Name("FriendListUpdated"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name("FriendRequestUpdated"), object: nil)
            }
        }
    


    private func rejectFriendRequest(_ request: FriendRequest) {
        FriendsService.shared.removeFriendRequest(requestID: request.id) { [weak self] success, error in
            if let error = error {
                print("Error rejecting friend request: \(error)")
                return
            }
            self?.friendRequests.removeAll { $0.id == request.id }
            self?.tableView.reloadData()
        }
    }

//    private func sendFriendRequest(to user: User) {
//        guard let currentUser = currentUser else { return }
//        FriendsService.shared.sendFriendRequest(fromUserID: currentUser.id, toUserID: user.id) { [weak self] success, error in
//            if let error = error {
//                print("Error sending friend request: \(error)")
//                return
//            }
//            self?.filteredUsers.removeAll { $0.id == user.id }
//            self?.quickAddCollectionView.reloadData()
//        }
//    }

    private func sendFriendRequest(to user: User) {
        guard let currentUser = currentUser else { return }
        FriendsService.shared.sendFriendRequest(fromUserID: currentUser.id, toUserID: user.id) { [weak self] success, error in
            if let error = error {
                print("Error sending friend request: \(error)")
                return
            }

            DispatchQueue.main.async {
                if let index = self?.filteredUsers.firstIndex(where: { $0.id == user.id }) {
                    let indexPath = IndexPath(item: index, section: 0)
                    if let cell = self?.quickAddCollectionView.cellForItem(at: indexPath) as? QuickAddCell {
                        cell.addButton.setTitle("Added", for: .normal)
                        cell.addButton.backgroundColor = .lightGray
                        cell.addButton.setTitleColor(.darkGray, for: .normal)
                        cell.addButton.isUserInteractionEnabled = false
                    }
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestCell.identifier, for: indexPath) as! FriendRequestCell
        let request = friendRequests[indexPath.row]
        
        if let user = userCache[request.fromUserID] {
            cell.configure(
                with: user,
                acceptAction: { [weak self] in
                    self?.acceptFriendRequest(request)
                },
                rejectAction: { [weak self] in
                    self?.rejectFriendRequest(request)
                }
            )
        }
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let halfCount = max(filteredUsers.count / 2, 0) // ✅ Ensure no negative values
        if collectionView == firstRowCollectionView {
            return halfCount
        } else {
            return max(filteredUsers.count - halfCount, 0) // ✅ Ensure no negative values
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuickAddCell.identifier, for: indexPath) as! QuickAddCell
        
        let halfCount = filteredUsers.count / 2
        guard !filteredUsers.isEmpty else { return cell } // ✅ Prevents crash if filteredUsers is empty

        let user: User

        if collectionView == firstRowCollectionView, indexPath.row < halfCount {
            user = filteredUsers[indexPath.row]
        } else if collectionView == secondRowCollectionView, indexPath.row < filteredUsers.count - halfCount {
            user = filteredUsers[halfCount + indexPath.row]
        } else {
            return cell
        }

        cell.configure(with: user, addAction: {
            self.sendFriendRequest(to: user)
        })

        return cell
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 2 // ✅ Set 2 columns
        let spacing: CGFloat = 12 // ✅ Adjust spacing between items
        let totalSpacing = (numberOfColumns - 1) * spacing // ✅ Total spacing
        let availableWidth = collectionView.frame.width - totalSpacing
        let width = availableWidth / numberOfColumns // ✅ Dynamically calculate width
        
        let height: CGFloat = 180 // ✅ Fixed height for uniform row display

        return CGSize(width: width, height: height) // ✅ Ensures two rows
    }



}


#Preview {
    FriendRequestsViewController()
}


#Preview {
    FriendRequestsViewController()
}
