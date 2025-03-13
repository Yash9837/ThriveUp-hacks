import UIKit
import FirebaseAuth

class EventContainerViewController: UIViewController {

    // MARK: - Properties
    var event: EventModel? // Event data passed from the previous page
    var openedFromEventVC: Bool = false // Flag to check if opened from EventViewController

    // MARK: - UI Elements
    private let detailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Details", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.addTarget(self, action: #selector(detailsButtonTapped), for: .touchUpInside)
        return button
    }()

    private let updatesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Updates", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(updatesButtonTapped), for: .touchUpInside)
        return button
    }()

    private let photosButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Photos", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(photosButtonTapped), for: .touchUpInside)
        return button
    }()

    private let containerView = UIView()

    // Child view controllers
    private var eventDetailVC: EventDetailViewController?
    private var updatesVC: UpdatesViewController?
    private var photosVC: PhotosViewController?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupSwipeGestures()
        showDetailsView()
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        // Remove the back label and only keep the back arrow
        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        // Create a container for the buttons
        let buttonStackView = UIStackView(arrangedSubviews: [detailsButton, updatesButton, photosButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10

        // Create a container view for the button stack
        let buttonContainerView = UIView()
        buttonContainerView.addSubview(buttonStackView)

        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Set the button container view as the title view of the navigation item
        navigationItem.titleView = buttonContainerView
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 54), // Adjusted for navigation bar height
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Ensure event is not nil before initializing child view controllers
        guard let event = event else { return }

        eventDetailVC = EventDetailViewController()
        eventDetailVC?.eventId = event.eventId
        eventDetailVC?.openedFromEventVC = openedFromEventVC // Pass the flag

        updatesVC = UpdatesViewController(eventId: event.eventId)

        photosVC = PhotosViewController(eventId: event.eventId)
    }

    // MARK: - Setup Swipe Gestures
    private func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }

    // MARK: - Handle Swipe
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            if detailsButton.titleColor(for: .normal) == .orange {
                showUpdatesView()
            } else if updatesButton.titleColor(for: .normal) == .orange {
                showPhotosView()
            }
        case .right:
            if photosButton.titleColor(for: .normal) == .orange {
                showUpdatesView()
            } else if updatesButton.titleColor(for: .normal) == .orange {
                showDetailsView()
            }
        default:
            break
        }
    }

    // MARK: - Button Actions
    @objc private func detailsButtonTapped() {
        showDetailsView()
    }

    @objc private func updatesButtonTapped() {
        showUpdatesView()
    }

    @objc private func photosButtonTapped() {
        showPhotosView()
    }

    // MARK: - Show Views
    private func showDetailsView() {
        detailsButton.setTitleColor(.orange, for: .normal)
        updatesButton.setTitleColor(.black, for: .normal)
        photosButton.setTitleColor(.black, for: .normal)

        if let eventDetailVC = eventDetailVC {
            switchToViewController(eventDetailVC)
        }
    }

    private func showUpdatesView() {
        detailsButton.setTitleColor(.black, for: .normal)
        updatesButton.setTitleColor(.orange, for: .normal)
        photosButton.setTitleColor(.black, for: .normal)

        if let updatesVC = updatesVC {
            switchToViewController(updatesVC)
        }
    }

    private func showPhotosView() {
        detailsButton.setTitleColor(.black, for: .normal)
        updatesButton.setTitleColor(.black, for: .normal)
        photosButton.setTitleColor(.orange, for: .normal)

        if let photosVC = photosVC {
            switchToViewController(photosVC)
        }
    }

    // MARK: - Helper
    private func switchToViewController(_ childVC: UIViewController) {
        // Remove previous child view controllers
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        // Add new child view controller
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childVC.didMove(toParent: self)
    }
}
