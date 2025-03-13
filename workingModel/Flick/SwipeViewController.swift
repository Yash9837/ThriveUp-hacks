import UIKit
import Instructions
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class SwipeViewController: UIViewController, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    private var eventStack: [EventModel] = []
    private var userStack: [UserDetails] = []
    private var acceptRequests: [AcceptRequest] = []
    
    private var bookmarkedEvents: [EventModel] = []
    private var bookmarkedUsers: [UserDetails] = []
    private let db = Firestore.firestore()

    private let cardContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // CoachMarksController instance for the guided tour
    let coachMarksController = CoachMarksController()
    let swipeButton = UIButton(type: .system)
    let hackathonButton = UIButton(type: .system)
    let filterButton = UIButton(type: .system)
    let acceptRequestsButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6

        setupTitleStackView()
        setupViews()
        setupConstraints()
        fetchEventsFromDatabase()
        fetchUsersFromDatabase()
        fetchAcceptRequests()

        // Configure CoachMarksController
        coachMarksController.dataSource = self
        coachMarksController.delegate = self

        // Check if it's the user's first time logging in
        if isFirstTimeUser() {
            askForTutorial()
        }

        // Observe for notification to show the instructions
        NotificationCenter.default.addObserver(self, selector: #selector(showInstructions), name: NSNotification.Name("ShowInstructions"), object: nil)
    }

    @objc private func showInstructions() {
        askForTutorial()
    }

    private func setupTitleStackView() {
        // Configure swipeButton
        swipeButton.setTitle("Flick", for: .normal)
        swipeButton.setTitleColor(.orange, for: .normal)
        swipeButton.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        swipeButton.addTarget(self, action: #selector(handleSwipeButtonTapped), for: .touchUpInside)

        // Configure hackathonButton
        hackathonButton.setTitle("HackMate", for: .normal)
        hackathonButton.setTitleColor(.gray, for: .normal)
        hackathonButton.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        hackathonButton.addTarget(self, action: #selector(handleHackathonButtonTapped), for: .touchUpInside)

        // Stack for buttons above "HackMate"
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .equalSpacing
        buttonStackView.spacing = 16

        // Configure filterButton (use existing class variable, not a new one)
        filterButton.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle"), for: .normal)
        filterButton.tintColor = .black
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

        // Configure acceptRequestsButton (use existing class variable, not a new one)
        acceptRequestsButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        acceptRequestsButton.tintColor = .black
        acceptRequestsButton.translatesAutoresizingMaskIntoConstraints = false
        acceptRequestsButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        acceptRequestsButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

        // Add buttons to stack
        buttonStackView.addArrangedSubview(filterButton)
        buttonStackView.addArrangedSubview(acceptRequestsButton)

        // Ensure buttons are properly linked to actions
        filterButton.addTarget(self, action: #selector(handleFilterButtonTapped), for: .touchUpInside)
        acceptRequestsButton.addTarget(self, action: #selector(handleAcceptRequestsButtonTapped), for: .touchUpInside)

        // Configure titleStackView
        let titleStackView = UIStackView(arrangedSubviews: [swipeButton, hackathonButton])
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 8

        // Add titleStackView to the view
        view.addSubview(titleStackView)
        view.addSubview(buttonStackView)
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleStackView.heightAnchor.constraint(equalToConstant: 40),

            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }


    @objc private func handleSwipeButtonTapped() {
        swipeButton.setTitleColor(.orange, for: .normal)
        hackathonButton.setTitleColor(.gray, for: .normal)
        acceptRequestsButton.setTitleColor(.gray, for: .normal)
        displayTopCards(for: .swipe)
    }

    @objc private func handleHackathonButtonTapped() {
        swipeButton.setTitleColor(.gray, for: .normal)
        hackathonButton.setTitleColor(.orange, for: .normal)
        acceptRequestsButton.setTitleColor(.gray, for: .normal)
        displayTopCards(for: .hackathon)
    }

    @objc private func handleFilterButtonTapped() {
        guard let userId = Auth.auth().currentUser?.uid else {
            promptUserToSignIn()
            return
        }

        let interestViewController = InterestsViewController()
        interestViewController.userID = userId
        navigationController?.pushViewController(interestViewController, animated: true)
    }

    @objc private func handleAcceptRequestsButtonTapped() {
        let hackmateVC = HackmateViewController()
        navigationController?.pushViewController(hackmateVC, animated: true)
    }


    private func promptUserToSignIn() {
        let alert = UIAlertController(title: "Sign In Required", message: "Please sign in to access your interests", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { _ in
            // Navigate to sign-in view controller
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func setupViews() {
        view.addSubview(cardContainerView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            cardContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    private func fetchEventsFromDatabase() {
        db.collection("events").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }

            var fetchedEvents: [EventModel] = []

            snapshot?.documents.forEach { document in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let event = try JSONDecoder().decode(EventModel.self, from: jsonData)
                    fetchedEvents.append(event)
                } catch {
                    print("Error decoding event: \(error.localizedDescription)")
                }
            }

            self?.eventStack = fetchedEvents.reversed()

            DispatchQueue.main.async {
                self?.displayTopCards(for: .swipe)
            }
        }
    }

    private func fetchUsersFromDatabase() {
        db.collection("users").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }

            var fetchedUsers: [UserDetails] = []

            snapshot?.documents.forEach { document in
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let description = data["Description"] as? String ?? "No Description Available"
                let imageUrl = data["profileImageURL"] as? String ?? ""
                let githubUrl = data["githubUrl"] as? String ?? "Not Available"
                let linkedinUrl = data["linkedinUrl"] as? String ?? "Not Available"
                let techStack = data["techStack"] as? String ?? "Unknown"
                let contact = data["ContactDetails"] as? String ?? "Not Available"

                let user = UserDetails(
                    id: id,
                    name: name,
                    description: description,
                    imageUrl: imageUrl,
                    contact: contact, githubUrl: githubUrl,
                    linkedinUrl: linkedinUrl,
                    techStack: techStack
                )
                
                fetchedUsers.append(user)
            }

            self?.userStack = fetchedUsers.reversed()
            self?.displayTopUserCards()
        }
    }

    private func fetchAcceptRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        db.collection("accept_requests")
            .whereField("receiverId", isEqualTo: currentUserId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching accept requests: \(error.localizedDescription)")
                    return
                }
                
                var fetchedRequests: [AcceptRequest] = []
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    let senderId = data["senderId"] as? String ?? ""
                    let receiverId = data["receiverId"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
                    let request = AcceptRequest(id: document.documentID, senderId: senderId, receiverId: receiverId, timestamp: timestamp.dateValue())
                    fetchedRequests.append(request)
                }
                self?.acceptRequests = fetchedRequests
                DispatchQueue.main.async {
                    self?.displayTopAcceptRequestCards()
                }
            }
    }

    private func displayTopCards(for category: Category) {
        cardContainerView.subviews.forEach { $0.removeFromSuperview() }

        let cards: [UIView]
        switch category {
        case .swipe:
            cards = eventStack.suffix(3).map { createCard(for: $0) }
        case .hackathon:
            cards = userStack.suffix(3).map { createCard(for: $0) }
        case .acceptRequests:
            cards = acceptRequests.suffix(3).map { createCard(for: $0) }
        }

        for cardView in cards {
            cardContainerView.addSubview(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                cardView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
                cardView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
                cardView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
                cardView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor)
            ])

            cardContainerView.sendSubviewToBack(cardView)
        }
    }

    private func createCard(for event: EventModel) -> UIView {
        let cardView = FlippableCardView(event: event)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        cardView.addGestureRecognizer(panGesture)

        let bookmarkButton = createButton(imageName: "bookmark.fill", tintColor: .systemOrange)
        let discardButton = createButton(imageName: "xmark", tintColor: .systemRed)

        bookmarkButton.alpha = 0 // Initially hide the bookmark button
        discardButton.alpha = 0 // Initially hide the discard button

        cardView.addSubview(bookmarkButton)
        cardView.addSubview(discardButton)

        NSLayoutConstraint.activate([
            bookmarkButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 60),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 60),

            discardButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            discardButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            discardButton.widthAnchor.constraint(equalToConstant: 60),
            discardButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        cardView.bookmarkButton = bookmarkButton
        cardView.discardButton = discardButton

        return cardView
    }

    private func createCard(for user: UserDetails) -> UIView {
        let cardView = UserProfileCardView(user: user)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleUserSwipe(_:)))
        cardView.addGestureRecognizer(panGesture)

        let bookmarkButton = createButton(imageName: "bookmark.fill", tintColor: .systemOrange)
        let discardButton = createButton(imageName: "xmark", tintColor: .systemRed)

        bookmarkButton.alpha = 0 // Initially hide the bookmark button
        discardButton.alpha = 0 // Initially hide the discard button

        cardView.bookmarkButton = bookmarkButton
        cardView.discardButton = discardButton

        cardView.addSubview(bookmarkButton)
        cardView.addSubview(discardButton)

        NSLayoutConstraint.activate([
            bookmarkButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 60),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 60),

            discardButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            discardButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            discardButton.widthAnchor.constraint(equalToConstant: 60),
            discardButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        return cardView
    }

    private func createCard(for request: AcceptRequest) -> UIView {
        let cardView = AcceptRequestCardView(request: request)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleRequestSwipe(_:)))
        cardView.addGestureRecognizer(panGesture)

        return cardView
    }

    private func createButton(imageName: String, tintColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = tintColor
        button.backgroundColor = UIColor(white: 1, alpha: 0.75)
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func bookmarkEvent(for event: EventModel) {
        bookmarkedEvents.append(event)
        // Optionally: Save the bookmarked event to a database or UserDefaults
    }

    private func discardEvent(for event: EventModel) {
        eventStack.removeAll { $0.eventId == event.eventId }
        displayTopCards(for: .swipe)
    }

    private func bookmarkUser(for user: UserDetails) {
        bookmarkedUsers.append(user)
        // Optionally: Save the bookmarked user to a database or UserDefaults
    }

    private func discardUser(for user: UserDetails) {
        userStack.removeAll { $0.id == user.id }
        displayTopUserCards()
    }

    private func animateCardOffScreen(_ cardView: FlippableCardView, toRight: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            cardView.transform = CGAffineTransform(translationX: toRight ? self.view.frame.width : -self.view.frame.width, y: 0)
            cardView.alpha = 0
        }) { _ in
            cardView.removeFromSuperview()
            if let index = self.eventStack.firstIndex(of: cardView.event) {
                self.eventStack.remove(at: index)
            }
            self.displayTopCards(for: .swipe)
        }
    }

    private func animateUserCardOffScreen(_ cardView: UserProfileCardView, toRight: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            cardView.transform = CGAffineTransform(translationX: toRight ? self.view.frame.width : -self.view.frame.width, y: 0)
            cardView.alpha = 0
        }) { _ in
            cardView.removeFromSuperview()
            if let index = self.userStack.firstIndex(where: { $0.id == cardView.user.id }) {
                self.userStack.remove(at: index)
            }
            self.displayTopUserCards()
        }
    }
    
    private func displayTopUserCards() {
        cardContainerView.subviews.forEach { $0.removeFromSuperview() }

        guard !userStack.isEmpty else { return }

        let topUsers = userStack.suffix(3)
        for user in topUsers {
            let userCardView = UserProfileCardView(user: user)
            userCardView.translatesAutoresizingMaskIntoConstraints = false
            cardContainerView.addSubview(userCardView)

            NSLayoutConstraint.activate([
                userCardView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
                userCardView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),
                userCardView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
                userCardView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor)
            ])

            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleUserSwipe(_:)))
            userCardView.addGestureRecognizer(panGesture)

            cardContainerView.sendSubviewToBack(userCardView)
        }
    }

    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        guard let cardView = gesture.view as? FlippableCardView else { return }
        let translation = gesture.translation(in: view)
        let xFromCenter = translation.x

        switch gesture.state {
        case .began:
            // Hide both buttons initially
            cardView.bookmarkButton?.alpha = 0
            cardView.discardButton?.alpha = 0
        case .changed:
            cardView.transform = CGAffineTransform(translationX: xFromCenter, y: 0)
                .rotated(by: xFromCenter / 200)
            cardView.alpha = 1 - abs(xFromCenter) / view.frame.width

            // Show the appropriate button based on swipe direction
            if xFromCenter > 0 {
                cardView.bookmarkButton?.alpha = 1
                cardView.discardButton?.alpha = 0
            } else {
                cardView.bookmarkButton?.alpha = 0
                cardView.discardButton?.alpha = 1
            }

        case .ended:
            if xFromCenter > 100 {
                bookmarkEvent(for: cardView.event)
                animateCardOffScreen(cardView, toRight: true)
            } else if xFromCenter < -100 {
                discardEvent(for: cardView.event)
                animateCardOffScreen(cardView, toRight: false)
            } else {
                UIView.animate(withDuration: 0.3) {
                    cardView.transform = CGAffineTransform.identity
                    cardView.alpha = 1
                    cardView.bookmarkButton?.alpha = 0
                    cardView.discardButton?.alpha = 0
                }
            }
        default:
            UIView.animate(withDuration: 0.3) {
                cardView.transform = CGAffineTransform.identity
                cardView.alpha = 1
                cardView.bookmarkButton?.alpha = 0
                cardView.discardButton?.alpha = 0
            }
        }
    }

    @objc private func handleUserSwipe(_ gesture: UIPanGestureRecognizer) {
        guard let cardView = gesture.view as? UserProfileCardView else { return }
        let translation = gesture.translation(in: view)
        let xFromCenter = translation.x

        switch gesture.state {
        case .ended:
            if xFromCenter > 100 {
                sendHackmateRequest(to: cardView.user.id)
                animateUserCardOffScreen(cardView, toRight: true)
            } else {
                discardUser(for: cardView.user)
                animateUserCardOffScreen(cardView, toRight: false)
            }
        default:
            break
        }
    }
    @objc private func handleRequestSwipe(_ gesture: UIPanGestureRecognizer) {
        guard let cardView = gesture.view as? AcceptRequestCardView else { return }
        let translation = gesture.translation(in: view)
        let xFromCenter = translation.x

        switch gesture.state {
        case .began:
            // Hide the card initially
            cardView.alpha = 1
        case .changed:
            cardView.transform = CGAffineTransform(translationX: xFromCenter, y: 0)
                .rotated(by: xFromCenter / 200)
            cardView.alpha = 1 - abs(xFromCenter) / view.frame.width
        case .ended:
            if xFromCenter > 100 {
                acceptRequest(cardView.request)
                animateCardOffScreen(cardView, toRight: true)
            } else if xFromCenter < -100 {
                rejectRequest(cardView.request)
                animateCardOffScreen(cardView, toRight: false)
            } else {
                UIView.animate(withDuration: 0.3) {
                    cardView.transform = CGAffineTransform.identity
                    cardView.alpha = 1
                }
            }
        default:
            UIView.animate(withDuration: 0.3) {
                cardView.transform = CGAffineTransform.identity
                cardView.alpha = 1
            }
        }
    }

    private func acceptRequest(_ request: AcceptRequest) {
        // Logic to accept the request
        // Update Firestore or local data as needed
        acceptRequests.removeAll { $0.id == request.id }
        displayTopAcceptRequestCards()
    }

    private func rejectRequest(_ request: AcceptRequest) {
        // Logic to reject the request
        // Update Firestore or local data as needed
        acceptRequests.removeAll { $0.id == request.id }
        displayTopAcceptRequestCards()
    }

    private func animateCardOffScreen(_ cardView: AcceptRequestCardView, toRight: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            cardView.transform = CGAffineTransform(translationX: toRight ? self.view.frame.width : -self.view.frame.width, y: 0)
            cardView.alpha = 0
        }) { _ in
            cardView.removeFromSuperview()
            self.displayTopAcceptRequestCards()
        }
    }

    private func displayTopAcceptRequestCards() {
        cardContainerView.subviews.forEach { $0.removeFromSuperview() }

        guard !acceptRequests.isEmpty else { return }

        let topRequests = acceptRequests.suffix(3)
        for request in topRequests {
            let requestCardView = AcceptRequestCardView(request: request)
            requestCardView.translatesAutoresizingMaskIntoConstraints = false
            cardContainerView.addSubview(requestCardView)

            NSLayoutConstraint.activate([
                requestCardView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
                requestCardView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),
                requestCardView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
                requestCardView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor)
            ])

            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleRequestSwipe(_:)))
            requestCardView.addGestureRecognizer(panGesture)

            cardContainerView.sendSubviewToBack(requestCardView)
        }
    }

    private func isFirstTimeUser() -> Bool {
        // Implement logic to check if it's the first time user
        return false
    }

    private func askForTutorial() {
        let alert = UIAlertController(title: "Welcome!", message: "Would you like to take a quick tour of the app?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.startGuidedTour()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func startGuidedTour() {
        coachMarksController.start(in: .window(over: self))
    }

    // MARK: - CoachMarksControllerDataSource

    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 3
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: swipeButton)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: hackathonButton)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: filterButton)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: UIView & CoachMarkBodyView, arrowView: (UIView & CoachMarkArrowView)?) {
        let hintText: String
        switch index {
        case 0:
            hintText = "Tap here to swipe through events."
        case 1:
            hintText = "Tap here to view hackathon matches."
        case 2:
            hintText = "Tap here to filter your interests."
        default:
            hintText = ""
        }

        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        coachViews.bodyView.hintLabel.text = hintText
        coachViews.bodyView.nextLabel.text = "Next"

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    private func sendHackmateRequest(to receiverId: String) {
        guard let senderId = Auth.auth().currentUser?.uid else { return }

        let requestRef = db.collection("hackmate_requests").document()
        let requestData: [String: Any] = [
            "senderId": senderId,
            "receiverId": receiverId,
            "timestamp": Timestamp(),
            "status": "pending"
        ]

        requestRef.setData(requestData) { error in
            if let error = error {
                print("Error sending hackmate request: \(error.localizedDescription)")
            } else {
                print("Hackmate request sent successfully")
            }
        }
    }
    private func fetchHackmateRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("hackmate_requests")
            .whereField("receiverId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching hackmate requests: \(error.localizedDescription)")
                    return
                }

                var fetchedRequests: [HackmateRequest] = []
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    let senderId = data["senderId"] as? String ?? ""
                    let receiverId = data["receiverId"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
                    let requestId = document.documentID

                    let request = HackmateRequest(id: requestId, senderId: senderId, receiverId: receiverId, timestamp: timestamp.dateValue())
                    fetchedRequests.append(request)
                }

                self?.acceptRequests = fetchedRequests.map { $0.toAcceptRequest() }

            }
    }

}
        
enum Category {
    case swipe
    case hackathon
    case acceptRequests
}
           




#Preview{
    SwipeViewController()
}
