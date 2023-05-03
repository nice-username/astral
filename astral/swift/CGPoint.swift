//
//  CGPoint.swift
//  astral
//
//  Created by Joseph Haygood on 5/2/23.
//

import Foundation


//
// CGPoint extensions
//
extension CGPoint {
    func distanceTo(_ point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx*dx + dy*dy)
    }
}
