//
//  Direction.swift
//  astral
//
//  Created by Joseph Haygood on 4/30/23.
//
import Foundation

/// Represents directional movement in the game
enum AstralDirection: Int, Codable, CaseIterable {
    case up
    case upRight
    case right
    case downRight
    case down
    case downLeft
    case left
    case upLeft
    case none
    
    /// Converts direction to an angle in radians
    var angle: CGFloat {
        switch self {
        case .up:         return CGFloat.pi / 2     // 90 degrees
        case .upRight:    return CGFloat.pi / 4     // 45 degrees
        case .right:      return 0                  // 0 degrees
        case .downRight:  return -CGFloat.pi / 4    // -45 degrees
        case .down:       return -CGFloat.pi / 2    // -90 degrees
        case .downLeft:   return -3 * CGFloat.pi / 4 // -135 degrees
        case .left:       return CGFloat.pi         // 180 degrees
        case .upLeft:     return 3 * CGFloat.pi / 4  // 135 degrees
        case .none:       return 0                  // No rotation
        }
    }
    
    /// Determines if this direction represents movement (not .none)
    var isMoving: Bool {
        return self != .none
    }
    
    /// Returns the opposite direction
    var opposite: AstralDirection {
        switch self {
        case .up:         return .down
        case .upRight:    return .downLeft
        case .right:      return .left
        case .downRight:  return .upLeft
        case .down:       return .up
        case .downLeft:   return .upRight
        case .left:       return .right
        case .upLeft:     return .downRight
        case .none:       return .none
        }
    }
    
    /// Returns the direction from one point to another
    static func direction(from source: CGPoint, to destination: CGPoint) -> AstralDirection {
        if source == destination {
            return .none
        }
        
        let deltaX = destination.x - source.x
        let deltaY = destination.y - source.y
        let angle = atan2(deltaY, deltaX)
        
        // Convert angle to direction
        if angle >= -CGFloat.pi / 8 && angle < CGFloat.pi / 8 {
            return .right
        } else if angle >= CGFloat.pi / 8 && angle < 3 * CGFloat.pi / 8 {
            return .upRight
        } else if angle >= 3 * CGFloat.pi / 8 && angle < 5 * CGFloat.pi / 8 {
            return .up
        } else if angle >= 5 * CGFloat.pi / 8 && angle < 7 * CGFloat.pi / 8 {
            return .upLeft
        } else if angle >= 7 * CGFloat.pi / 8 || angle < -7 * CGFloat.pi / 8 {
            return .left
        } else if angle >= -7 * CGFloat.pi / 8 && angle < -5 * CGFloat.pi / 8 {
            return .downLeft
        } else if angle >= -5 * CGFloat.pi / 8 && angle < -3 * CGFloat.pi / 8 {
            return .down
        } else if angle >= -3 * CGFloat.pi / 8 && angle < -CGFloat.pi / 8 {
            return .downRight
        }
        
        return .none
    }
}
