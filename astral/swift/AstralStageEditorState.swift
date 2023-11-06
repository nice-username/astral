//
//  AstralStageEditorState.swift
//  astral
//
//  Created by Joseph Haygood on 11/2/23.
//

import Foundation

enum AstralStageEditorState {
    case idle
    case drawingNewPath
    case appendingToPath
    case editingNode
    case editingBezier
}
