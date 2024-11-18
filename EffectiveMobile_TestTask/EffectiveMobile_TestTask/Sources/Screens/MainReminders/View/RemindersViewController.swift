//
//  RemindersViewController.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

final class RemindersViewController: UIViewController, RemindersViewProtocol, StoryBoarded {
    func showReminders(with reminder: [Task]) {

    }

    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ReminderCell.self, forCellReuseIdentifier: ReminderCell.defaultReuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private(set) lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search reminders..."
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        return searchBar
    }()

    private(set) lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()

    var presenter: RemindersPresenterProtocol!
    private var reminders: [Task] = []
    private var filteredReminders: [String] = []
    private var isSearching = false

    private var mockNames: [String] = ["John", "Mike", "Alex", "Max", "Tom", "Bob", "Kate", "Anna", "Lena", "Sasha"]

    override func viewDidLoad() {
        super.viewDidLoad()
        RemindersRouter.createRemindersListModule(remindersListRef: self)
        configureUI()
        presenter.viewDidLoad()
    }

    private func configureUI() {
        view.addSubview(tableView)
        view.addSubview(addButton)
        self.configureNavigationTitle()
        self.setupSearchBar()
        setupConstraints()
    }

    private func configureNavigationTitle() {
        title = "Задачи"
           navigationController?.navigationBar.prefersLargeTitles = true
           navigationItem.largeTitleDisplayMode = .always
           navigationController?.navigationBar.largeTitleTextAttributes = [
               .font: UIFont.systemFont(ofSize: 34, weight: .bold),
               .foregroundColor: UIColor.label
           ]
    }

    private func setupSearchBar() {
        tableView.tableHeaderView = searchBar
        tableView.tableHeaderView?.frame.size.height = 50 // Set height for the search bar
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func addButtonTapped() {
//        presenter.didTapAddButton()
    }
}

extension RemindersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.defaultReuseIdentifier, for: indexPath) as? ReminderCell else {
            return UITableViewCell()
        }

        cell.configure(with: mockNames[indexPath.row])
        // Configure cell
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let reminder = reminders[indexPath.row]
//        presenter.didSelectReminder(reminder)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RemindersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredReminders.removeAll()
        } else {
            isSearching = true
            filteredReminders = mockNames.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}
