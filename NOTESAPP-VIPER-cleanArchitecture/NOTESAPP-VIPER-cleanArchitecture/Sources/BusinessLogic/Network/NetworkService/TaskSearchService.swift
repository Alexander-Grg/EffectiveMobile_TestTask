//
//  TaskSearchService.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import Foundation
import Combine

struct TasksFetchServiceKey: InjectionKey {
    static var currentValue: TasksFetchServiceProtocol = TasksFetchService()
}

protocol TasksFetchServiceProtocol: AnyObject {
    func requestToDoList() -> AnyPublisher<Data, Error>
}

final class TasksFetchService: TasksFetchServiceProtocol {
    
    var apiProvider = APIProvider<TaskEndpoint>()

    func requestToDoList() -> AnyPublisher<Data, Error> {
        return apiProvider.getData(from: .taskSearch, localFile: "todos")
            .eraseToAnyPublisher()
    }
}
