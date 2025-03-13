//
//  File.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 18/11/24.
//
//
//
//import UIKit
//import MapKit
//
//class EventDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate {
//    
//    var event: EventModel? // Event data
//    private var updates: [String] = [] // Array to hold updates
//    private var photos: [String] = [] // Array to hold photo image names
//    
//    // MARK: - UI Elements
//    private let segmentedControl: UISegmentedControl = {
//        let control = UISegmentedControl(items: ["Details", "Updates", "Photos"])
//        control.selectedSegmentIndex = 0
//        control.selectedSegmentTintColor = .orange
//        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
//        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
//        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
//        return control
//    }()
//    
//    private let eventImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 22)
//        label.textAlignment = .left
//        label.numberOfLines = 0
//        return label
//    }()
//
//    private let categoryLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .darkGray
//        return label
//    }()
//
//    private let organizerLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = .gray
//        return label
//    }()
//
//    private let dateLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textAlignment = .left
//        label.textColor = .black
//        return label
//    }()
//
//    private let locationLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.numberOfLines = 2
//        label.textAlignment = .left
//        label.textColor = .black
//        return label
//    }()
//
//    private let mapView: MKMapView = {
//        let map = MKMapView()
//        map.layer.cornerRadius = 10
//        map.clipsToBounds = true
//        return map
//    }()
//    
//    private let detailsContainer: UIView = UIView()
//    private let updatesTableView: UITableView = UITableView()
//    private let photosCollectionView: UICollectionView
//    
//    private let registerButton: UIButton = UIButton()
//
//    // MARK: - Initializer
//    init() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.itemSize = CGSize(width: 100, height: 100)
//        layout.minimumInteritemSpacing = 16
//        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//        photosCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - View Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        configureUIWithData()
//        setupRegisterButton()
//        loadMockData()
//    }
//
//    // MARK: - Setup UI
//    private func setupUI() {
//        view.backgroundColor = .white
//        
//        // Configure updates table view
//        updatesTableView.dataSource = self
//        updatesTableView.delegate = self
//        updatesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UpdateCell")
//        updatesTableView.isHidden = true
//        
//        // Configure photos collection view
//        photosCollectionView.dataSource = self
//        photosCollectionView.delegate = self
//        photosCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
//        photosCollectionView.backgroundColor = .clear
//        photosCollectionView.isHidden = true
//
//        // Add subviews
//        [eventImageView, segmentedControl, detailsContainer, updatesTableView, photosCollectionView, registerButton].forEach {
//            view.addSubview($0)
//            $0.translatesAutoresizingMaskIntoConstraints = false
//        }
//
//        // Add details to details container
//        [titleLabel, categoryLabel, organizerLabel, dateLabel, locationLabel, mapView].forEach {
//            detailsContainer.addSubview($0)
//            $0.translatesAutoresizingMaskIntoConstraints = false
//        }
//
//        setupConstraints()
//    }
//
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // Event Image View
//            eventImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            eventImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            eventImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            eventImageView.heightAnchor.constraint(equalToConstant: 250),
//
//            // Segmented Control
//            segmentedControl.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 8),
//            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            segmentedControl.heightAnchor.constraint(equalToConstant: 36),
//
//            // Details Container
//            detailsContainer.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
//            detailsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            detailsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            // Title Label
//            titleLabel.topAnchor.constraint(equalTo: detailsContainer.topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor),
//
//            // Category Label
//            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
//            categoryLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor),
//            categoryLabel.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor),
//
//            // Organizer Label
//            organizerLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
//            organizerLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor),
//            organizerLabel.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor),
//
//            // Date Label
//            dateLabel.topAnchor.constraint(equalTo: organizerLabel.bottomAnchor, constant: 16),
//            dateLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor),
//
//            // Location Label
//            locationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
//            locationLabel.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor),
//
//            // Map View
//            mapView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
//            mapView.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor),
//            mapView.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor),
//            mapView.heightAnchor.constraint(equalToConstant: 100),
//            mapView.bottomAnchor.constraint(equalTo: detailsContainer.bottomAnchor),
//
//            // Updates Table View
//            updatesTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
//            updatesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            updatesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            updatesTableView.bottomAnchor.constraint(equalTo: registerButton.topAnchor, constant: -16),
//
//            // Photos Collection View
//            photosCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
//            photosCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            photosCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            photosCollectionView.bottomAnchor.constraint(equalTo: registerButton.topAnchor, constant: -16),
//
//            // Register Button
//            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            registerButton.heightAnchor.constraint(equalToConstant: 50),
//            registerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
//        ])
//    }
//
//    // MARK: - Configure Data
//    private func configureUIWithData() {
//        guard let event = event else { return }
//
//        titleLabel.text = event.title
//        categoryLabel.text = "\(event.category) • \(event.attendanceCount) people"
//        organizerLabel.text = "Organized by \(event.organizerName)"
//        dateLabel.text = "\(event.date), \(event.time)"
//        locationLabel.text = event.location
//        eventImageView.image = UIImage(named: event.imageName)
//
//        if let latitude = event.latitude, let longitude = event.longitude {
//            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
//            mapView.setRegion(region, animated: false)
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            annotation.title = event.location
//            mapView.addAnnotation(annotation)
//        }
//    }
//
//    // MARK: - Handle Segmented Control
//    @objc private func segmentChanged() {
//        let selectedIndex = segmentedControl.selectedSegmentIndex
//        detailsContainer.isHidden = selectedIndex != 0
//        updatesTableView.isHidden = selectedIndex != 1
//        photosCollectionView.isHidden = selectedIndex != 2
//    }
//
//    // MARK: - Mock Data
//    private func loadMockData() {
//        updates = ["Update 1", "Update 2", "Update 3"]
//        photos = ["photo1", "photo2", "photo3"] // Replace with actual image names
//        updatesTableView.reloadData()
//        photosCollectionView.reloadData()
//    }
//
//    // MARK: - TableView DataSource
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return updates.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell", for: indexPath)
//        cell.textLabel?.text = updates[indexPath.row]
//        return cell
//    }
//
//    // MARK: - CollectionView DataSource
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return photos.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
//        cell.backgroundColor = .lightGray // Placeholder for photo
//        return cell
//    }
//}
