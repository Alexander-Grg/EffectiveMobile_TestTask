//
//  DetailReminderInteractor.swift
//  EffectiveMobile_TestTaskTests
//
//  Created by Alexander Grigoryev on 20/11/24.
//

import XCTest
import CoreData
@testable import EffectiveMobile_TestTask

class DetailReminderInteractorTests: XCTestCase {
    var interactor: DetailReminderInteractor!
    var mockCoreDataService: MockCoreDataService!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        // Create an in-memory NSPersistentContainer for testing
        let container = NSPersistentContainer(name: "EffectiveMobile_TestTask")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null") // Use in-memory store
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }

        // Assign the context from the container
        context = container.viewContext

        // Initialize MockCoreDataService with the context
        mockCoreDataService = MockCoreDataService(context: context)

        // Set up the interactor and inject the mock CoreDataService
        interactor = DetailReminderInteractor()
        interactor.coreDataService = mockCoreDataService
    }

    override func tearDown() {
        interactor = nil
        mockCoreDataService = nil
        context = nil
        super.tearDown()
    }

    func testSaveOrUpdateReminder() {
        // Given
        let taskEntity = TaskEntity(context: context)
        taskEntity.id = "1"
        taskEntity.todo = "Test Reminder"
        taskEntity.isCompleted = false

        // When
        interactor.saveOrUpdateReminder(taskEntity)

        // Then
        XCTAssertTrue(mockCoreDataService.saveOrUpdateEntityCalled, "Expected saveOrUpdateEntity to be called")
        XCTAssertEqual(mockCoreDataService.savedOrUpdatedEntity, taskEntity, "Expected the correct entity to be passed to saveOrUpdateEntity")
    }
}
