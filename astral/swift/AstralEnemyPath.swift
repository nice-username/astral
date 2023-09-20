//
//  AstralEnemyPath.swift
//  astral
//
//  Created by Joseph Haygood on 9/17/23.
//

import Foundation
import UIKit

enum AstralPathSegmentType {
    case line(start: CGPoint, end: CGPoint)
    case bezier(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint)
}

class AstralPathSegment {
    var type: AstralPathSegmentType
    
    init(type: AstralPathSegmentType) {
        self.type = type
    }
}

class AstralEnemyPath {
    var segments: [AstralPathSegment] = []
    
    func addSegment(segment: AstralPathSegment) {
        segments.append(segment)
    }
    
    func toUIBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        for segment in segments {
            switch segment.type {
            case .line(let start, let end):
                path.move(to: start)
                path.addLine(to: end)
            case .bezier(let start, let control1, let control2, let end):
                path.move(to: start)
                path.addCurve(to: end, controlPoint1: control1, controlPoint2: control2)
            }
        }
        return path
    }
}
