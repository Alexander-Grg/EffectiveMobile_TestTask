//
//  APIProvider.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import Foundation
import Combine

class APIProvider<Endpoint: EndpointProtocol> {
    func getData(from endpoint: Endpoint, localFile: String) -> AnyPublisher<Data, Error> {
        loadLocalJSON(filename: localFile)
    }
    
    private func loadLocalJSON(filename: String) -> AnyPublisher<Data, Error> {
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            print("Found URL for \(filename).json: \(url)")
            do {
                let data = try Data(contentsOf: url)
                print("Successfully loaded data from \(filename).json")
                return Just(data)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } catch {
                print("Error reading data from \(filename).json: \(error)")
                return Fail(error: APIProviderErrors.dataNil)
                    .eraseToAnyPublisher()
            }
        } else {
            print("Invalid URL for file: \(filename).json")
            return Fail(error: APIProviderErrors.invalidURL)
                .eraseToAnyPublisher()
        }
    }
}
