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
    
    func saveOrUpdateReminder(_ reminder: TaskEntity) {
        coreDataService.saveOrUpdateEntity(reminder)
    }
}
