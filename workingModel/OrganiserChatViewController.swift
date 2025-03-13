import UIKit
import FirebaseFirestore
import FirebaseAuth

class OrganiserChatViewController: UIViewController {
    private let tableView = UITableView()
    private let chatManager = FirestoreChatManager()
    private var users: [User] = []
    private var currentUser: User? // Define the currentUser variable
    private let currentUserID = Auth.auth().currentUser?.uid ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Organiser Chats"

        setupTableView()
        fetchCurrentUser()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .singleLine

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchCurrentUser() {
        guard let firebaseUser = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }

        let currentUserID = firebaseUser.uid
        chatManager.fetchUsers { [weak self] users in
            guard let self = self else { return }

            if let currentUser = users.first(where: { $0.id == currentUserID }) {
                self.currentUser = currentUser
                self.fetchUsersWhoMessaged()
            } else {
                print("Current user not found in users collection.")
            }
        }
    }

    private func fetchUsersWhoMessaged() {
        chatManager.fetchUsersWhoMessaged(to: currentUserID) { [weak self] users in
            guard let self = self else { return }
            self.users = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate

extension OrganiserChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }

        let user = users[indexPath.row]
        cell.configure(
            with: user.name,
            message: "Tap to start a chat",
            time: "",
            profileImageURL: user.profileImageURL
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        startChat(with: selectedUser)
    }

    private func startChat(with otherUser: User) {
        guard let currentUser = currentUser else {
            print("Current user is nil. Cannot start chat.")
            return
        }

        chatManager.fetchOrCreateChatThread(for: currentUser.id, with: otherUser.id) { [weak self] thread in
            guard let self = self, let thread = thread else {
                print("Error creating or fetching chat thread.")
                return
            }

            DispatchQueue.main.async {
                let chatDetailVC = ChatDetailViewController()
                chatDetailVC.chatThread = thread
                self.navigationController?.pushViewController(chatDetailVC, animated: true)
            }
        }
    }
}
