//
//  RemindersPresenterTests.swift
//  EffectiveMobile_TestTaskTests
//
//  Created by Alexander Grigoryev on 20/11/24.
//

import XCTest
import Combine
import CoreData
@testable import EffectiveMobile_TestTask

class RemindersPresenterTests: XCTestCase {
    var presenter: RemindersPresenter!
    var mockView: MockRemindersView!
    var mockInteractor: MockRemindersInteractor!
    var mockRouter: MockRemindersRouter!
    var mockAppLaunchChecker: MockAppLaunchChecker!
    var mockCoreData: MockCoreDataService!
    var context: NSManagedObjectContext!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        // Create an in-memory persistent container for testing
        let persistentContainer = NSPersistentContainer(name: "EffectiveMobile_TestTask")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to set up in-memory Core Data stack: \(error)")
            }
        }

        // Assign the context from the in-memory persistent container
        context = persistentContainer.viewContext
        mockCoreData = MockCoreDataService(context: context)
        mockView = MockRemindersView()
        mockInteractor = MockRemindersInteractor(context: context)
        mockRouter = MockRemindersRouter()
        mockAppLaunchChecker = MockAppLaunchChecker()

        presenter = RemindersPresenter()
        presenter.view = mockView
        presenter.interactor = mockInteractor
        presenter.router = mockRouter
        presenter.appLaunchChecker = mockAppLaunchChecker
        cancellables = []
    }

    override func tearDown() {
        presenter = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        mockAppLaunchChecker = nil
        cancellables = nil
        super.tearDown()
    }

    func testViewWillAppear_FirstLaunch_FetchesJSONReminders() {
        // Given
        mockAppLaunchChecker.isFirstLaunch = true
        let jsonReminders = [Task(id: 1, todo: "Task 1", completed: false, userID: 101)]
        mockInteractor.mockFetchRemindersFromJSONResult = Just(jsonReminders)
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()

        // When
        presenter.viewWillAppear()

        // Then
        XCTAssertTrue(mockInteractor.fetchRemindersFromJSONCalled)
        XCTAssertTrue(mockInteractor.saveRemindersToCoreDataCalled)
        XCTAssertEqual(mockInteractor.savedReminders.count, 1)
        XCTAssertEqual(mockInteractor.savedReminders.first?.todo, "Task 1")
    }

    func testViewWillAppear_NotFirstLaunch_FetchesCoreDataReminders() {
        // Given
        mockAppLaunchChecker.isFirstLaunch = false

        let task1 = TaskEntity(context: context)
        task1.todo = "Task 1"
        task1.id = "1"
        task1.isCompleted = false

        let task2 = TaskEntity(context: context)
        task2.todo = "Task 2"
        task2.id = "2"
        task2.isCompleted = true

        let coreDataReminders = [task1, task2]
        mockInteractor.mockFetchCoreDataRemindersResult = Just(coreDataReminders)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        // When
        presenter.viewWillAppear()

        // Then
        XCTAssertTrue(mockInteractor.fetchCoreDataRemindersCalled, "Expected fetchCoreDataReminders to be called")
        XCTAssertEqual(mockView.remindersShown.count, 2, "Expected 2 reminders to be shown")
        XCTAssertEqual(mockView.remindersShown.first?.todo, "Task 1", "Expected first reminder's todo to be 'Task 1'")
        XCTAssertEqual(mockView.remindersShown.last?.todo, "Task 2", "Expected second reminder's todo to be 'Task 2'")
    }

    func testToggleReminderCompletion() {
        // Given
        let reminder = TaskEntity(context: context)
        reminder.todo = "Task 1"
        reminder.id = "1"
        reminder.isCompleted = false
        presenter.reminders = [reminder]

        // When
        presenter.toggleReminderCompletion(reminder: reminder)

        // Then
        XCTAssertTrue(mockInteractor.toggleReminderCompletionCalled)
        XCTAssertEqual(mockView.remindersShown.first?.isCompleted, true)
    }

    func testDeleteReminder() {
        // Given
        let reminder = TaskEntity(context: context)
        reminder.todo = "Task 1"
        reminder.id = "1"
        reminder.isCompleted = false
        presenter.reminders = [reminder]

        // When
        presenter.deleteReminder(reminder)

        // Then
        XCTAssertTrue(mockInteractor.deleteReminderCalled)
        XCTAssertEqual(presenter.reminders.count, 0)
        XCTAssertEqual(mockView.remindersShown.count, 0)
    }

    func testCreateNewReminder() {
        // Given
        let viewController = UIViewController()

        // When
        presenter.createNewReminder(from: viewController)

        // Then
        XCTAssertTrue(mockInteractor.createNewReminderCalled)
    }
}
