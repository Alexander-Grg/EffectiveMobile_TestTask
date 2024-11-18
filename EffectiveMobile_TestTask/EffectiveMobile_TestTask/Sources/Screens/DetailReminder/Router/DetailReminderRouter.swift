//
//  DetailReminderRouter.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

final class DetailReminderRouter: DetailRemindersRouterProtocol {
    
    class func createReminderDetailModule(with reminderDetailRef: DetailReminderViewController, and reminder: Task) {
        let presenter = DetailReminderPresenter()
        presenter.reminder = reminder
        reminderDetailRef.presenter = presenter
        reminderDetailRef.presenter?.view = reminderDetailRef
        reminderDetailRef.presenter?.router = DetailReminderRouter()
    }

    func goBackToReminderListView(from view: UIViewController)  {

    }
}
