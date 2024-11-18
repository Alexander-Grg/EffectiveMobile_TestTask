//
//  Task.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//
import Foundation

struct Task: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

struct TaskResponse: Decodable {
    let todos: [Task]
    let total: Int
    let skip: Int
    let limit: Int
}
