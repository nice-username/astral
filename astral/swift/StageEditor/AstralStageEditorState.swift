//
//  AstralStageEditorState.swift
//  astral
//
//  Created by Joseph Haygood on 11/2/23.
//

import Foundation

enum AstralStageEditorState {
    case idle
    case selectingPath
    case drawingNewPath
    case appendingToPath
    case editingNode
    case editingBezier
    case selectingNodeType
    case selectingNodeActionType
    case placingCreationNode
    case placingActionNode
    case placingPathingNode
    case movingPath
}
