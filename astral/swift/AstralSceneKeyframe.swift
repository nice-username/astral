//
//  AstralSceneKeyframe.swift
//  astral
//
//  Created by Joseph Haygood on 5/22/24.
//

import Foundation
import SceneKit

struct AstralSceneKeyframe {
    var name: String = ""
    var timeWait: TimeInterval
    var timeApply: TimeInterval
    var position: SCNVector3
    var eulerAngles: SCNVector3
}
