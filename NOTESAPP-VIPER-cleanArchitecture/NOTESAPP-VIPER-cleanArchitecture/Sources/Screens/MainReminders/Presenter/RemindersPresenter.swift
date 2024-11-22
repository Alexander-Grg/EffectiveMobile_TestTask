//
//  RemindersPresenter.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//
import UIKit
import Combine
import CoreData

final class RemindersPresenter: RemindersPresenterProtocol {
    @Injected(\.appLaunchChecker) var appLaunchChecker
    weak var view: RemindersViewProtocol?
    var interactor: RemindersInputInteractorProtocol?
    var router: RemindersRouterProtocol?
    private var cancellables = Set<AnyCancellable>()
    var reminders: [TaskEntity] = []
    
    func viewWillAppear() {
        fetchAllReminders()
    }
    
    func fetchAllReminders() {
        if appLaunchChecker.isFirstLaunch {
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
            fetchCoreDataReminders()
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
    
    func toggleReminderCompletion(reminder: TaskEntity) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isCompleted.toggle()
            interactor?.toggleReminderCompletion(reminders[index])
            view?.showReminders(with: reminders)
        }
    }
    
    func showReminderSelection(with reminder: TaskEntity, from view: UIViewController) {
        router?.pushToReminderDetail(with: reminder, from: view)
    }
    
    func deleteReminder(_ reminder: TaskEntity) {
        interactor?.deleteReminder(reminder)
        reminders.removeAll { $0.id == reminder.id }
        view?.showReminders(with: reminders)
    }
    
    func updateReminder(_ reminder: TaskEntity) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        }
        interactor?.updateReminderInCoreData(reminder)
        view?.showReminders(with: reminders)
    }
    
    func createNewReminder(from view: UIViewController) {
        if let router = router {
            interactor?.createNewReminder(from: view, router: router)
        }
    }
}

extension RemindersPresenter: RemindersOutputInteractorProtocol {
}
