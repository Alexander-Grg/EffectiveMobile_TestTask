//
//  ReminderCell.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

final class ReminderCell: UITableViewCell {

    private(set) lazy var reminderTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        contentView.addSubview(reminderTitleLabel)

        // Add Auto Layout constraints
        NSLayoutConstraint.activate([
            reminderTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reminderTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reminderTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            reminderTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with title: String) {
        reminderTitleLabel.text = title
    }
}
