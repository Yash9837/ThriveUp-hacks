//
//  SpeakerCell.swift
//  workingModel
//
//  Created by Yash's Mackbook on 13/11/24.
//
//import UIKit
//
//class SpeakerCell: UICollectionViewCell {
//    
//    static let identifier = "SpeakerCell"
//    
//     let imageView: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFill
//        iv.clipsToBounds = true
//        iv.layer.cornerRadius = 40 // Make it circular (width / 2)
//        return iv
//    }()
//    
//     let nameLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = .black
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        contentView.addSubview(imageView)
//        contentView.addSubview(nameLabel)
//        
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            // ImageView constraints
//            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            imageView.widthAnchor.constraint(equalToConstant: 80),
//            imageView.heightAnchor.constraint(equalToConstant: 80),
//            
//            // Label constraints
//            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
//            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//        ])
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(with speaker: Speaker) {
//        imageView.image = UIImage(named: speaker.imageURL) // Assuming `imageName` is a property of Speaker
//        nameLabel.text = speaker.name
//    }
//}
