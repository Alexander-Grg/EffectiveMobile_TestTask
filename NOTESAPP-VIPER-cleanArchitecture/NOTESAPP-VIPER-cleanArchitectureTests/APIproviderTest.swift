//
//  APIproviderTest.swift
//  EffectiveMobile_TestTaskTests
//
//  Created by Alexander Grigoryev on 20/11/24.
//

import XCTest
import Combine
@testable import EffectiveMobile_TestTask

final class MockAPIProvider: APIProvider<TaskEndpoint> {
    var shouldReturnError = false
    var mockData: Data?

    override func getData(from endpoint: TaskEndpoint, localFile: String) -> AnyPublisher<Data, Error> {
        if shouldReturnError {
            return Fail(error: APIProviderErrors.invalidURL)
                .eraseToAnyPublisher()
        } else {
            let data = mockData ?? Data()
            return Just(data)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}

final class TasksFetchServiceTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    private var mockAPIProvider: MockAPIProvider!
    private var tasksFetchService: TasksFetchService!

    override func setUp() {
        super.setUp()
        cancellables = []
        mockAPIProvider = MockAPIProvider()
        tasksFetchService = TasksFetchService()
        tasksFetchService.apiProvider = mockAPIProvider
    }

    override func tearDown() {
        cancellables = nil
        mockAPIProvider = nil
        tasksFetchService = nil
        super.tearDown()
    }

    func testRequestToDoList_Success() {
        // Arrange
        let expectedData = "{\"tasks\": [{\"id\": 1, \"title\": \"Sample Task\"}]}".data(using: .utf8)!
        mockAPIProvider.mockData = expectedData
        mockAPIProvider.shouldReturnError = false

        // Act & Assert
        let expectation = self.expectation(description: "Fetching To-Do List")
        tasksFetchService.requestToDoList()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, but got error: \(error)")
                }
            }, receiveValue: { data in
                XCTAssertEqual(data, expectedData, "Received data does not match expected data")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testRequestToDoList_Failure() {
        // Arrange
        mockAPIProvider.shouldReturnError = true

        // Act & Assert
        let expectation = self.expectation(description: "Fetching To-Do List with Failure")
        tasksFetchService.requestToDoList()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertTrue(error is APIProviderErrors, "Expected APIProviderErrors, but got \(error)")
                    expectation.fulfill()
                }
            }, receiveValue: { data in
                XCTFail("Expected failure, but got data: \(data)")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }
}
