//
//  CoreDataServiceTest.swift
//  EffectiveMobile_TestTaskTests
//
//  Created by Alexander Grigoryev on 20/11/24.
//

import XCTest
import CoreData
import Combine
@testable import EffectiveMobile_TestTask

final class CoreDataServiceTests: XCTestCase {
    private var coreDataService: CoreDataService!
    private var persistentContainer: NSPersistentContainer!

    override func setUp() {
        super.setUp()

        persistentContainer = NSPersistentContainer(name: "EffectiveMobile_TestTask")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load in-memory persistent store")
        }

        coreDataService = CoreDataService(containerName: "EffectiveMobile_TestTask")
        coreDataService.persistentContainer = persistentContainer
    }

    override func tearDown() {
        coreDataService = nil
        persistentContainer = nil
        super.tearDown()
    }

    func testFetchTasks_Empty() {
        let tasks = coreDataService.fetchTasks()

        XCTAssertEqual(tasks.count, 0, "Expected no tasks in the persistent store")
    }

    func testSaveTasksAndFetch() {
        let task = Task(id: 123, todo: "Test Task", completed: false, userID: 1)

        coreDataService.saveTasks([task])

        let tasks = coreDataService.fetchTasks()

        XCTAssertEqual(tasks.count, 1, "Expected one task in the persistent store")
        XCTAssertEqual(tasks.first?.todo, "Test Task", "Task title mismatch")
    }

    func testDeleteTaskById() {
        // Arrange
        let task = Task(id: 123, todo: "Test Task", completed: false, userID: 1)
        coreDataService.saveTasks([task])

        // Act
        coreDataService.deleteTask(byId: String(task.id))  // Convert Int to String

        // Assert
        let tasks = coreDataService.fetchTasks()
        XCTAssertEqual(tasks.count, 0, "Expected no tasks in the persistent store after deletion")
    }

    func testSaveOrUpdateEntity_NewEntity() {
        let newTask = TaskEntity(context: persistentContainer.viewContext)
        newTask.id = "123"
        newTask.todo = "New Task"
        newTask.isCompleted = false
        newTask.userId = "1"

        coreDataService.saveOrUpdateEntity(newTask)

        let tasks = coreDataService.fetchTasks()

        XCTAssertEqual(tasks.count, 1, "Expected one task in the persistent store")
        XCTAssertEqual(tasks.first?.todo, "New Task", "Task title mismatch")
    }

    func testSaveOrUpdateEntity_UpdateExisting() {
        let task = TaskEntity(context: persistentContainer.viewContext)
        task.id = "123"
        task.todo = "Old Task"
        task.isCompleted = false
        task.userId = "1"

        coreDataService.saveOrUpdateEntity(task)

        task.todo = "Updated Task"
        coreDataService.saveOrUpdateEntity(task)

        let tasks = coreDataService.fetchTasks()

        XCTAssertEqual(tasks.count, 1, "Expected one task in the persistent store")
        XCTAssertEqual(tasks.first?.todo, "Updated Task", "Task title mismatch")
    }
}
