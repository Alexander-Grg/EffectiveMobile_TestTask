//
//  DetailReminderPresenter.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit
import Combine

final class DetailReminderPresenter: DetailRemindersPresenterProtocol {
    weak var view: DetailRemindersViewProtocol?
    var router: DetailRemindersRouterProtocol?
    var interactor: DetailReminderInputInteractorProtocol?
    var reminder: TaskEntity?
    
    func viewDidLoad() {
        if let reminderEntity = reminder {
            view?.showReminderDetail(with: reminderEntity)
        }
    }
    
    func updateReminderTitle(_ newTitle: String) {
        guard let reminder = reminder else { return }
        reminder.todo = newTitle
        interactor?.saveOrUpdateReminder(reminder)
    }
    
    func updateReminderBody(_ newBody: String) {
        guard let reminder = reminder else { return }
        reminder.body = newBody
        interactor?.saveOrUpdateReminder(reminder)
    }
    
    private func isNewReminder(_ reminder: TaskEntity) -> Bool {
        return reminder.todo?.isEmpty ?? true || reminder.id == ""
    }
    
    private func saveReminderChanges() {
        guard let updatedReminder = reminder else { return }
        if isNewReminder(updatedReminder) {
            interactor?.saveOrUpdateReminder(updatedReminder)
        } else {
            interactor?.saveOrUpdateReminder(updatedReminder)
        }
    }
    
    func backButtonPressed(from view: UIViewController) {
        router?.goBackToReminderListView(from: view)
    }
}
