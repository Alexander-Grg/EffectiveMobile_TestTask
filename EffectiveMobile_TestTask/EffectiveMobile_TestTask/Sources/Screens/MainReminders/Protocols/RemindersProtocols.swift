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

    //    func viewDidLoad()
    func viewWillAppear()
    func showReminderSelection(with reminder: Task, from view: UIViewController)
    func deleteReminder(_ reminder: Task)
    func updateReminder(_ reminder: Task)
}

protocol RemindersInputInteractorProtocol: AnyObject {
    var presenter: RemindersOutputInteractorProtocol? {get set}
    //Presenter -> Interactor
    func fetchRemindersFromJSON() -> AnyPublisher<[Task], Never>
    func saveRemindersToCoreData(_ reminders: [Task])
    func fetchCoreDataReminders() -> AnyPublisher<[Task], Error>
    func toggleReminderCompletion(_ reminder: Task)
    func deleteReminder(_ reminder: Task)
    func updateReminderInCoreData(_ reminder: Task)
}

protocol RemindersOutputInteractorProtocol: AnyObject {
    //Interactor -> Presenter
    func remindersDidFetch(reminders: [Task])
}

protocol RemindersRouterProtocol: AnyObject {
    //Presenter -> Router
    static func createRemindersListModule() -> UIViewController
    func pushToReminderDetail(with reminder: Task, from view: UIViewController)
}
