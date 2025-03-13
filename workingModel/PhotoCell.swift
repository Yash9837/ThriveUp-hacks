//
//  PhotoCell.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 18/11/24.
//
//import UIKit
//
//class PhotoCell: UICollectionViewCell {
//    static let identifier = "PhotoCell"
//    
//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.addSubview(imageView)
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        ])
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(with imageName: String) {
//        imageView.image = UIImage(named: imageName)
//    }
//}
