//
//  Mocks.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 20/11/24.
//
import Combine
import CoreData
import Foundation
@testable import EffectiveMobile_TestTask
import UIKit

final class MockCoreDataService: CoreDataServiceProtocol {
    var context: NSManagedObjectContext = {
          let container = NSPersistentContainer(name: "EffectiveMobile_TestTask")
          let description = NSPersistentStoreDescription()
          description.url = URL(fileURLWithPath: "/dev/null")
          container.persistentStoreDescriptions = [description]
          container.loadPersistentStores { _, error in
              if let error = error {
                  fatalError("Failed to load persistent store: \(error)")
              }
          }
          return container.viewContext
      }()
    
    private var storedTasks: [TaskEntity] = []
    var saveOrUpdateEntityCalled = false
    var savedOrUpdatedEntity: TaskEntity?

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func saveContext() { }
    func fetchTasks() -> [TaskEntity] { return [] }
    func saveTasks(_ tasks: [Task]) { }
    func deleteTask(byId id: String) { }
    func saveOrUpdateEntity(_ entity: TaskEntity) {
        saveOrUpdateEntityCalled = true
        savedOrUpdatedEntity = entity
    }
    func saveNewReminder(_ reminder: TaskEntity) { }
}

class MockRemindersInteractor: RemindersInputInteractorProtocol {
    weak var presenter: RemindersOutputInteractorProtocol?

    var savedReminders: [TaskEntity] = []
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    var fetchRemindersFromJSONCalled = false
    var saveRemindersToCoreDataCalled = false
    var toggleReminderCompletionCalled = false
    var deleteReminderCalled = false
    var updateReminderInCoreDataCalled = false
    var createNewReminderCalled = false

    var mockFetchRemindersFromJSONResult: AnyPublisher<[Task], Never> = Just([]).eraseToAnyPublisher()
    var mockFetchCoreDataRemindersResult: AnyPublisher<[TaskEntity], Error> = Just([])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    var fetchCoreDataRemindersCalled = false

    func fetchRemindersFromJSON() -> AnyPublisher<[Task], Never> {
        fetchRemindersFromJSONCalled = true
        return mockFetchRemindersFromJSONResult
    }

    func saveRemindersToCoreData(_ reminders: [Task]) {
        saveRemindersToCoreDataCalled = true

        reminders.forEach { task in
            let entity = TaskEntity(context: context)
            entity.id = String(task.id)
            entity.todo = task.todo
            entity.isCompleted = task.completed
            entity.userId = String(task.userID)
            savedReminders.append(entity)
        }
    }

    func fetchCoreDataReminders() -> AnyPublisher<[TaskEntity], Error> {
        fetchCoreDataRemindersCalled = true
        return mockFetchCoreDataRemindersResult
    }

    func toggleReminderCompletion(_ reminder: TaskEntity) {
        toggleReminderCompletionCalled = true
        if let index = savedReminders.firstIndex(where: { $0.id == reminder.id }) {
            savedReminders[index].isCompleted.toggle()
        }
    }

    func deleteReminder(_ reminder: TaskEntity) {
        deleteReminderCalled = true
        savedReminders.removeAll { $0.id == reminder.id }
    }

    func updateReminderInCoreData(_ reminder: TaskEntity) {
        updateReminderInCoreDataCalled = true
        if let index = savedReminders.firstIndex(where: { $0.id == reminder.id }) {
            savedReminders[index] = reminder
        }
    }

    func createNewReminder(from view: UIViewController, router: RemindersRouterProtocol) {
        createNewReminderCalled = true
        let newReminder = TaskEntity(context: context)
        newReminder.id = UUID().uuidString
        newReminder.todo = "New Reminder"
        newReminder.isCompleted = false
        newReminder.body = ""
        savedReminders.append(newReminder)
    }
}

class MockRemindersRouter: RemindersRouterProtocol {
    static func createRemindersListModule() -> UIViewController {
        return UIViewController()
    }

    var pushToReminderDetailCalled = false
    var pushedReminder: TaskEntity?

    func pushToReminderDetail(with reminder: TaskEntity, from view: UIViewController) {
        pushToReminderDetailCalled = true
        pushedReminder = reminder
    }
}

class MockRemindersPresenter: RemindersPresenterProtocol {
    var interactor: RemindersInputInteractorProtocol?
    var view: RemindersViewProtocol?
    var router: RemindersRouterProtocol?

    var viewWillAppearCalled = false
    var showReminderSelectionCalled = false
    var deleteReminderCalled = false
    var updateReminderCalled = false
    var createNewReminderCalled = false

    func viewWillAppear() {
        viewWillAppearCalled = true
    }

    func showReminderSelection(with reminder: TaskEntity, from view: UIViewController) {
        showReminderSelectionCalled = true
    }

    func deleteReminder(_ reminder: TaskEntity) {
        deleteReminderCalled = true
    }

    func updateReminder(_ reminder: TaskEntity) {
        updateReminderCalled = true
    }

    func createNewReminder(from view: UIViewController) {
        createNewReminderCalled = true
    }
}

class MockRemindersView: RemindersViewProtocol {
    var remindersShown: [TaskEntity] = []

    func showReminders(with reminders: [TaskEntity]) {
        remindersShown = reminders
    }
}

class MockAppLaunchChecker: AppLaunchCheckerProtocol {
    var isFirstLaunch = false
}

class MockNavigationController: UINavigationController {
    var pushedViewController: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: animated)
    }
}

final class MockDetailReminderView: DetailRemindersViewProtocol {
    var showReminderDetailCalled = false
    var reminderShown: TaskEntity?

    func showReminderDetail(with reminder: TaskEntity) {
        showReminderDetailCalled = true
        reminderShown = reminder
    }
}

final class MockDetailReminderRouter: DetailRemindersRouterProtocol {
    var goBackToReminderListViewCalled = false

    func goBackToReminderListView(from view: UIViewController) {
        goBackToReminderListViewCalled = true
    }
}

final class MockDetailReminderInteractor: DetailReminderInputInteractorProtocol {
    var saveOrUpdateReminderCalled = false
    var reminderPassed: TaskEntity?

    func saveOrUpdateReminder(_ reminder: TaskEntity) {
        saveOrUpdateReminderCalled = true
        reminderPassed = reminder
    }
}
