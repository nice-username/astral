//
//  CGPoint.swift
//  astral
//
//  Created by Joseph Haygood on 5/2/23.
//

import Foundation
import CoreGraphics


//
// Quick CGFloat extension for readability
//
extension CGFloat {
    func squared() -> CGFloat {
        return self * self
    }
}


//
// CGPoint extensions
//
extension CGPoint {
    func distanceTo(_ point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx*dx + dy*dy)
    }
    
    func distanceToLineSegment(start: CGPoint, end: CGPoint) -> CGFloat {
        let lineLength = start.distanceTo(end)
        if lineLength == 0 {
            return self.distanceTo(start) // The line is a point
        }

        // Calculate the projection of the point onto the line (AB) formed by start and end
        let t = ((self.x - start.x) * (end.x - start.x) + (self.y - start.y) * (end.y - start.y)) / (lineLength * lineLength)
        
        // Check if the projection falls on the line segment
        if t < 0 {
            return self.distanceTo(start) // Closest to the start point of the segment
        } else if t > 1 {
            return self.distanceTo(end) // Closest to the end point of the segment
        }

        // Calculate the projection point
        let projection = CGPoint(x: start.x + t * (end.x - start.x), y: start.y + t * (end.y - start.y))
        
        // Return the distance from the point to the projection point
        return self.distanceTo(projection)
    }
    
    
    func isOnSegment(from start: CGPoint, to end: CGPoint, tolerance: CGFloat) -> Bool {
        let crossProduct = (self.y - start.y) * (end.x - start.x) - (self.x - start.x) * (end.y - start.y)
        if abs(crossProduct) > tolerance {
            return false
        }
        
        let dotProduct = (self.x - start.x) * (end.x - start.x) + (self.y - start.y) * (end.y - start.y)
        if dotProduct < 0 {
            return false
        }
        
        let squaredLength = (end.x - start.x).squared() + (end.y - start.y).squared()
        if dotProduct > squaredLength {
            return false
        }
        
        return true
    }
}

