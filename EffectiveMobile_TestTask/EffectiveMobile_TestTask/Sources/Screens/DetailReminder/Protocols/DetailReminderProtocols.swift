//
//  DetailReminderProtocols.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

protocol DetailRemindersViewProtocol: AnyObject {
    // PRESENTER -> VIEW
    func showReminderDetail(with reminder: Task)
}

protocol DetailRemindersPresenterProtocol: AnyObject {
    //View -> Presenter
    var view: DetailRemindersViewProtocol? {get set}
    var router: DetailRemindersRouterProtocol? {get set}

    func viewDidLoad()
    func backButtonPressed(from view: UIViewController)
}

protocol DetailRemindersRouterProtocol: AnyObject {
    //Presenter -> Router
    func goBackToReminderListView(from view: UIViewController)
}
