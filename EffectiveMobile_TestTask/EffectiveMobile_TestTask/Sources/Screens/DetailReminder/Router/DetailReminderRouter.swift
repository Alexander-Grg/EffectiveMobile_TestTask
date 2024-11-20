//
//  DetailReminderRouter.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

final class DetailReminderRouter: DetailRemindersRouterProtocol {
    
    class func createReminderDetailModule(with reminderDetailRef: DetailReminderViewController, and reminder: TaskEntity) {
        let presenter = DetailReminderPresenter()
        let interactor = DetailReminderInteractor()
        let router = DetailReminderRouter()
        
        presenter.reminder = reminder
        reminderDetailRef.presenter = presenter
        reminderDetailRef.presenter?.view = reminderDetailRef
        reminderDetailRef.presenter?.interactor = interactor
        reminderDetailRef.presenter?.router = router
    }
    
    func goBackToReminderListView(from view: UIViewController) {
        view.navigationController?.popViewController(animated: true)
    }
}
