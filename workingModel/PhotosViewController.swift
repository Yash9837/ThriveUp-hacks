//
//  PhotosViewController.swift
//  ThriveUp
//
//  Created by Sanidhya's MacBook Pro on 26/01/25.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - Properties
    private var photos: [PhotoModel] = []
    private let db = Firestore.firestore()
    private let eventId: String // The event ID for which photos are being fetched

    // MARK: - UI Elements
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        return collectionView
    }()

    // MARK: - Initializer
    init(eventId: String) {
        self.eventId = eventId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchPhotos()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Fetch Photos
    private func fetchPhotos() {
        db.collection("event_photos").whereField("eventId", isEqualTo: eventId).order(by: "timestamp", descending: true).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching photos: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            self.photos = documents.compactMap { doc in
                try? doc.data(as: PhotoModel.self)
            }

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    // MARK: - Collection View DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let photo = photos[indexPath.item]
        cell.configure(with: photo)
        return cell
    }
}

// MARK: - PhotoModel
struct PhotoModel: Codable {
    var eventId: String
    var photoURL: String
    var timestamp: Date
}

// MARK: - PhotoCell
class PhotoCell: UICollectionViewCell {
    static let identifier = "photoCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with photo: PhotoModel) {
        if let url = URL(string: photo.photoURL) {
            imageView.sd_setImage(with: url, completed: nil)
        }
    }
}
