//
//  UIControl.swift
//  astral
//
//  Created by Joseph Haygood on 12/11/23.
//

import Foundation
import UIKit


//
// @aepryus wrote a shortcut for us here:
// https://stackoverflow.com/questions/25919472/adding-a-closure-as-target-to-a-uibutton
//
extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping()->()) {
        addAction(UIAction { (action: UIAction) in closure() }, for: controlEvents)
    }
}
