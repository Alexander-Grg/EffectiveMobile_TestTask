//
//  TaskSearchService.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import Foundation
import Combine

protocol TaskSearchServiceProtocol: AnyObject {
    func requestToDoList() -> AnyPublisher<Data, Error>
}

final class TaskSearchService: TaskSearchServiceProtocol {

    private let apiProvider = APIProvider<TaskEndpoint>()

    func requestToDoList() -> AnyPublisher<Data, Error> {
        return apiProvider.getData(from: .taskSearch, localFile: "Tasks")
            .eraseToAnyPublisher()
    }
}
