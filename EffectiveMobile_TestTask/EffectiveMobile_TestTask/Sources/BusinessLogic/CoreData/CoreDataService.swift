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
    func fetchTasks() -> [Task]
    func saveTasks(_ tasks: [Task])
    func deleteTask(byId id: Int)
}

final class CoreDataService: CoreDataServiceProtocol {
    
    private let persistentContainer: NSPersistentContainer
    
    init(containerName: String = "EffectiveMobile_TestTask") {
        persistentContainer = NSPersistentContainer(name: containerName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
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
    
    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            return entities.map { Task(id: Int($0.id), todo: $0.todo ?? "", completed: $0.isCompleted, userID: Int($0.userId)) }
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func saveTasks(_ tasks: [Task]) {
        tasks.forEach { task in
            let entity = TaskEntity(context: context)
            entity.id = Int64(task.id)
            entity.todo = task.todo
            entity.isCompleted = task.completed
            entity.userId = Int64(task.id)
        }
        saveContext()
    }
    
    func deleteTask(byId id: Int) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            saveContext()
        } catch {
            print("Failed to delete task with id \(id): \(error)")
        }
    }
    
    func deleteAllTasks() {
        let request: NSFetchRequest<NSFetchRequestResult> = TaskEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            print("Failed to delete all tasks: \(error)")
        }
    }
    
    func deleteAllTasksWithPredicate(matching predicate: NSPredicate) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = predicate
        
        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            saveContext()
        } catch {
            print("Failed to delete tasks matching predicate \(predicate): \(error)")
        }
    }
}
