//
//  CoreDataService.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 19/11/24.
//

import CoreData

struct CoreDataServiceKey: InjectionKey {
    static var currentValue: CoreDataServiceProtocol = CoreDataService()
}

protocol CoreDataServiceProtocol {
    var context: NSManagedObjectContext { get }
    func saveContext()
    func fetchTasks() -> [TaskEntity]
    func saveTasks(_ tasks: [Task])
    func deleteTask(byId id: String)
    func saveOrUpdateEntity(_ entity: TaskEntity)
    func saveNewReminder(_ reminder: TaskEntity)
}

final class CoreDataService: CoreDataServiceProtocol {
    var persistentContainer: NSPersistentContainer

    init(containerName: String = "EffectiveMobile_TestTask") {
        persistentContainer = NSPersistentContainer(name: containerName)

        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            // Use in-memory store for testing
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            persistentContainer.persistentStoreDescriptions = [description]
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }

            self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func fetchTasks() -> [TaskEntity] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "todo", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        do {
            let entities = try context.fetch(request)
            return entities
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }

    func saveTasks(_ tasks: [Task]) {
        context.performAndWait {  //  synchronous execution for testing
            tasks.forEach { task in
                let entity = TaskEntity(context: self.context)
                entity.id = String(task.id)
                entity.todo = task.todo
                entity.isCompleted = task.completed
                entity.userId = String(task.userID)
            }
            do {
                try self.context.save()
            } catch {
                print("Failed to save tasks: \(error)")
            }
        }
    }

    func deleteTask(byId id: String) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        context.performAndWait {  //  synchronous execution for testing
            do {
                let results = try self.context.fetch(request)
                results.forEach { self.context.delete($0) }
                try self.context.save()
            } catch {
                print("Failed to delete task with id \(id): \(error)")
            }
        }
    }

    func saveOrUpdateEntity(_ entity: TaskEntity) {
        context.perform {
            do {
                let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %d", entity.id)

                if let existingEntity = try self.context.fetch(fetchRequest).first {
                    existingEntity.todo = entity.todo
                    existingEntity.body = entity.body
                    existingEntity.isCompleted = entity.isCompleted
                    existingEntity.userId = entity.userId
                } else {
                    self.context.insert(entity)
                }
                self.saveContext()
            } catch {
                print("Failed to save or update entity: \(error)")
            }
        }
    }

    func saveNewReminder(_ reminder: TaskEntity) {
        saveOrUpdateEntity(reminder)
    }
}
