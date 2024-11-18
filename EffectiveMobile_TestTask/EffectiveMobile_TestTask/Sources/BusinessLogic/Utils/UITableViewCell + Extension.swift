//
//  UITableViewCell + Extension.swift
//  EffectiveMobile_TestTask
//
//  Created by Alexander Grigoryev on 18/11/24.
//
import UIKit

protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last ?? String(describing: Mirror(reflecting: self).subjectType)
    }
}

extension UITableViewCell: ReusableView {}
