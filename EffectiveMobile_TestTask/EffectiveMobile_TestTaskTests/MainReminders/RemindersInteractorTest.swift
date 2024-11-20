//
//  RemindersInteractorTest.swift
//  EffectiveMobile_TestTaskTests
//
//  Created by Alexander Grigoryev on 20/11/24.
//

import XCTest
import CoreData
import Combine
@testable import EffectiveMobile_TestTask

final class RemindersInteractorTests: XCTestCase {
    private var interactor: RemindersInteractor!
    private var coreDataService: CoreDataService!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Set up in-memory Core Data stack
        let persistentContainer = NSPersistentContainer(name: "EffectiveMobile_TestTask")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }

        coreDataService = CoreDataService(persistentContainer: persistentContainer)

        interactor = RemindersInteractor()
        interactor.coreDataService = coreDataService

        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = nil
        coreDataService = nil
        interactor = nil
        try super.tearDownWithError()
    }

    func testSaveAndFetchReminders() throws {
        let tasks = [
            Task(id: 1, todo: "Task 1", completed: false, userID: 101),
            Task(id: 2, todo: "Task 2", completed: true, userID: 102)
        ]

        interactor.saveRemindersToCoreData(tasks)

        let expectation = XCTestExpectation(description: "Fetch Core Data reminders")

        interactor.fetchCoreDataReminders()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTFail("Failed to fetch tasks with error: \(error)")
                }
            }, receiveValue: { fetchedTasks in
                XCTAssertEqual(fetchedTasks.count, 2, "Expected 2 tasks in Core Data")
                XCTAssertEqual(fetchedTasks[0].todo, "Task 1", "First task title mismatch")
                XCTAssertEqual(fetchedTasks[1].todo, "Task 2", "Second task title mismatch")
                XCTAssertFalse(fetchedTasks[0].isCompleted, "First task completion mismatch")
                XCTAssertTrue(fetchedTasks[1].isCompleted, "Second task completion mismatch")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}
