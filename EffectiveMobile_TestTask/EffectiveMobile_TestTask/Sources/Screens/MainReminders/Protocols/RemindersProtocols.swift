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
    func showReminders(with reminder: [TaskEntity])
}

protocol RemindersPresenterProtocol: AnyObject {
    var interactor: RemindersInputInteractorProtocol? { get set }
    var view: RemindersViewProtocol? { get set }
    var router: RemindersRouterProtocol? { get set }
    
    func viewWillAppear()
    func showReminderSelection(with reminder: TaskEntity, from view: UIViewController)
    func deleteReminder(_ reminder: TaskEntity)
    func updateReminder(_ reminder: TaskEntity)
    func createNewReminder(from view: UIViewController)
}

protocol RemindersInputInteractorProtocol: AnyObject {
    // Presenter -> Interactor
    var presenter: RemindersOutputInteractorProtocol? { get set }
    func fetchRemindersFromJSON() -> AnyPublisher<[Task], Never>
    func saveRemindersToCoreData(_ reminders: [Task])
    func fetchCoreDataReminders() -> AnyPublisher<[TaskEntity], Error>
    func toggleReminderCompletion(_ reminder: TaskEntity)
    func deleteReminder(_ reminder: TaskEntity)
    func updateReminderInCoreData(_ reminder: TaskEntity)
    func createNewReminder(from view: UIViewController, router: RemindersRouterProtocol)
}

protocol RemindersOutputInteractorProtocol: AnyObject {
    // Interactor -> Presenter
    func remindersDidFetch(reminders: [TaskEntity])
}

protocol RemindersRouterProtocol: AnyObject {
    // Presenter -> Router
    static func createRemindersListModule() -> UIViewController
    func pushToReminderDetail(with reminder: TaskEntity, from view: UIViewController)
}
