//
//  DetailReminderProtocols.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit

protocol DetailRemindersViewProtocol: AnyObject {
    func showReminderDetail(with reminder: Task)
}

protocol DetailRemindersPresenterProtocol: AnyObject {
    var view: DetailRemindersViewProtocol? {get set}
    var router: DetailRemindersRouterProtocol? {get set}
    
    func viewDidLoad()
    func backButtonPressed(from view: UIViewController)
}

protocol DetailReminderInputInteractorProtocol: AnyObject {
    func updateReminder(_ reminder: Task)
}

protocol DetailReminderOutputInteractorProtocol: AnyObject {
}

protocol DetailRemindersRouterProtocol: AnyObject {
    func goBackToReminderListView(from view: UIViewController)
}
