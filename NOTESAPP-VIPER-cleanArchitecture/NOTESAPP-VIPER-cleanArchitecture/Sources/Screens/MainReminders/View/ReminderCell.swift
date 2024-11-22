//
//  ReminderCell.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

protocol ReminderCellDelegate: AnyObject {
    func reminderCell(_ cell: ReminderCell, didUpdateReminderTitle newTitle: String)
    func reminderCell(_ cell: ReminderCell, didUpdateReminderCompletion isCompleted: Bool)
}

final class ReminderCell: UITableViewCell, UITextFieldDelegate {

    weak var delegate: ReminderCellDelegate?

    private(set) lazy var checkmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
        return button
    }()

    private(set) lazy var reminderTitleTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.isHidden = true
        textField.delegate = self
        return textField
    }()

    private(set) lazy var reminderTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private(set) lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private(set) lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var originalTitleText: String?
    private var isCompleted: Bool = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        contentView.addSubview(checkmarkButton)
        contentView.addSubview(reminderTitleLabel)
        contentView.addSubview(reminderTitleTextField)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 24),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 24),

            reminderTitleLabel.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 8),
            reminderTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reminderTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            reminderTitleTextField.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 8),
            reminderTitleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reminderTitleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            reminderTitleTextField.heightAnchor.constraint(equalTo: reminderTitleLabel.heightAnchor),

            subTitleLabel.leadingAnchor.constraint(equalTo: reminderTitleLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: reminderTitleLabel.trailingAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: reminderTitleLabel.bottomAnchor, constant: 4),

            dateLabel.leadingAnchor.constraint(equalTo: reminderTitleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: reminderTitleLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        reminderTitleLabel.isHidden = false
        reminderTitleTextField.isHidden = true
        reminderTitleLabel.attributedText = nil
        reminderTitleLabel.text = nil
        reminderTitleTextField.text = nil
        originalTitleText = nil
        isCompleted = false
    }

    func configure(with reminder: TaskEntity) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        self.originalTitleText = reminder.todo
        self.isCompleted = reminder.isCompleted
        self.reminderTitleLabel.text = reminder.todo
        self.reminderTitleTextField.text = reminder.todo
        self.dateLabel.text = formatter.string(from: reminder.date ?? Date())
        self.subTitleLabel.text = reminder.body
        updateCheckmarkState()
    }

    @objc private func checkmarkTapped() {
        isCompleted.toggle()
        updateCheckmarkState()
        delegate?.reminderCell(self, didUpdateReminderCompletion: isCompleted)
    }

    private func updateCheckmarkState() {
        checkmarkButton.setImage(
            UIImage(systemName: isCompleted ? "checkmark.circle" : "circle"),
            for: .normal
        )
        checkmarkButton.tintColor = AppColor.yellowSpecial.color

        if isCompleted {
            let attributedText = NSAttributedString(
                string: originalTitleText ?? "",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.gray
                ]
            )
            reminderTitleLabel.attributedText = attributedText
        } else {
            reminderTitleLabel.attributedText = nil
            reminderTitleLabel.text = originalTitleText
        }
    }

    func enableEditingMode() {
        reminderTitleLabel.isHidden = true
        reminderTitleTextField.isHidden = false
        reminderTitleTextField.becomeFirstResponder()
    }

    func disableEditingMode() {
        reminderTitleLabel.isHidden = false
        reminderTitleTextField.isHidden = true
        reminderTitleTextField.resignFirstResponder()
        reminderTitleLabel.text = reminderTitleTextField.text
        originalTitleText = reminderTitleTextField.text
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let newText = textField.text, !newText.isEmpty else { return }
        delegate?.reminderCell(self, didUpdateReminderTitle: newText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveEditedReminder()
        return true
    }

    private func saveEditedReminder() {
        guard let newTitle = reminderTitleTextField.text, !newTitle.isEmpty else { return }
        reminderTitleLabel.text = newTitle
        originalTitleText = newTitle

        reminderTitleLabel.isHidden = false
        reminderTitleTextField.isHidden = true

        delegate?.reminderCell(self, didUpdateReminderTitle: newTitle)
    }
}
