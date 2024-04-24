//
//  CGVector.swift
//  astral
//
//  Created by Joseph Haygood on 4/23/24.
//

import Foundation

extension CGVector {
    /// Returns a normalized version of the vector (unit vector).
    func normalized() -> CGVector {
        let length = sqrt(dx * dx + dy * dy)
        guard length != 0 else { return self }
        return CGVector(dx: dx / length, dy: dy / length)
    }
    
    /// Rotates the vector by a given angle (in radians)
    func rotated(by radians: CGFloat) -> CGVector {
        let newDx = dx * cos(radians) - dy * sin(radians)
        let newDy = dx * sin(radians) + dy * cos(radians)
        return CGVector(dx: newDx, dy: newDy)
    }
    
    /// Returns the length (magnitude) of the vector.
    var length: CGFloat {
        return sqrt(dx*dx + dy*dy)
    }    
    
    /// Adds two vectors.
    static func +(lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    /// Subtracts one vector from another.
    static func -(lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }

    /// Multiplies a vector by a scalar.
    static func *(vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }

    /// Divides a vector by a scalar.
    static func /(vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
    }
}
