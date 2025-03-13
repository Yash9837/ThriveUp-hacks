//
//  TagViewControllerDelegate.swift
//  ThriveUp
//
//  Created by Sanidhya's MacBook Pro on 16/01/25.
//


import UIKit
import Firebase
import FirebaseFirestore

protocol TagViewControllerDelegate: AnyObject {
    func tagViewController(_ controller: TagViewController, didSelectTags tags: [String])
}

class TagViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // Delegate property
    weak var delegate: TagViewControllerDelegate?

    // Data structure for tags
    private let tags: [String: [String]] = [
        "Academic": ["Workshops", "Seminars", "Conferences"],
        "Cultural": ["Festival", "Dance", "Music", "Art Exhibition", "Pro Shows"],
        "Sports": ["Tournaments", "Hostel Day Events", "Yoga Day Events", "Outdoor Activities"],
        "Networking": ["Career Fairs", "Alumni Meetups", "Guest Lectures", "Professional Development Event"],
        "Club & Society": ["Club Meetings", "Club Recruitements", "Social Events"],
        "Health & Wellness": ["Health Camps", "Mental Health Workshops", "Yoga Classes", "Wellness Seminars"],
        "Community Service": ["Volunteering Opportunities", "Blood Donation", "Community Clean-up Events", "Charity Fundraisers"],
        "Tech & Innovation": ["Hackathons", "Tech Talks", "Startup Pitches", "Coding Competition"],
        "Entertainment": ["Movie Screenings", "Game Nioghts", "Talent Shows", "Open Mic Events"],
        "Miscellaneous": ["Orientation Sessions","Special Interest Events"],
    ]

    var selectedTags = [String]()
    private let maxSelection = 10

    private var collectionView: UICollectionView!

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Tags"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Pick up to 10 tags for your event."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let selectionLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10 selected"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupNavigationBar()
        setupHeader()
        setupCollectionView()
        setupConstraints()

        // Update selection label with the initial count of selected tags
        selectionLabel.text = "\(selectedTags.count)/\(maxSelection) selected"
    }
    
    private func setupNavigationBar() {
        // Change back button to orange
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .systemOrange
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupHeader() {
        view.addSubview(headerLabel)
        view.addSubview(subHeaderLabel)
        view.addSubview(selectionLabel)
        view.addSubview(saveButton)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(44))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            section.boundarySupplementaryItems = [header]

            return section
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
        collectionView.register(CustomSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CustomSectionHeader")
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            selectionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            selectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: subHeaderLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: selectionLabel.topAnchor, constant: -16),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func saveButtonTapped() {
        delegate?.tagViewController(self, didSelectTags: selectedTags)
        navigationController?.popViewController(animated: true)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - UICollectionView DataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tags.keys.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = Array(tags.keys)[section]
        return tags[category]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = Array(tags.keys)[indexPath.section]
        let item = tags[category]?[indexPath.row] ?? ""

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.configure(with: item, isSelected: selectedTags.contains(item))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = Array(tags.keys)[indexPath.section]
        let selectedItem = tags[category]?[indexPath.row] ?? ""

        if let index = selectedTags.firstIndex(of: selectedItem) {
            selectedTags.remove(at: index)
        } else if selectedTags.count < maxSelection {
            selectedTags.append(selectedItem)
        } else {
            let alert = UIAlertController(title: "Limit Reached", message: "You can only select up to \(maxSelection) tags.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

        collectionView.reloadData()
        selectionLabel.text = "\(selectedTags.count)/\(maxSelection) selected"
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CustomSectionHeader", for: indexPath) as! CustomSectionHeader
        let category = Array(tags.keys)[indexPath.section]
        header.configure(with: category)
        return header
    }
}

// Custom UICollectionViewCell for Tag
class TagCell: UICollectionViewCell {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.clipsToBounds = true

        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String, isSelected: Bool) {
        label.text = text
        contentView.backgroundColor = isSelected ? .systemOrange : .white
        contentView.layer.borderColor = isSelected ? UIColor.systemOrange.cgColor : UIColor.lightGray.cgColor
        label.textColor = isSelected ? .white : .black
    }
}

// Custom Header View for Section
class CustomSectionHeader: UICollectionReusableView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        label.text = text
    }
}
