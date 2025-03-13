import UIKit
import FirebaseFirestore
import FirebaseAuth

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var notifications: [NotificationModel] = []
    private let db = Firestore.firestore()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Notifications"
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        loadNotifications()
    }
    
    private func loadNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        db.collection("notifications").whereField("userId", isEqualTo: userId).getDocuments { [weak self] querySnapshot, error in
            if let error = error {
                print("Error fetching notifications: \(error.localizedDescription)")
                return
            }

            self?.notifications = querySnapshot?.documents.compactMap { document in
                let data = document.data()
                return NotificationModel(
                    id: document.documentID,
                    title: data["title"] as? String ?? "No Title",
                    message: data["message"] as? String ?? "No Message",
                    date: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                    isRead: data["isRead"] as? Bool ?? false
                )
            } ?? []
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                print("Notifications loaded: \(self?.notifications.count ?? 0) notifications")
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as! NotificationTableViewCell
        cell.configure(with: notifications[indexPath.row])
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle notification tap
        let notification = notifications[indexPath.row]
        markNotificationAsRead(notification)
    }
    
    private func markNotificationAsRead(_ notification: NotificationModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("notifications").document(notification.id).updateData(["isRead": true]) { [weak self] error in
            if let error = error {
                print("Error marking notification as read: \(error.localizedDescription)")
            } else {
                if let index = self?.notifications.firstIndex(where: { $0.id == notification.id }) {
                    self?.notifications[index].isRead = true
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        print("Notification marked as read: \(notification.id)")
                    }
                }
            }
        }
    }
}
