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
