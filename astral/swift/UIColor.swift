//
//  UIColor.swift
//  astral
//
//  Created by Joseph Haygood on 1/26/24.
//

import Foundation
import UIKit

struct UIColorData: Codable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
}

extension UIColor {
    func toData() -> UIColorData {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColorData(red: red, green: green, blue: blue, alpha: alpha)
    }

    convenience init(from data: UIColorData) {
        self.init(red: data.red, green: data.green, blue: data.blue, alpha: data.alpha)
    }
}
