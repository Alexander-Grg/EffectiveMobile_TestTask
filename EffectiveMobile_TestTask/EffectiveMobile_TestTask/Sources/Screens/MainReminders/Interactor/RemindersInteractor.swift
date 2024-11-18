//
//  RemindersInteractor.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import UIKit
import Combine

final class RemindersInteractor: RemindersInputInteractorProtocol {
    weak var presenter: RemindersOutputInteractorProtocol?
    private let remindersService: TaskSearchServiceProtocol

    init(remindersService: TaskSearchServiceProtocol) {
        self.remindersService = remindersService
    }

    func fetchReminders() -> AnyPublisher<[Task], Never> {
        remindersService.requestToDoList()
            .decode(type: TaskResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard !response.todos.isEmpty else {
                    throw URLError(.badServerResponse) // Throw an error if todos is empty
                }
                return response.todos
            }
            .catch { error -> AnyPublisher<[Task], Never> in
                print("Error fetching reminders: \(error.localizedDescription)")
                return Just([]).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main) // Deliver data on main thread
            .eraseToAnyPublisher()
    }


    func deleteReminder(_ reminder: Task) {
    }

    func saveReminder(_ reminder: Task) {
    }

    func updateReminder(_ reminder: Task) {
    }
}
