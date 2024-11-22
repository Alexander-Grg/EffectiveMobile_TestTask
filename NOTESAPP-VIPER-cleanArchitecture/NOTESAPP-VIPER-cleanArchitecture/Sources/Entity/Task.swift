//
//  Task.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//

import Foundation

struct TaskResponse: Codable {
    let todos: [Task]
    let total, skip, limit: Int
}

struct Task: Codable {
    var id: Int
    var todo: String
    var completed: Bool
    var userID: Int
    
    
    enum CodingKeys: String, CodingKey {
        case id, todo, completed
        case userID = "userId"
    }
}
