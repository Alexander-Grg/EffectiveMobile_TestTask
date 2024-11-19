//
//  DetailReminderInteractor.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 19/11/24.
//

import UIKit
import CoreData

final class DetailReminderInteractor: DetailReminderInputInteractorProtocol {
    weak var presenter: DetailReminderOutputInteractorProtocol?
    @Injected(\.coreDataService) var coreDataService
    
    func updateReminder(_ reminder: Task) {
        let context = coreDataService.context
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", reminder.id)
        
        context.perform {
            do {
                if let entity = try context.fetch(fetchRequest).first {
                    entity.todo = reminder.todo
                    //                    entity.body = reminder.body
                    try context.save()
                    print("Reminder successfully updated in CoreData.")
                } else {
                    print("No matching reminder found for ID: \(reminder.id)")
                }
            } catch {
                print("Failed to update reminder: \(error.localizedDescription)")
            }
        }
    }
}
