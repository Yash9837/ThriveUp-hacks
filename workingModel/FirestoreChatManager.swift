import FirebaseFirestore
import FirebaseAuth
import UIKit

class FirestoreChatManager {
    private let db = Firestore.firestore()

    // MARK: - Fetch All Users
    func fetchUsers(completion: @escaping ([User]) -> Void) {
        db.collection("users").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            let users = documents.compactMap { doc -> User? in
                let data = doc.data()
                let id = data["uid"] as? String ?? ""
                let name = data["name"] as? String ?? "Unknown"
                let profileImageURL = data["profileImageURL"] as? String
                return User(id: id, name: name, profileImage: nil, profileImageURL: profileImageURL)
            }
            completion(users)
        }
    }

    // Fetch the last message for a given chat thread
    func fetchLastMessage(for chatThread: ChatThread, currentUserID: String, completion: @escaping (ChatMessage?) -> Void) {
        let chatRef = db.collection("chats").document(chatThread.id).collection("messages")
        chatRef.order(by: "timestamp", descending: true).limit(to: 1).getDocuments { snapshot, error in
            guard let document = snapshot?.documents.first else {
                print("No messages found or error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            let data = document.data()
            let id = document.documentID
            let messageContent = data["messageContent"] as? String ?? ""
            let senderID = data["senderId"] as? String ?? ""
            let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()

            let sender = chatThread.participants.first(where: { $0.id == senderID }) ?? User(id: senderID, name: "Unknown")
            let message = ChatMessage(
                id: id,
                sender: sender,
                messageContent: messageContent,
                timestamp: timestamp,
                isSender: senderID == currentUserID
            )
            completion(message)
        }
    }

    // Fetch or create a chat thread between two users
    func fetchOrCreateChatThread(for currentUserID: String, with otherUserID: String, completion: @escaping (ChatThread?) -> Void) {
        let chatId = [currentUserID, otherUserID].sorted().joined(separator: "_")
        let chatRef = db.collection("chats").document(chatId)

        chatRef.getDocument { document, error in
            if let error = error {
                print("Error fetching chat thread: \(error)")
                completion(nil)
                return
            }

            if let document = document, document.exists {
                // Chat thread already exists
                self.fetchParticipants(for: [currentUserID, otherUserID]) { participants in
                    let thread = ChatThread(id: chatId, participants: participants)
                    completion(thread)
                }
            } else {
                // Create a new chat thread
                chatRef.setData([
                    "participants": [currentUserID, otherUserID],
                    "timestamp": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("Error creating chat thread: \(error)")
                        completion(nil)
                    } else {
                        self.fetchParticipants(for: [currentUserID, otherUserID]) { participants in
                            let thread = ChatThread(id: chatId, participants: participants)
                            completion(thread)
                        }
                    }
                }
            }
        }
    }

    // Fetch participants for a given list of user IDs
    func fetchParticipants(for participantIDs: [String], completion: @escaping ([User]) -> Void) {
        guard !participantIDs.isEmpty else {
            print("Participant IDs array is empty.")
            completion([])
            return
        }

        db.collection("users").whereField("uid", in: participantIDs).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching participants: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            let participants = documents.compactMap { doc -> User? in
                let data = doc.data()
                let id = data["uid"] as? String ?? ""
                let name = data["name"] as? String ?? "Unknown"
                let profileImageURL = data["profileImageURL"] as? String
                return User(id: id, name: name, profileImage: nil, profileImageURL: profileImageURL)
            }

            completion(participants)
        }
    }

    // Send a message in a chat thread
    func sendMessage(chatThread: ChatThread, messageContent: String, senderID: String, completion: @escaping (Bool) -> Void) {
        let chatRef = db.collection("chats").document(chatThread.id).collection("messages").document()

        let messageData: [String: Any] = [
            "id": chatRef.documentID,
            "senderId": senderID,
            "messageContent": messageContent,
            "timestamp": FieldValue.serverTimestamp()
        ]

        chatRef.setData(messageData) { error in
            if let error = error {
                print("Error sending message: \(error)")
                completion(false)
            } else {
                self.updateLastMessage(for: chatThread.id, lastMessage: messageContent)
                completion(true)
            }
        }
    }

    // Update the last message in a chat thread
    private func updateLastMessage(for chatId: String, lastMessage: String) {
        let chatRef = db.collection("chats").document(chatId)
        chatRef.updateData([
            "lastMessage": lastMessage,
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error updating last message: \(error)")
            }
        }
    }

    // Notify friends about event registration
    func notifyFriendsForEventRegistration(eventName: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        // Fetch friends of the current user
        FriendsService.shared.fetchFriends(forUserID: currentUserID) { [weak self] friends, error in
            if let error = error {
                print("Error fetching friends: \(error)")
                return
            }
            let friendIDs = friends?.map { $0.friendID } ?? []
            self?.fetchParticipants(for: friendIDs) { participants in
                for friend in participants {
                    let notificationData: [String: Any] = [
                        "id": UUID().uuidString,
                        "userId": friend.id,
                        "senderId": currentUserID,
                        "title": "Event Registration",
                        "message": "Your friend has registered for the event: \(eventName)",
                        "timestamp": FieldValue.serverTimestamp(),
                        "isRead": false
                    ]

                    self?.db.collection("notifications").addDocument(data: notificationData) { error in
                        if let error = error {
                            print("Error creating notification: \(error)")
                        }
                    }
                }
            }
        }
    }

    // Fetch users who have sent messages to the current organiser
    func fetchUsersWhoMessaged(to organiserID: String, completion: @escaping ([User]) -> Void) {
        db.collection("chats")
            .whereField("participants", arrayContains: organiserID)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching chat threads: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }

                var senderIDs: Set<String> = []
                let group = DispatchGroup()

                for document in documents {
                    group.enter()
                    let chatID = document.documentID
                    self.db.collection("chats").document(chatID).collection("messages")
                        .whereField("senderId", isNotEqualTo: organiserID)
                        .getDocuments { messageSnapshot, error in
                            guard let messages = messageSnapshot?.documents else {
                                print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                                group.leave()
                                return
                            }

                            for message in messages {
                                if let senderID = message.data()["senderId"] as? String {
                                    senderIDs.insert(senderID)
                                }
                            }
                            group.leave()
                        }
                }

                group.notify(queue: .main) {
                    self.db.collection("users")
                        .whereField("uid", in: Array(senderIDs))
                        .getDocuments { userSnapshot, error in
                            guard let documents = userSnapshot?.documents else {
                                print("Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                                completion([])
                                return
                            }

                            let users = documents.compactMap { doc -> User? in
                                let data = doc.data()
                                let id = data["uid"] as? String ?? ""
                                let name = data["name"] as? String ?? "Unknown"
                                let profileImageURL = data["profileImageURL"] as? String
                                return User(id: id, name: name, profileImage: nil, profileImageURL: profileImageURL)
                            }
                            completion(users)
                        }
                }
            }
    }

    // Fetch chat threads for a given user
    func fetchChatThreads(for currentUser: User, completion: @escaping ([ChatThread]) -> Void) {
        db.collection("chats")
            .whereField("participants", arrayContains: currentUser.id)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching chat threads: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }

                var threads: [ChatThread] = []
                let group = DispatchGroup()

                for document in documents {
                    group.enter()
                    let data = document.data()
                    let chatId = document.documentID
                    let participantIDs = data["participants"] as? [String] ?? []
                    let lastMessageContent = data["lastMessage"] as? String ?? "No messages yet."
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()

                    self.fetchParticipants(for: participantIDs) { participants in
                        let thread = ChatThread(
                            id: chatId,
                            participants: participants,
                            messages: [
                                ChatMessage(
                                    id: "lastMessage",
                                    sender: participants.first ?? User(id: "", name: "Unknown"),
                                    messageContent: lastMessageContent,
                                    timestamp: timestamp,
                                    isSender: false
                                )
                            ]
                        )
                        threads.append(thread)
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    completion(threads)
                }
            }
    }
}
