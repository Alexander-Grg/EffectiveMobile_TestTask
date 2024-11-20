//
//  RemindersRouterTest.swift
//  EffectiveMobile_TestTaskTests
//
//  Created by Alexander Grigoryev on 20/11/24.
//

import XCTest
@testable import EffectiveMobile_TestTask
import CoreData

class RemindersRouterTests: XCTestCase {
    var router: RemindersRouter!
    var mockNavigationController: MockNavigationController!
    var taskEntity: TaskEntity!

    override func setUp() {
        super.setUp()
        router = RemindersRouter()
        mockNavigationController = MockNavigationController()

        // Create a TaskEntity for testing
        let persistentContainer = NSPersistentContainer(name: "EffectiveMobile_TestTask")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to set up in-memory Core Data stack: \(error)")
            }
        }

        let context = persistentContainer.viewContext
        taskEntity = TaskEntity(context: context)
        taskEntity.id = "1"
        taskEntity.todo = "Test Reminder"
        taskEntity.isCompleted = false
    }

    override func tearDown() {
        router = nil
        mockNavigationController = nil
        taskEntity = nil
        super.tearDown()
    }

    func testPushToReminderDetail() {
        // Given
        let mockViewController = UIViewController()
        mockNavigationController.viewControllers = [mockViewController]

        // When
        router.pushToReminderDetail(with: taskEntity, from: mockViewController)

        // Then
        XCTAssertNotNil(mockNavigationController.pushedViewController, "Expected a view controller to be pushed")
        XCTAssertTrue(mockNavigationController.pushedViewController is DetailReminderViewController, "Expected a DetailReminderViewController to be pushed")
    }

    func testCreateRemindersListModule() {
        // When
        let remindersListModule = RemindersRouter.createRemindersListModule()

        // Then
        XCTAssertTrue(remindersListModule is UINavigationController, "Expected a UINavigationController to be returned")
        guard let navigationController = remindersListModule as? UINavigationController else { return }
        XCTAssertTrue(navigationController.viewControllers.first is RemindersViewController, "Expected a RemindersViewController as the root view controller")
    }
}
