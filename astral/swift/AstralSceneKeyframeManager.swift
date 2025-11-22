//
//  AstralSceneKeyframeManager.swift
//  astral
//
//  Created by Joseph Haygood on 5/22/24.
//

import Foundation
import SceneKit

class AstralSceneKeyframeManager {
    private var keyframes: [AstralSceneKeyframe] = []
    
    func addTestData() {
        addKeyframe(name: "Keyframe 1", timeWait: 0.5, timeApply: 2.0, position: SCNVector3(x: 0, y: 4, z: 0), eulerAngles: SCNVector3(x: 2, y: 0, z: 0))
        addKeyframe(name: "Keyframe 2", timeWait: 0.5, timeApply: 2.5, position: SCNVector3(x: 0, y: 6.33, z: 0), eulerAngles: SCNVector3(x: 1, y: 2, z: 0))
        addKeyframe(name: "Keyframe 3", timeWait: 0.5, timeApply: 3.0, position: SCNVector3(x: 0, y: 3, z: 10), eulerAngles: SCNVector3(x: 1, y: -0.5, z: 0))
    }
    
    func addKeyframe(name: String, timeWait: TimeInterval, timeApply: TimeInterval, position: SCNVector3, eulerAngles: SCNVector3) {
        let keyframe = AstralSceneKeyframe(name: name, timeWait: timeWait, timeApply: timeApply, position: position, eulerAngles: eulerAngles)
        keyframes.append(keyframe)
    }
    
    func deleteKeyframe(at index: Int) {
        if index >= 0 && index < keyframes.count {
            keyframes.remove(at: index)
        }
    }
    
    func getKeyframe(at index: Int) -> AstralSceneKeyframe? {
        if index >= 0 && index < keyframes.count {
            return keyframes[index]
        }
        return nil
    }
    
    func setKeyframe(at index: Int, from keyframe: AstralSceneKeyframe) {
        if index >= 0 && index < keyframes.count {
            keyframes[index] = keyframe
        }
    }
    
    func getAllKeyframes() -> [AstralSceneKeyframe] {
        return keyframes
    }
}
