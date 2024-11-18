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
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            return Fail(error: APIProviderErrors.invalidURL)
                .eraseToAnyPublisher()
        }

        do {
            let data = try Data(contentsOf: url)
            return Just(data)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: APIProviderErrors.dataNil)
                .eraseToAnyPublisher()
        }
    }
}
