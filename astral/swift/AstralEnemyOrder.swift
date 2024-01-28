//
//  AstralEnemyOrder.swift
//  astral
//
//  Created by Joseph Haygood on 5/3/23.
//

import Foundation


struct AstralEnemyOrder: Codable {
    enum AstralEnemyActionType: Codable {
        case move(AstralDirection)
        case turnRight(duration: TimeInterval, angle: CGFloat)
        case turnLeft(duration: TimeInterval, angle: CGFloat)
        case turnToBase(TimeInterval)
        case rest(TimeInterval)
        case stop
        case fire
        case fireStop
        case speedUp(Double)
        case speedDown(Double)
    }
    
    let type: AstralEnemyActionType
    let duration: TimeInterval
}
