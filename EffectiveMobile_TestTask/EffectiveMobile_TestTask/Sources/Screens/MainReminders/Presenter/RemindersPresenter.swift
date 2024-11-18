//
//  RemindersPresenter.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

final class RemindersPresenter: RemindersPresenterProtocol {
    weak var view: RemindersViewProtocol?
    var interactor: RemindersInputInteractorProtocol?
    var router: RemindersRouterProtocol?


    func viewDidLoad() {
        //        view?.showLoadingIndicator()
        //        interactor.fetchReminders()
    }

    //       func loadReminders() {
    //           interactor?.fetchReminders()
    //       }

    //    func showReminderSelection(with reminder: Task, from view: UIViewController) {
    //           router?.pushToReminderDetail(with: Task, from: view)
    //       }
}

extension RemindersPresenter: RemindersOutputInteractorProtocol {
    func remindersDidFetch(reminders: [Task]) {
//         view?.showReminders(with: )
     }
}
