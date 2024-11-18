//
//  EndpointProtocol.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import Foundation

protocol EndpointProtocol {
    var absoluteURL: String { get }
    var parameters: [String : String] { get }
}
