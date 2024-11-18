//
//  UIViewController + Extension.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//
import UIKit

protocol StoryBoarded {
    static func instantiate() -> Self
}

extension StoryBoarded where Self: UIViewController {
    static func instantiate() -> Self {
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        return storyboard.instantiateViewController(withIdentifier: id) as! Self
    }
}
