//
//  DetailReminderViewController.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

final class DetailReminderViewController: UIViewController, DetailRemindersViewProtocol, StoryBoarded {
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 34, weight: .bold)
        textField.textAlignment = .left
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.delegate = self
        textField.addTarget(self, action: #selector(titleEditingDidEnd), for: .editingDidEnd)
        return textField
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()

    private lazy var bodyTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.isEditable = true
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    var presenter: DetailReminderPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }

    func showReminderDetail(with reminder: TaskEntity) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        titleTextField.text = reminder.todo
        dateLabel.text = formatter.string(for: Date())
        bodyTextView.text = reminder.body
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        view.addSubview(stackView)
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(bodyTextView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    @objc private func titleEditingDidEnd() {
        guard let updatedTitle = titleTextField.text, !updatedTitle.isEmpty else { return }
        presenter?.updateReminderTitle(updatedTitle)
    }
}

extension DetailReminderViewController: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == bodyTextView else { return }
        guard let updatedBody = textView.text else { return }
        presenter?.updateReminderBody(updatedBody)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        titleEditingDidEnd()
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        guard textView == bodyTextView else { return }
        guard let updatedBody = textView.text else { return }

        presenter?.updateReminderBody(updatedBody)
    }
}
