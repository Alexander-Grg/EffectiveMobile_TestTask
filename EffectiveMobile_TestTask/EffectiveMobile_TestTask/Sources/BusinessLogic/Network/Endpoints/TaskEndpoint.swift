//
//  TaskEndpoint.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import Foundation

enum TaskEndpoint: EndpointProtocol {
    case taskSearch
    var absoluteURL: String {
        return ""
    }
    
    var parameters: [String: String] {
        switch self {
        case .taskSearch:
            return [
                "limit": "30",
                "skip": "0"
            ]
        }
    }
}
