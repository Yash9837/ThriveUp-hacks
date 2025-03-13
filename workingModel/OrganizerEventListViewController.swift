import FirebaseFirestore
import FirebaseAuth
import UIKit
import AVFoundation


class OrganizerEventListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

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
    private let filterButton = UIButton(type: .system)
    private var captureSession: AVCaptureSession?
       private var previewLayer: AVCaptureVideoPreviewLayer?
       private var scannedResult: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupSearchBar()
        setupFilterButton()
        setupCollectionView()
        fetchEventsFromFirestore()
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        let logoImageView = UIImageView(image: UIImage(named: "thriveUpLogo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        let logoContainerView = UIView()
        logoContainerView.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            logoImageView.leadingAnchor.constraint(equalTo: logoContainerView.leadingAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: logoContainerView.trailingAnchor),
            logoImageView.topAnchor.constraint(equalTo: logoContainerView.topAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: logoContainerView.bottomAnchor)
        ])

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoContainerView)

        let notificationButton = UIButton(type: .system)
        notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
        notificationButton.tintColor = .black
        notificationButton.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        
        let cameraButton = UIButton(type: .system)
        cameraButton.setImage(UIImage(systemName: "camera"), for: .normal)
        cameraButton.tintColor = .black
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: notificationButton),
            UIBarButtonItem(customView: cameraButton)
        ]
    }

    @objc private func notificationButtonTapped() {
        let notificationVC = NotificationViewController()
        navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    
    @objc private func cameraButtonTapped() {
        startQRCodeScanner()
    }

    // MARK: - QR Code Scanner
    private func startQRCodeScanner() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showAlert(title: "Error", message: "Camera not supported on this device.")
            return
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showAlert(title: "Error", message: "Cannot access camera.")
            return
        }

        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            showAlert(title: "Error", message: "Cannot access camera.")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showAlert(title: "Error", message: "Cannot scan QR codes.")
            return
        }

        // Add preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)

        // Add a "Cross" button to exit
        let crossButton = UIButton(type: .system)
        crossButton.setTitle("✕", for: .normal)
        crossButton.setTitleColor(.white, for: .normal)
        crossButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        crossButton.layer.cornerRadius = 20
        crossButton.addTarget(self, action: #selector(closeQRCodeScanner), for: .touchUpInside)
        crossButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(crossButton)

        // Tag the cross button to remove it later
        crossButton.tag = 999

        // Set constraints for the Cross button
        NSLayoutConstraint.activate([
            crossButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            crossButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            crossButton.widthAnchor.constraint(equalToConstant: 40),
            crossButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        captureSession?.startRunning()
    }

    @objc private func closeQRCodeScanner() {
        stopQRCodeScanner()

        // Remove the Cross button
        if let crossButton = view.viewWithTag(999) {
            crossButton.removeFromSuperview()
        }

        navigationController?.popViewController(animated: true) // Navigate back to the home screen
    }

    private func stopQRCodeScanner() {
        DispatchQueue.main.async {
            self.captureSession?.stopRunning()
            self.captureSession = nil
            self.previewLayer?.removeFromSuperlayer()
            self.previewLayer = nil

            // Remove the Cross button
            if let crossButton = self.view.viewWithTag(999) {
                crossButton.removeFromSuperview()
            }
        }
    }

    private func validateQRCode(_ qrData: String) {
        guard let qrJSON = try? JSONSerialization.jsonObject(with: Data(qrData.utf8), options: []) as? [String: Any],
              let uid = qrJSON["uid"] as? String,
              let eventId = qrJSON["eventId"] as? String else {
            showAlert(title: "Error", message: "Invalid QR code.")
            stopQRCodeScanner()
            return
        }

        let db = Firestore.firestore()

        // Step 1: Verify the event ID belongs to the logged-in organizer
        guard let loggedInUserId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "User not logged in.")
            stopQRCodeScanner()
            return
        }

        db.collection("events").document(eventId).getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    self.stopQRCodeScanner()
                }
                return
            }

            guard let eventData = document?.data(), let organizerId = eventData["userId"] as? String else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Event not found.")
                    self.stopQRCodeScanner()
                }
                return
            }

            if organizerId != loggedInUserId {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "You are not authorized to scan this QR code.")
                    self.stopQRCodeScanner()
                }
                return
            }

            // Step 2: Validate the QR code registration
            db.collection("registrations")
                .whereField("uid", isEqualTo: uid)
                .whereField("eventId", isEqualTo: eventId)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }

                    DispatchQueue.main.async {
                        self.stopQRCodeScanner()
                    }

                    if let error = error {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: error.localizedDescription)
                        }
                        return
                    }

                    if let document = snapshot?.documents.first {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Success", message: "Registration validated successfully for user: \(uid).")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: "No matching registration found.")
                        }
                    }
                }
        }
    }


    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }

    // MARK: - Search Bar
    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
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
        let filterVC = EventFilterViewController() // Renamed to avoid conflict
        filterVC.delegate = self
        present(filterVC, animated: true, completion: nil)
    }

    // MARK: - Collection View
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let sectionName = self.filteredCategories[sectionIndex]

            if sectionName == "Trending" {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(180))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

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
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

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
        collectionView.backgroundColor = .white
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

        header.titleLabel.font = UIFont.boldSystemFont(ofSize: header.titleLabel.font.pointSize)

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
            let eventDetailsVC = OrganiserEventDetailViewController()
            eventDetailsVC.eventId = event.eventId
            navigationController?.pushViewController(eventDetailsVC, animated: true)
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

protocol EventFilterViewControllerDelegate: AnyObject {
    func didApplyFilters(_ filters: [String])
}

class EventFilterViewController: UIViewController {
    weak var delegate: EventFilterViewControllerDelegate?
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

extension EventFilterViewController: UITableViewDelegate, UITableViewDataSource {
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

// MARK: - EventFilterViewControllerDelegate
extension OrganizerEventListViewController: EventFilterViewControllerDelegate {
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
extension OrganizerEventListViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            stopQRCodeScanner()
            validateQRCode(stringValue)
        }
    }
}
