//
//  AstralStageEditorPathData.swift
//  astral
//
//  Created by Joseph Haygood on 1/28/24.
//

import Foundation



enum NodeDataWrapper: Codable {
    case action(AstralPathNodeActionData)
    case creation(AstralPathNodeCreationData)
    case base(AstralPathNodeData)

    enum CodingKeys: String, CodingKey {
        case type
        case data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .action(let actionData):
            try container.encode("action", forKey: .type)
            try container.encode(actionData, forKey: .data)
        case .creation(let creationData):
            try container.encode("creation", forKey: .type)
            try container.encode(creationData, forKey: .data)
        case .base(let baseData):
            try container.encode("base", forKey: .type)
            try container.encode(baseData, forKey: .data)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "action":
            let actionData = try container.decode(AstralPathNodeActionData.self, forKey: .data)
            self = .action(actionData)
        case "creation":
            let creationData = try container.decode(AstralPathNodeCreationData.self, forKey: .data)
            self = .creation(creationData)
        case "base":
            let baseData = try container.decode(AstralPathNodeData.self, forKey: .data)
            self = .base(baseData)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid node type")
        }
    }
    // Implement Codable manually to handle different cases
    // Add encode(to:) and init(from:) to handle different node data types
}



struct AstralPathSegmentData: Codable {
    var type: AstralPathSegmentType
    var nodesData: [NodeDataWrapper]

    init(from segment: AstralPathSegment) {
        self.type = segment.type
        self.nodesData = segment.nodes.map { node in
            if let actionNode = node as? AstralPathNodeAction {
                return .action(AstralPathNodeActionData(from: actionNode))
            } else if let creationNode = node as? AstralPathNodeCreation {
                return .creation(AstralPathNodeCreationData(from: creationNode))
            } else {
                return .base(AstralPathNodeData(from: node))
            }
        }
    }

    func toSegment() -> AstralPathSegment {
        let segment = AstralPathSegment(type: self.type)
        
        // Load nodes from nodesData
        segment.nodes = self.nodesData.map { nodeDataWrapper in
            switch nodeDataWrapper {
            case .action(let actionData):
                return actionData.toNode()
            case .creation(let creationData):
                return creationData.toNode()
            case .base(let baseData):
                return baseData.toNode()
            }
        }

        return segment
    }
}

