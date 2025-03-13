//
//  ChatMessageCell.swift
//  ThriveUp
//
//  Created by palak seth on 15/11/24.
//

//
//  ChatMessageCell.swift
//  ThriveUp
//
//  Created by palak seth on 15/11/24.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    private let messageLabel = UILabel()
    private let bubbleBackgroundView = UIView()
    
    var isIncoming: Bool = true {
        didSet {
            bubbleBackgroundView.backgroundColor = isIncoming ? UIColor(white: 0.9, alpha: 1) : UIColor.systemOrange
            messageLabel.textColor = isIncoming ? .black : .white
            
            // Adjust alignment of the bubble based on the message direction
            leadingConstraint.isActive = isIncoming
            trailingConstraint.isActive = !isIncoming
        }
    }
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Cell appearance settings
        backgroundColor = .clear
        selectionStyle = .none
        
        // Configure bubble background
        bubbleBackgroundView.layer.cornerRadius = 15
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleBackgroundView)
        
        // Configure message label
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        
        // Define constraints for the bubble and message label
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -12),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 12)
        ])
        
        // Set up leading and trailing constraints to control alignment
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.messageContent
        isIncoming = !message.isSender
    }
}


#Preview{
    ChatMessageCell()
}
