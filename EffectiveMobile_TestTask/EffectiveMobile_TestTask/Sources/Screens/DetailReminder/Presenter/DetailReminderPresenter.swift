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
    var reminder: Task?

    func viewDidLoad() {
//         view?.showRemainderDetail(with: reminder!)
     }

     func backButtonPressed(from view: UIViewController) {

     }
}
