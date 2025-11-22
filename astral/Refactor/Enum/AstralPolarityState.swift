//
//  AstralPolarityState.swift
//  astral
//
//  Created by Joseph Haygood on 2/17/25.
//

import Foundation

enum AstralPolarityState: Codable {
    case white
    case black
    
    var atlasName: String {
        switch self {
        case .white: return "polarity_switch_white"
        case .black: return "polarity_switch_black"
        }
    }
    
    var frameRange: ClosedRange<Int> {
        switch self {
        case .white: return 0...45    // Comp 1_00000 to Comp 1_00045
        case .black: return 45...90   // Comp 2_00045 to Comp 2_00090
        }
    }
    
    var framePrefix: String {
        switch self {
        case .white: return "Comp1_"
        case .black: return "Comp2_"
        }
    }
    
    mutating func toggle() {
        self = self == .white ? .black : .white
    }
}
