//
//  RemindersProtocols.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit
import Combine

protocol RemindersViewProtocol: AnyObject {
    // PRESENTER -> VIEW
    func showReminders(with reminder: [Task])
}

protocol RemindersPresenterProtocol: AnyObject {
    //View -> Presenter
    var interactor: RemindersInputInteractorProtocol? {get set}
    var view: RemindersViewProtocol? {get set}
    var router: RemindersRouterProtocol? {get set}

    func viewDidLoad()
}

protocol RemindersInputInteractorProtocol: AnyObject {
    var presenter: RemindersOutputInteractorProtocol? {get set}
    //Presenter -> Interactor
    func fetchReminders() -> AnyPublisher<[Task], Never>
}

protocol RemindersOutputInteractorProtocol: AnyObject {
    //Interactor -> Presenter
    func remindersDidFetch(reminders: [Task])
}

protocol RemindersRouterProtocol: AnyObject {
    //Presenter -> Router
    func pushToReminderDetail(with reminder: Task,from view: UIViewController)
    static func createRemindersListModule(remindersListRef: RemindersViewController)
}
