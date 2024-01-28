//
//  AstralStageData.swift
//  astral
//
//  Created by Joseph Haygood on 9/17/23.
//

import Foundation

struct AstralStageData: Codable {
    var metadata: AstralStageMetadata
    var backgrounds: [AstralParallaxBackgroundLayerData]
}

struct AstralStageMetadata: Codable {
    var name: String
    var author: String
    var description: String
    var dateCreated: Date
    var dateOpened: Date
    var dateModified: Date
}

struct AstralParallaxBackgroundLayerData: Codable {
    var atlasName: String
    var scrollingSpeed: CGFloat
    var scrollingDirection: CGVector
    var shouldLoop: Bool
}




struct AstralPathSegmentTypeData: Codable {
    enum SegmentType: String, Codable {
        case line, bezier
    }

    var type: SegmentType
    var start: CGPoint
    var end: CGPoint
    var control1: CGPoint?
    var control2: CGPoint?

    init(from segmentType: AstralPathSegmentType) {
        switch segmentType {
        case .line(let start, let end):
            self.type = .line
            self.start = start
            self.end = end
        case .bezier(let start, let control1, let control2, let end):
            self.type = .bezier
            self.start = start
            self.control1 = control1
            self.control2 = control2
            self.end = end
        }
    }

    // Add a method to convert back to AstralPathSegmentType if needed
}

