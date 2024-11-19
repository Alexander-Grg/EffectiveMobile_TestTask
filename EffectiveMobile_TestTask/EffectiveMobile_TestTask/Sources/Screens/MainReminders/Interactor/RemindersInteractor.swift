//
//  RemindersInteractor.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit
import Combine
import CoreData

final class RemindersInteractor: RemindersInputInteractorProtocol {
    weak var presenter: RemindersOutputInteractorProtocol?
    @Injected(\.tasksFetchService) var fetchRemindersService
    @Injected(\.coreDataService) var coreDataService
    private var cancellables = Set<AnyCancellable>()

    func fetchRemindersFromJSON() -> AnyPublisher<[Task], Never> {
        fetchRemindersService.requestToDoList()
            .decode(type: TaskResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard !response.todos.isEmpty else {
                    throw URLError(.badServerResponse)
                }
                return response.todos
            }
            .catch { error -> AnyPublisher<[Task], Never> in
                print("Error fetching reminders: \(error.localizedDescription)")
                return Just([]).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func saveRemindersToCoreData(_ reminders: [Task]) {
        let context = coreDataService.context

        context.perform {
            do {
                for reminder in reminders {
                    let entity = TaskEntity(context: context)
                    entity.id = Int64(reminder.id)
                    entity.todo = reminder.todo
                    entity.isCompleted = reminder.completed
                    entity.userId = Int64(reminder.userID)
                }
                try context.save()
            } catch {
                print("Failed to save reminders to CoreData: \(error)")
            }
        }
    }

    func fetchCoreDataReminders() -> AnyPublisher<[Task], Error> {
        let context = coreDataService.context
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        return Future<[Task], Error> { promise in
            context.perform {
                do {
                    let taskEntities = try context.fetch(fetchRequest)
                    let tasks = taskEntities.map { Task(from: $0) }
                    promise(.success(tasks))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func toggleReminderCompletion(_ reminder: Task) {
        let context = coreDataService.context
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", reminder.id)

        context.perform {
            do {
                if let entity = try context.fetch(fetchRequest).first {
                    entity.isCompleted.toggle()
                    try context.save()
                }
            } catch {
                print("Failed to toggle completion for reminder: \(error)")
            }
        }
    }

    func deleteReminder(_ reminder: Task) {
        let context = coreDataService.context
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", reminder.id)

        context.perform {
            do {
                if let entity = try context.fetch(fetchRequest).first {
                    context.delete(entity)
                    try context.save()
                }
            } catch {
                print("Failed to delete reminder: \(error)")
            }
        }
    }

    func updateReminderInCoreData(_ reminder: Task) {
        let context = coreDataService.context
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", reminder.id)

        context.perform {
            do {
                if let entity = try context.fetch(fetchRequest).first {
                    entity.todo = reminder.todo
                    entity.isCompleted = reminder.completed
                    try context.save()
                    print("Reminder successfully updated in CoreData.")
                } else {
                    print("No reminder found with ID: \(reminder.id)")
                }
            } catch {
                print("Failed to update reminder in CoreData: \(error.localizedDescription)")
            }
        }
    }
}
