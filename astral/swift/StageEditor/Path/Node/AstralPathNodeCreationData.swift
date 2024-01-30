//
//  AstralPathNodeCreationData.swift
//  astral
//
//  Created by Joseph Haygood on 1/28/24.
//

import Foundation

struct AstralPathNodeCreationData: Codable {
    var baseNodeData: AstralPathNodeData
    var timeSinceLastCreation: TimeInterval
    var objectType: AstralGameObjectType
    var objectIndex: Int
    var repeatEnabled: Bool
    var repeatCount: Int
    var repeatInterval: TimeInterval
    var isEndless: Bool
    var initialTimeOffset: TimeInterval
    var initialSpeed: CGFloat

    init(from node: AstralPathNodeCreation) {
        self.baseNodeData = node.toData()
        self.timeSinceLastCreation = node.timeSinceLastCreation
        self.objectType = node.objectType
        self.objectIndex = node.objectIndex
        self.repeatEnabled = node.repeatEnabled
        self.repeatCount = node.repeatCount
        self.repeatInterval = node.repeatInterval
        self.isEndless = node.isEndless
        self.initialTimeOffset = node.initialTimeOffset
        self.initialSpeed = node.initialSpeed
    }

    // Method to create an AstralPathNodeCreation from AstralPathNodeCreationData
    func toNode() -> AstralPathNodeCreation {
        let node = AstralPathNodeCreation(from: baseNodeData)
        node.timeSinceLastCreation = self.timeSinceLastCreation
        node.objectType = self.objectType
        node.objectIndex = self.objectIndex
        node.repeatEnabled = self.repeatEnabled
        node.repeatCount = self.repeatCount
        node.repeatInterval = self.repeatInterval
        node.isEndless = self.isEndless
        node.initialTimeOffset = self.initialTimeOffset
        node.initialSpeed = self.initialSpeed
        return node
    }
}
