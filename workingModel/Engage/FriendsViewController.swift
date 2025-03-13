import UIKit
import FirebaseFirestore

class FriendsViewController: UIViewController {
    var currentUser: User?
    var friends: [Friend] = []
    var filteredFriends: [Friend] = []  // Array to store filtered friends based on search
    var userCache: [String: User] = [:]  // Cache to store fetched user details

    let tableView = UITableView()
    let searchBar = UISearchBar()
    let titleLabel = UILabel()
    let titleStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTitleStackView()
        setupSearchBar()
        setupTableView()
        fetchFriends()
        tableView.rowHeight = 70 // ✅ Ensures enough space for each row

    }

    private func setupTitleStackView() {
        // Configure titleLabel
        titleLabel.text = "Friends"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .left

        // Configure titleStackView
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 8

        // Add titleLabel to titleStackView
        titleStackView.addArrangedSubview(titleLabel)

        // Add titleStackView to the view
        view.addSubview(titleStackView)
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search friends"
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.identifier)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }


//    private func fetchFriends() {
//        guard let currentUser = currentUser else { return }
//        FriendsService.shared.fetchFriends(forUserID: currentUser.id) { [weak self] friends, error in
//            if let error = error {
//                print("Error fetching friends: \(error)")
//                return
//            }
//            self?.friends = friends ?? []
//            self?.filteredFriends = self?.friends ?? []
//            self?.fetchUserDetailsForFriends()
//        }
//    }
//    private func fetchFriends() {
//        guard let currentUser = currentUser else { return }
//        FriendsService.shared.fetchFriends(forUserID: currentUser.id) { [weak self] friends, error in
//            if let error = error {
//                print("Error fetching friends: \(error)")
//                return
//            }
//            self?.friends = friends ?? []
//            self?.filteredFriends = self?.friends ?? []
//            self?.fetchUserDetailsForFriends()
//
//            // Update friends count in ProfileViewController
//            if let profileVC = self?.navigationController?.viewControllers.first(where: { $0 is ProfileViewController }) as? ProfileViewController {
//                profileVC.fetchFriendsCount()
//            }
//        }
//    }

    private func fetchFriends() {
        guard let currentUser = currentUser else { return }
        
        FriendsService.shared.fetchFriends(forUserID: currentUser.id) { [weak self] friends, error in
            if let error = error {
                print("Error fetching friends: \(error)")
                return
            }
            
            self?.friends = friends ?? []
            self?.filteredFriends = self?.friends ?? []
            self?.fetchUserDetailsForFriends()
            
            // Notify ProfileViewController to update friend count
            NotificationCenter.default.post(name: NSNotification.Name("FriendCountUpdated"), object: nil)
        }
    }




    private func fetchUserDetailsForFriends() {
        let dispatchGroup = DispatchGroup()
        
        for friend in friends {
            if userCache[friend.friendID] == nil {
                dispatchGroup.enter()
                FriendsService.shared.fetchUserDetails(uid: friend.friendID) { [weak self] user, error in
                    if let user = user {
                        self?.userCache[friend.friendID] = user
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }


    private func removeFriend(_ friend: Friend?) {
        guard let friend = friend else { return }
        let alert = UIAlertController(title: "Remove Friend", message: "Are you sure you want to remove this friend?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            FriendsService.shared.removeFriend(userID: self.currentUser!.id, friendID: friend.friendID) { [weak self] success, error in
                if let error = error {
                    print("Error removing friend: \(error)")
                    return
                }
                self?.friends.removeAll { $0.friendID == friend.friendID }
                self?.filteredFriends.removeAll { $0.friendID == friend.friendID }
                self?.userCache.removeValue(forKey: friend.friendID)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.identifier, for: indexPath) as? FriendCell else {
            return UITableViewCell()
        }
        
        let friend = filteredFriends[indexPath.row]

        if let user = userCache[friend.friendID] {
            cell.configure(with: user)
        } else {
            cell.configure(with: User(id: friend.friendID, name: "Loading...", profileImageURL: nil))
            
            FriendsService.shared.fetchUserDetails(uid: friend.friendID) { [weak self] user, error in
                if let user = user {
                    self?.userCache[friend.friendID] = user
                    DispatchQueue.main.async {
                        if let visibleIndexPath = tableView.indexPath(for: cell), visibleIndexPath == indexPath {
                            cell.configure(with: user)
                        }
                    }
                }
            }
        }

        // ✅ Attach message button action
        cell.messageButton.tag = indexPath.row
        cell.messageButton.addTarget(self, action: #selector(openChat(_:)), for: .touchUpInside)

        return cell
    }

    @objc private func openChat(_ sender: UIButton) {
        let friend = filteredFriends[sender.tag]

        if let user = userCache[friend.friendID] {
            let chatVC = ChatDetailViewController()

            // Generate a unique chat ID for the conversation
            let chatID = generateChatID(for: user.id, and: currentUser?.id ?? "")

            // Initialize chat thread with user and chat ID
            chatVC.chatThread = ChatThread(id: chatID, participants: [currentUser!, user])

            let navController = UINavigationController(rootViewController: chatVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
    }


    // Helper function to generate a consistent chat ID
    private func generateChatID(for user1: String, and user2: String) -> String {
        return user1 < user2 ? "\(user1)_\(user2)" : "\(user2)_\(user1)"
    }




    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completionHandler) in
            let friend = self?.filteredFriends[indexPath.row]
            self?.removeFriend(friend)
            completionHandler(true)
        }
        
        removeAction.image = UIImage(systemName: "trash.fill") // Trash icon
        removeAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [removeAction])
    }

}

extension FriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFriends = friends
        } else {
            filteredFriends = friends.filter { userCache[$0.friendID]?.name.lowercased().contains(searchText.lowercased()) ?? false }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
#Preview{
    FriendsViewController()
}
