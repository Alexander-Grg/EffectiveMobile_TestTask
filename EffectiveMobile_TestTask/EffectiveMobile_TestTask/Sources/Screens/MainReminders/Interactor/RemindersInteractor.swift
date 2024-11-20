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
        coreDataService.saveTasks(reminders)
    }

    func fetchCoreDataReminders() -> AnyPublisher<[TaskEntity], Error> {
        Future<[TaskEntity], Error> { promise in
            let tasks = self.coreDataService.fetchTasks()
            promise(.success(tasks))
        }.eraseToAnyPublisher()
    }

    func toggleReminderCompletion(_ reminder: TaskEntity) {
        let updatedReminder = reminder
        updatedReminder.isCompleted.toggle()
        coreDataService.saveOrUpdateEntity(updatedReminder)
    }

    func deleteReminder(_ reminder: TaskEntity) {
        coreDataService.deleteTask(byId: String(reminder.id))
    }

    func updateReminderInCoreData(_ reminder: TaskEntity) {
        coreDataService.saveOrUpdateEntity(reminder)
    }

    func createNewReminder(from view: UIViewController, router: RemindersRouterProtocol) {
        let context = coreDataService.context
        let newReminder = TaskEntity(context: context)
        newReminder.id = UUID().uuidString
        newReminder.todo = "New Reminder"
        newReminder.isCompleted = false
        newReminder.body = ""

        coreDataService.saveOrUpdateEntity(newReminder)
        router.pushToReminderDetail(with: newReminder, from: view)
    }
}
