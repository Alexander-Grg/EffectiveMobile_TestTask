//
//  AppLaunchChecker.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 19/11/24.
//

import Foundation

class AppLaunchChecker {
    private let firstLaunchKey = "isFirstLaunch"
    
    var isFirstLaunch: Bool {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: firstLaunchKey)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
        return isFirstLaunch
    }
}
