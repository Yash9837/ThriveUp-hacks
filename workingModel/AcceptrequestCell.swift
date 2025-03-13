//
//  AcceptRequestCell.swift
//  ThriveUp
//
//  Created by Sanidhya's MacBook Pro on 09/03/25.
//

import UIKit

protocol AcceptRequestCellDelegate: AnyObject {
    func didAcceptRequest(_ request: AcceptRequest)
    func didRejectRequest(_ request: AcceptRequest)
}

class AcceptRequestCell: UITableViewCell {
    var request: AcceptRequest?
    weak var delegate: AcceptRequestCellDelegate?

    private let nameLabel = UILabel()
    private let acceptButton = UIButton(type: .system)
    private let rejectButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        rejectButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(nameLabel)
        contentView.addSubview(acceptButton)
        contentView.addSubview(rejectButton)

        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)

        rejectButton.setTitle("Reject", for: .normal)
        rejectButton.addTarget(self, action: #selector(handleReject), for: .touchUpInside)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            acceptButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            acceptButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            rejectButton.trailingAnchor.constraint(equalTo: acceptButton.leadingAnchor, constant: -8),
            rejectButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with request: AcceptRequest) {
        self.request = request
        nameLabel.text = "Request from \(request.senderId)"
    }

    @objc private func handleAccept() {
        guard let request = request else { return }
        delegate?.didAcceptRequest(request)
    }

    @objc private func handleReject() {
        guard let request = request else { return }
        delegate?.didRejectRequest(request)
    }
}
