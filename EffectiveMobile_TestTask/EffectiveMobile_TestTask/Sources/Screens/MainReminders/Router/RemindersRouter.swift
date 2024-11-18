//
//  RemindersRouter.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

final class RemindersRouter: RemindersRouterProtocol {
    func pushToReminderDetail(with reminder: Task, from view: UIViewController) {
//         let DetailReminderViewController = view.storyboard?.instantiateViewController(withIdentifier: "DetailReminderViewController") as! DetailReminderView
     }

    class func createRemindersListModule(remindersListRef: RemindersViewController) {
         let presenter: RemindersPresenterProtocol & RemindersOutputInteractorProtocol = RemindersPresenter()

         remindersListRef.presenter = presenter
         remindersListRef.presenter?.router = RemindersRouter()
         remindersListRef.presenter?.view = remindersListRef
         remindersListRef.presenter?.interactor = RemindersInteractor(remindersService: TaskSearchService())
         remindersListRef.presenter?.interactor?.presenter = presenter
     }
}
