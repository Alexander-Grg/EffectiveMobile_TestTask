//
//  DetailReminderPresenter.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

final class DetailReminderPresenter: DetailRemindersPresenterProtocol {
    weak var view: DetailRemindersViewProtocol?
    var router: DetailRemindersRouterProtocol?
    var interactor: DetailReminderInputInteractorProtocol?
    var reminder: Task?
    
    func viewDidLoad() {
        if let task = reminder {
            view?.showReminderDetail(with: task)
        }
    }
    
    func updateReminderTitle(_ newTitle: String) {
        reminder?.todo = newTitle
        saveReminderChanges()
    }
    
    func updateReminderBody(_ newBody: String) {
        //        reminder?.body = newBody
        saveReminderChanges()
    }
    
    private func saveReminderChanges() {
        guard let updatedReminder = reminder else { return }
        interactor?.updateReminder(updatedReminder)
    }
    
    func backButtonPressed(from view: UIViewController) {
        router?.goBackToReminderListView(from: view)
    }
}
