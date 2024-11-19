//
//  RemindersPresenter.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit
import Combine

final class RemindersPresenter: RemindersPresenterProtocol {
    weak var view: RemindersViewProtocol?
    var interactor: RemindersInputInteractorProtocol?
    var router: RemindersRouterProtocol?
    private var cancellables = Set<AnyCancellable>()
    var reminders: [Task] = []

    func viewWillAppear() {
        fetchAllReminders()
    }

    func fetchAllReminders() {
        let isFirstLaunch = AppLaunchChecker().isFirstLaunch

        if isFirstLaunch {
            interactor?.fetchRemindersFromJSON()
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error fetching JSON reminders: \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] jsonReminders in
                    guard let self = self else { return }
                    self.interactor?.saveRemindersToCoreData(jsonReminders)
                    self.fetchCoreDataReminders()
                })
                .store(in: &cancellables)
        } else {
            self.fetchCoreDataReminders()
        }
    }

    func fetchCoreDataReminders() {
        interactor?.fetchCoreDataReminders()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching CoreData reminders: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] coreDataReminders in
                guard let self = self else { return }
                self.reminders = coreDataReminders
                self.view?.showReminders(with: coreDataReminders)
            })
            .store(in: &cancellables)
    }

    func toggleReminderCompletion(reminder: Task) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].completed.toggle()
            interactor?.toggleReminderCompletion(reminders[index])
            view?.showReminders(with: reminders)
        }
    }

    func showReminderSelection(with reminder: Task, from view: UIViewController) {
        router?.pushToReminderDetail(with: reminder, from: view)
    }

    func deleteReminder(_ reminder: Task) {
        interactor?.deleteReminder(reminder)
    }

    func updateReminder(_ reminder: Task) {
        interactor?.updateReminderInCoreData(reminder)
    }
}

extension RemindersPresenter: RemindersOutputInteractorProtocol {
    func remindersDidFetch(reminders: [Task]) {
    }
}
