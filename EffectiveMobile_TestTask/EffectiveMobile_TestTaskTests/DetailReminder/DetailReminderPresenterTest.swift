//
//  DetailReminderPresenterTest.swift
//  EffectiveMobile_TestTaskTests
//
//  Created by Alexander Grigoryev on 20/11/24.
//

import XCTest
import Combine
import CoreData
@testable import EffectiveMobile_TestTask

final class DetailReminderPresenterTests: XCTestCase {
    var presenter: DetailReminderPresenter!
    var mockView: MockDetailReminderView!
    var mockRouter: MockDetailReminderRouter!
    var mockInteractor: MockDetailReminderInteractor!
    var reminder: TaskEntity!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        // Create an in-memory NSPersistentContainer
        let container = NSPersistentContainer(name: "EffectiveMobile_TestTask")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        context = container.viewContext

        // Initialize the reminder entity
        reminder = TaskEntity(context: context)
        reminder.id = "1"
        reminder.todo = "Test Reminder"
        reminder.body = "Test Body"

        // Initialize mocks and presenter
        mockView = MockDetailReminderView()
        mockRouter = MockDetailReminderRouter()
        mockInteractor = MockDetailReminderInteractor()
        presenter = DetailReminderPresenter()

        presenter.view = mockView
        presenter.router = mockRouter
        presenter.interactor = mockInteractor
        presenter.reminder = reminder
    }

    override func tearDown() {
        presenter = nil
        mockView = nil
        mockRouter = nil
        mockInteractor = nil
        reminder = nil
        context = nil
        super.tearDown()
    }

    func testViewDidLoad_ShowsReminderDetail() {
        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(mockView.showReminderDetailCalled, "Expected view to show reminder detail")
        XCTAssertEqual(mockView.reminderShown?.todo, "Test Reminder", "Expected reminder title to be 'Test Reminder'")
    }

    func testUpdateReminderTitle_CallsSaveOrUpdate() {
        // When
        presenter.updateReminderTitle("Updated Title")

        // Then
        XCTAssertTrue(mockInteractor.saveOrUpdateReminderCalled, "Expected interactor to save or update reminder")
        XCTAssertEqual(mockInteractor.reminderPassed?.todo, "Updated Title", "Expected updated reminder title to be 'Updated Title'")
    }

    func testUpdateReminderBody_CallsSaveOrUpdate() {
        // When
        presenter.updateReminderBody("Updated Body")

        // Then
        XCTAssertTrue(mockInteractor.saveOrUpdateReminderCalled, "Expected interactor to save or update reminder")
        XCTAssertEqual(mockInteractor.reminderPassed?.body, "Updated Body", "Expected updated reminder body to be 'Updated Body'")
    }

    func testBackButtonPressed_CallsRouter() {
        // Given
        let viewController = UIViewController()

        // When
        presenter.backButtonPressed(from: viewController)

        // Then
        XCTAssertTrue(mockRouter.goBackToReminderListViewCalled, "Expected router to navigate back to reminder list view")
    }
}
