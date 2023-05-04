//
//  AstralEnemyOrder.swift
//  astral
//
//  Created by Joseph Haygood on 5/3/23.
//

import Foundation

struct AstralEnemyOrder {
    enum AstralEnemyActionType {
        case move(JoystickDirection)
        case turnRight(TimeInterval)
        case turnLeft(TimeInterval)
        case turnToBase(TimeInterval)
        case rest(TimeInterval)
        case stop
        case shoot
    }
    
    let type: AstralEnemyActionType
    let duration: TimeInterval
    let completion: (() -> Void)? = nil
}
