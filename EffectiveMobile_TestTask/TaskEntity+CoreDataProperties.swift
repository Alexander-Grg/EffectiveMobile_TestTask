//
//  TaskEntity+CoreDataProperties.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 20/11/24.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var id: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var todo: String?
    @NSManaged public var userId: String
    @NSManaged public var body: String?
    @NSManaged public var date: Date?

}

extension TaskEntity : Identifiable {

}
