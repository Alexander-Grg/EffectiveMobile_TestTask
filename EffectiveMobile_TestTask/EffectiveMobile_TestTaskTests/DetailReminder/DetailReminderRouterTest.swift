//
//  DetailReminderRouterTest.swift
//  EffectiveMobile_TestTaskTests
//
//  Created by Alexander Grigoryev on 20/11/24.
//

import XCTest
import CoreData
@testable import EffectiveMobile_TestTask

final class DetailReminderRouterTests: XCTestCase {
    var router: DetailReminderRouter!
    var navigationController: UINavigationController!
    var viewController: UIViewController!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        // Set up in-memory Core Data stack
        let persistentContainer = NSPersistentContainer(name: "EffectiveMobile_TestTask")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to set up in-memory Core Data stack: \(error)")
            }
        }

        context = persistentContainer.viewContext

        router = DetailReminderRouter()
        viewController = UIViewController()
        navigationController = UINavigationController(rootViewController: viewController)
    }

    override func tearDown() {
        router = nil
        navigationController = nil
        viewController = nil
        context = nil
        super.tearDown()
    }

    func testGoBackToReminderListView() {
        // Arrange: Push a new view controller onto the stack
        let detailViewController = UIViewController()
        navigationController.pushViewController(detailViewController, animated: false)

        // Act: Call the router to pop the view controller
        router.goBackToReminderListView(from: detailViewController)

        // Assert: Check if the view controller was popped
        XCTAssertEqual(navigationController.viewControllers.count, 1, "Expected navigation controller to pop the view controller")
        XCTAssertTrue(navigationController.topViewController === viewController, "Expected root view controller to be the top view controller")
    }

    func testCreateReminderDetailModule() {
        // Arrange
        let reminder = TaskEntity(context: context)
        reminder.id = "1"
        reminder.todo = "Test Reminder"
        let detailViewController = DetailReminderViewController()

        // Act
        DetailReminderRouter.createReminderDetailModule(with: detailViewController, and: reminder)

        // Assert
        XCTAssertNotNil(detailViewController.presenter, "Expected DetailReminderViewController to have a presenter")
        XCTAssertNotNil(detailViewController.presenter?.view, "Expected presenter to have a view")
        XCTAssertNotNil(detailViewController.presenter?.interactor, "Expected presenter to have an interactor")
        XCTAssertNotNil(detailViewController.presenter?.router, "Expected presenter to have a router")
        XCTAssertEqual(detailViewController.presenter?.reminder?.todo, "Test Reminder", "Expected reminder to be correctly passed to the presenter")
    }
}
