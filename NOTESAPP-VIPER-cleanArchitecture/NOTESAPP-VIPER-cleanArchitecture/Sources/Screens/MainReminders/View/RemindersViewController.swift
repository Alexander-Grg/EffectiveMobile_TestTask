//
//  RemindersViewController.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//
import UIKit

final class RemindersViewController: UIViewController, RemindersViewProtocol, StoryBoarded {
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ReminderCell.self, forCellReuseIdentifier: ReminderCell.defaultReuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private(set) lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .systemBlue
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        return searchController
    }()

    private(set) lazy var createButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = AppColor.yellowSpecial.color
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()

    private(set) lazy var totalRemindersLabel: UILabel = {
        let label = UILabel()
        label.text = "\(reminders.count) Задач"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var footerView: UIView = {
        let footer = UIView()
        footer.backgroundColor = .systemBackground
        footer.translatesAutoresizingMaskIntoConstraints = false

        footer.addSubview(totalRemindersLabel)
        footer.addSubview(createButton)

        NSLayoutConstraint.activate([
            footer.heightAnchor.constraint(equalToConstant: 49),
            totalRemindersLabel.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            totalRemindersLabel.centerYAnchor.constraint(equalTo: footer.centerYAnchor),

            createButton.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16),
            createButton.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
            createButton.widthAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        return footer
    }()

    var presenter: RemindersPresenterProtocol?
    private var reminders: [TaskEntity] = []
    private var filteredReminders: [TaskEntity] = []
    private var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    private func configureUI() {
        view.addSubview(tableView)
        view.addSubview(footerView)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        configureNavigationTitle()
        configureBackButton()
        setupConstraints()
    }

    private func configureBackButton() {
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        backButton.tintColor = AppColor.yellowSpecial.color
        navigationItem.backBarButtonItem = backButton
    }

    private func configureNavigationTitle() {
        title = "Задачи"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    @objc private func addButtonTapped() {
        presenter?.createNewReminder(from: self)
    }

    func showReminders(with reminders: [TaskEntity]) {
        self.reminders = reminders
        updateFooterLabel()
        tableView.reloadData()
    }

    private func updateFooterLabel() {
        totalRemindersLabel.text = "\(reminders.count) Задач"
    }

    private func enableEditing(for reminder: TaskEntity, at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ReminderCell else { return }
        cell.enableEditingMode()
    }

    private func shareReminder(_ reminder: TaskEntity) {
        print("Share reminder: \(String(describing: reminder.todo))")
    }

    private func deleteReminder(_ reminder: TaskEntity, at indexPath: IndexPath) {
        tableView.performBatchUpdates({
            if isSearching {
                if let originalIndex = reminders.firstIndex(where: { $0.id == reminder.id }) {
                    reminders.remove(at: originalIndex)
                }
                filteredReminders.remove(at: indexPath.row)
            } else {
                reminders.remove(at: indexPath.row)
            }
            presenter?.deleteReminder(reminder)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }, completion: { _ in
            self.updateFooterLabel()
        })
    }
}

extension RemindersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredReminders.count : reminders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.defaultReuseIdentifier, for: indexPath) as? ReminderCell else {
            return UITableViewCell()
        }

        let reminder = isSearching ? filteredReminders[indexPath.row] : reminders[indexPath.row]
        cell.configure(with: reminder)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedReminder = isSearching ? filteredReminders[indexPath.row] : reminders[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.showReminderSelection(with: selectedReminder, from: self)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let reminder = isSearching ? filteredReminders[indexPath.row] : reminders[indexPath.row]

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.enableEditing(for: reminder, at: indexPath)
            }

            let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.shareReminder(reminder)
            }

            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deleteReminder(reminder, at: indexPath)
            }

            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
}

extension RemindersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            isSearching = false
            filteredReminders.removeAll()
            tableView.reloadData()
            return
        }

        isSearching = true
        filteredReminders = reminders.filter { reminder in
            guard let todo = reminder.todo else { return false }
            return todo.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

extension RemindersViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        filteredReminders.removeAll()
        tableView.reloadData()
    }
}

extension RemindersViewController: ReminderCellDelegate {
    func reminderCell(_ cell: ReminderCell, didUpdateReminderTitle newTitle: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        // Update the data model
        let reminder = isSearching ? filteredReminders[indexPath.row] : reminders[indexPath.row]
        reminder.todo = newTitle

        presenter?.updateReminder(reminder)

        // Reflect the changes in the appropriate list
        if isSearching {
            filteredReminders[indexPath.row] = reminder
        } else {
            reminders[indexPath.row] = reminder
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func reminderCell(_ cell: ReminderCell, didUpdateReminderCompletion isCompleted: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let reminder = isSearching ? filteredReminders[indexPath.row] : reminders[indexPath.row]
        reminder.isCompleted = isCompleted

        presenter?.updateReminder(reminder)

        if isSearching {
            filteredReminders[indexPath.row] = reminder
        } else {
            reminders[indexPath.row] = reminder
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
