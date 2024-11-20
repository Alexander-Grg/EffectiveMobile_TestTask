//
//  RemindersRouter.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

final class RemindersRouter: RemindersRouterProtocol {
    func pushToReminderDetail(with reminder: TaskEntity, from view: UIViewController) {
        let detailReminderViewController = DetailReminderViewController.instantiate()
        DetailReminderRouter.createReminderDetailModule(with: detailReminderViewController, and: reminder)
        view.navigationController?.pushViewController(detailReminderViewController, animated: true)
    }
    
    static func createRemindersListModule() -> UIViewController {
        let presenter: RemindersPresenterProtocol & RemindersOutputInteractorProtocol = RemindersPresenter()
        let vc = RemindersViewController.instantiate()
        
        vc.presenter = presenter
        vc.presenter?.router = RemindersRouter()
        vc.presenter?.view = vc
        vc.presenter?.interactor = RemindersInteractor()
        vc.presenter?.interactor?.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: vc)
        return navigationController
    }
}
