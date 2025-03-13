import UIKit

class CategoryHeader: UICollectionReusableView {
    static let identifier = "CategoryHeader"
    
    let titleLabel = UILabel()
    let arrowButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(arrowButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            arrowButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        arrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        arrowButton.tintColor = UIColor.systemBlue // Replace with your app's theme color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

